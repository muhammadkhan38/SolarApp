import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../models/booking.dart';
import '../../providers/bookings_provider.dart';
import '../shared/async_value_view.dart';
import '../shared/status_badge.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final int bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  Timer? _poll;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(AppConfig.pollInterval, (_) {
      if (mounted) ref.invalidate(bookingDetailProvider(widget.bookingId));
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _cancel(Booking booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text(
          'We will ask dispatch to release this reservation. Cancellation may be unavailable once the chauffeur is en route.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep booking'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _busy = true);
    try {
      await ref.read(bookingsRepositoryProvider).cancel(booking.id);
      ref.invalidate(bookingDetailProvider(booking.id));
      ref.invalidate(allBookingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancellation requested.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMaps({
    required String label,
    double? lat,
    double? lng,
    String? address,
  }) async {
    final query = lat != null && lng != null ? '$lat,$lng' : address;
    if (query == null || query.isEmpty) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(bookingDetailProvider(widget.bookingId));
    return Scaffold(
      appBar: AppBar(title: const Text('Booking detail')),
      body: AsyncValueView<Booking>(
        value: detail,
        onRetry: () => ref.invalidate(bookingDetailProvider(widget.bookingId)),
        builder: (booking) => Column(
          children: [
            _BookingMap(booking: booking),
            Expanded(
              child: _DetailBody(
                booking: booking,
                onCall: _call,
                onOpenMaps: _openMaps,
              ),
            ),
            _ActionBar(
              booking: booking,
              busy: _busy,
              onCancel: booking.canCancel ? () => _cancel(booking) : null,
              onCallSupport: () => _call(AppConfig.supportPhone),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingMap extends StatelessWidget {
  final Booking booking;

  const _BookingMap({required this.booking});

  @override
  Widget build(BuildContext context) {
    final hasMap =
        booking.hasPickupCoords ||
        booking.hasDropoffCoords ||
        booking.hasDriverCoords;
    return SizedBox(
      height: 240,
      child: hasMap
          ? GoogleMap(
              initialCameraPosition: _initialCamera(),
              markers: _markers(),
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            )
          : Container(
              color: const Color(0xFF141416),
              alignment: Alignment.center,
              child: const Text(
                'Map appears when coordinates are available',
                style: TextStyle(color: Colors.white54),
              ),
            ),
    );
  }

  CameraPosition _initialCamera() {
    if (booking.hasDriverCoords) {
      return CameraPosition(
        target: LatLng(booking.driverLat!, booking.driverLng!),
        zoom: 13,
      );
    }
    if (booking.hasPickupCoords) {
      return CameraPosition(
        target: LatLng(booking.pickupLat!, booking.pickupLng!),
        zoom: 13,
      );
    }
    return CameraPosition(
      target: LatLng(booking.dropoffLat!, booking.dropoffLng!),
      zoom: 13,
    );
  }

  Set<Marker> _markers() {
    final markers = <Marker>{};
    if (booking.hasPickupCoords) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(booking.pickupLat!, booking.pickupLng!),
          infoWindow: InfoWindow(
            title: 'Pickup',
            snippet: booking.pickupLocation,
          ),
          icon: kIsWeb
              ? BitmapDescriptor.defaultMarker
              : BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
        ),
      );
    }
    if (booking.hasDropoffCoords) {
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: LatLng(booking.dropoffLat!, booking.dropoffLng!),
          infoWindow: InfoWindow(
            title: 'Drop-off',
            snippet: booking.dropoffLocation,
          ),
        ),
      );
    }
    if (booking.hasDriverCoords) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(booking.driverLat!, booking.driverLng!),
          infoWindow: const InfoWindow(title: 'Chauffeur'),
          icon: kIsWeb
              ? BitmapDescriptor.defaultMarker
              : BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
        ),
      );
    }
    return markers;
  }
}

class _DetailBody extends StatelessWidget {
  final Booking booking;
  final Future<void> Function(String phone) onCall;
  final Future<void> Function({
    required String label,
    double? lat,
    double? lng,
    String? address,
  })
  onOpenMaps;

  const _DetailBody({
    required this.booking,
    required this.onCall,
    required this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, h:mm a');
    final currency = NumberFormat.simpleCurrency(name: 'USD');
    final b = booking;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                b.reference.isEmpty ? 'Booking #${b.id}' : b.reference,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            StatusBadge(b.status),
          ],
        ),
        const SizedBox(height: 16),
        _card([
          _kv(Icons.trip_origin, 'Pickup', b.pickupLocation),
          if (b.dropoffLocation != null)
            _kv(Icons.place_outlined, 'Drop-off', b.dropoffLocation!),
          if (b.pickupAt != null)
            _kv(Icons.schedule, 'Pickup time', dateFormat.format(b.pickupAt!)),
          if (b.vehicleClass != null)
            _kv(
              Icons.directions_car_outlined,
              'Vehicle class',
              b.vehicleClass!,
            ),
          if (b.hours != null) _kv(Icons.timelapse, 'Hours', '${b.hours}'),
          if (b.passengerCount != null)
            _kv(Icons.people_outline, 'Passengers', '${b.passengerCount}'),
          if (b.total != null)
            _kv(Icons.payments_outlined, 'Total', currency.format(b.total)),
        ]),
        if (b.notes != null && b.notes!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          _card([_kv(Icons.sticky_note_2_outlined, 'Notes', b.notes!)]),
        ],
        if (b.driver != null) ...[
          const SizedBox(height: 12),
          _card([
            _kv(
              Icons.person_pin_circle_outlined,
              'Chauffeur',
              b.driver!.name ?? 'Assigned chauffeur',
            ),
            if (b.driver!.phone != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone, color: AppTheme.gold),
                title: Text(b.driver!.phone!),
                trailing: OutlinedButton.icon(
                  onPressed: () => onCall(b.driver!.phone!),
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                  ),
                ),
              ),
          ]),
        ],
        if (b.vehicle != null) ...[
          const SizedBox(height: 12),
          _card([
            _kv(Icons.directions_car, 'Vehicle', b.vehicle!.displayName),
            if (b.vehicle!.plate != null)
              _kv(Icons.pin_outlined, 'Plate', b.vehicle!.plate!),
            if (b.vehicle!.color != null)
              _kv(Icons.palette_outlined, 'Color', b.vehicle!.color!),
          ]),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (b.hasPickupCoords || b.pickupLocation.isNotEmpty)
              _smallAction(
                icon: Icons.trip_origin,
                label: 'Pickup map',
                onTap: () => onOpenMaps(
                  label: 'Pickup',
                  lat: b.pickupLat,
                  lng: b.pickupLng,
                  address: b.pickupLocation,
                ),
              ),
            if (b.hasDropoffCoords || b.dropoffLocation != null)
              _smallAction(
                icon: Icons.place_outlined,
                label: 'Drop-off map',
                onTap: () => onOpenMaps(
                  label: 'Drop-off',
                  lat: b.dropoffLat,
                  lng: b.dropoffLng,
                  address: b.dropoffLocation,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _card(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(children: children),
      ),
    );
  }

  Widget _kv(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.gold),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: Text(label, style: const TextStyle(color: Colors.white54)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final Booking booking;
  final bool busy;
  final VoidCallback? onCancel;
  final VoidCallback onCallSupport;

  const _ActionBar({
    required this.booking,
    required this.busy,
    required this.onCancel,
    required this.onCallSupport,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(
          color: Color(0xFF101012),
          border: Border(top: BorderSide(color: Colors.white12)),
        ),
        child: busy
            ? const Center(child: CircularProgressIndicator())
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCallSupport,
                      icon: const Icon(Icons.support_agent),
                      label: const Text('Support'),
                    ),
                  ),
                  if (onCancel != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.danger,
                          side: const BorderSide(color: AppTheme.danger),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
