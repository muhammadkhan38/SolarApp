import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../models/booking.dart';
import '../../models/booking_status.dart';
import '../../providers/bookings_provider.dart';
import '../../providers/core_providers.dart';
import '../shared/async_value_view.dart';
import '../shared/status_badge.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final int bookingId;
  const TripDetailScreen({super.key, required this.bookingId});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  static const _streamLiveGps = false;

  Timer? _poll;
  Timer? _pingTimer;
  StreamSubscription<Position>? _posSub;
  Position? _lastPos;
  bool _streaming = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Poll detail so dispatch-side status changes show up.
    _poll = Timer.periodic(AppConfig.pollInterval, (_) {
      if (mounted) ref.invalidate(bookingDetailProvider(widget.bookingId));
    });
  }

  // ---- live GPS ping while the trip is active --------------------------------
  Future<void> _startStreaming() async {
    if (_streaming) return;
    final ok = await ref.read(locationServiceProvider).ensurePermission();
    if (!ok) return;
    _streaming = true;
    _posSub = ref.read(locationServiceProvider).watch().listen((p) {
      _lastPos = p;
    });
    // Push on a steady cadence so the admin Live Map stays fresh even when idle.
    _pingTimer = Timer.periodic(AppConfig.locationPingInterval, (_) => _pushPing());
    _pushPing();
  }

  Future<void> _pushPing() async {
    final p = _lastPos ?? await ref.read(locationServiceProvider).current();
    if (p == null) return;
    try {
      await ref.read(bookingsRepositoryProvider).pushLocation(p.latitude, p.longitude);
    } catch (_) {/* a dropped ping shouldn't disrupt the trip */}
  }

  void _stopStreaming() {
    _posSub?.cancel();
    _posSub = null;
    _pingTimer?.cancel();
    _pingTimer = null;
    _streaming = false;
  }

  @override
  void dispose() {
    _poll?.cancel();
    _stopStreaming();
    super.dispose();
  }

  // ---- actions ---------------------------------------------------------------
  Future<void> _accept() => _run(() async {
        await ref.read(bookingsRepositoryProvider).accept(widget.bookingId);
      });

  Future<void> _advance(String status) => _run(() async {
        await ref.read(bookingsRepositoryProvider).updateStatus(widget.bookingId, status);
      });

  Future<void> _decline() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Decline trip?'),
        content: const Text('This returns the booking to dispatch for reassignment.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Decline')),
        ],
      ),
    );
    if (confirm != true) return;
    await _run(() async {
      await ref.read(bookingsRepositoryProvider).decline(widget.bookingId);
    }, popAfter: true);
  }

  Future<void> _run(Future<void> Function() action, {bool popAfter = false}) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(bookingDetailProvider(widget.bookingId));
      ref.invalidate(activeBookingsProvider);
      if (popAfter && mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _navigate(Booking b) async {
    final target = b.status == BookingStatus.inProgress && b.hasDropoffCoords
        ? '${b.dropoffLat},${b.dropoffLng}'
        : b.hasPickupCoords
            ? '${b.pickupLat},${b.pickupLng}'
            : null;
    if (target == null) return;
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$target');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Set<Marker> _markers(Booking b) {
    final m = <Marker>{};
    if (b.hasPickupCoords) {
      m.add(Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(b.pickupLat!, b.pickupLng!),
        infoWindow: InfoWindow(title: 'Pickup', snippet: b.pickupLocation),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }
    if (b.hasDropoffCoords) {
      m.add(Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(b.dropoffLat!, b.dropoffLng!),
        infoWindow: InfoWindow(title: 'Drop-off', snippet: b.dropoffLocation),
      ));
    }
    return m;
  }

  CameraPosition _initialCamera(Booking b) {
    if (b.hasPickupCoords) {
      return CameraPosition(target: LatLng(b.pickupLat!, b.pickupLng!), zoom: 13);
    }
    if (b.hasDropoffCoords) {
      return CameraPosition(target: LatLng(b.dropoffLat!, b.dropoffLng!), zoom: 13);
    }
    return const CameraPosition(target: LatLng(40.7128, -74.0060), zoom: 11);
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(bookingDetailProvider(widget.bookingId));
    return Scaffold(
      appBar: AppBar(title: const Text('Trip detail')),
      body: AsyncValueView<Booking>(
        value: detail,
        onRetry: () => ref.invalidate(bookingDetailProvider(widget.bookingId)),
        builder: (b) {
          // Sync GPS streaming with trip state.
          if (_streamLiveGps && b.status.isActive && !_streaming) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _startStreaming());
          } else if (!b.status.isActive && _streaming) {
            _stopStreaming();
          }
          return Column(
            children: [
              SizedBox(
                height: 240,
                child: (b.hasPickupCoords || b.hasDropoffCoords)
                    ? GoogleMap(
                        initialCameraPosition: _initialCamera(b),
                        markers: _markers(b),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                      )
                    : Container(
                        color: const Color(0xFF161619),
                        alignment: Alignment.center,
                        child: const Text('No map coordinates for this trip',
                            style: TextStyle(color: Colors.white38)),
                      ),
              ),
              Expanded(child: _DetailBody(booking: b, onCall: _call, onNavigate: () => _navigate(b))),
              _ActionBar(
                booking: b,
                busy: _busy,
                onAccept: _accept,
                onDecline: _decline,
                onAdvance: _advance,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final Booking booking;
  final Future<void> Function(String phone) onCall;
  final VoidCallback onNavigate;
  const _DetailBody({required this.booking, required this.onCall, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final df = DateFormat('EEE, MMM d • h:mm a');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(b.reference,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const Spacer(),
            StatusBadge(b.status),
          ],
        ),
        if (b.vehicleClass != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(b.vehicleClass!.toUpperCase(),
                style: const TextStyle(color: Colors.white54, letterSpacing: 1, fontSize: 12)),
          ),
        const SizedBox(height: 16),
        _card([
          _kv(Icons.trip_origin, 'Pickup', b.pickupLocation),
          if (b.dropoffLocation != null) _kv(Icons.place, 'Drop-off', b.dropoffLocation!),
          if (b.pickupAt != null) _kv(Icons.schedule, 'Pickup at', df.format(b.pickupAt!)),
          if (b.hours != null) _kv(Icons.timelapse, 'Hours', '${b.hours}'),
          if (b.total != null) _kv(Icons.payments, 'Total', '\$${b.total!.toStringAsFixed(2)}'),
        ]),
        if (b.notes != null && b.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _card([_kv(Icons.sticky_note_2_outlined, 'Notes', b.notes!)]),
        ],
        if (b.customer != null) ...[
          const SizedBox(height: 12),
          _card([
            _kv(Icons.person, 'Customer', b.customer!.name ?? '—'),
            if (b.customer!.phone != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone, color: Color(0xFFC9A24B)),
                title: Text(b.customer!.phone!),
                trailing: OutlinedButton.icon(
                  onPressed: () => onCall(b.customer!.phone!),
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                ),
              ),
          ]),
        ],
        if (b.vehicle != null) ...[
          const SizedBox(height: 12),
          _card([
            _kv(Icons.directions_car, 'Vehicle', b.vehicle!.name ?? '—'),
            if (b.vehicle!.plate != null) _kv(Icons.pin, 'Plate', b.vehicle!.plate!),
          ]),
        ],
        if (b.hasPickupCoords || b.hasDropoffCoords) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onNavigate,
            icon: const Icon(Icons.navigation_outlined),
            label: const Text('Open in Maps'),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _card(List<Widget> children) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(children: children),
        ),
      );

  Widget _kv(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: const Color(0xFFC9A24B)),
            const SizedBox(width: 12),
            SizedBox(width: 78, child: Text(label, style: const TextStyle(color: Colors.white54))),
            Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      );
}

class _ActionBar extends StatelessWidget {
  final Booking booking;
  final bool busy;
  final Future<void> Function() onAccept;
  final Future<void> Function() onDecline;
  final Future<void> Function(String status) onAdvance;

  const _ActionBar({
    required this.booking,
    required this.busy,
    required this.onAccept,
    required this.onDecline,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    final b = booking;
    Widget content;

    if (busy) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (b.status == BookingStatus.assigned) {
      content = Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onDecline,
              style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD9534F),
                  side: const BorderSide(color: Color(0xFFD9534F))),
              child: const Text('Decline'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: FilledButton(onPressed: onAccept, child: const Text('Accept trip'))),
        ],
      );
    } else if (b.status.isActive && b.nextStatus != null) {
      content = FilledButton.icon(
        onPressed: () => onAdvance(b.nextStatus!),
        icon: const Icon(Icons.arrow_forward),
        label: Text(b.status.advanceLabel ?? 'Advance'),
      );
    } else {
      content = Center(
        child: Text(b.status.label, style: const TextStyle(color: Colors.white54)),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(
          color: Color(0xFF161619),
          border: Border(top: BorderSide(color: Colors.white12)),
        ),
        child: content,
      ),
    );
  }
}
