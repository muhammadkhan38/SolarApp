import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/config/app_config.dart';
import '../../core/router/app_router.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookings_provider.dart';
import '../shared/async_value_view.dart';
import '../shared/status_badge.dart';

class TripsListScreen extends ConsumerStatefulWidget {
  const TripsListScreen({super.key});

  @override
  ConsumerState<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends ConsumerState<TripsListScreen> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    // No websockets: poll the active-trips list on an interval.
    _poll = Timer.periodic(AppConfig.pollInterval, (_) {
      if (mounted) ref.invalidate(activeBookingsProvider);
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(activeBookingsProvider);
    final driver = ref.watch(authControllerProvider).driver;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My trips'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push(Routes.profile),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(activeBookingsProvider.future),
        child: AsyncValueView<List<Booking>>(
          value: bookings,
          onRetry: () => ref.invalidate(activeBookingsProvider),
          builder: (list) {
            if (list.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(Icons.event_available,
                      size: 56, color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No active trips${driver != null ? ', ${driver.name.split(' ').first}' : ''}.\nNew assignments appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _TripCard(
                booking: list[i],
                onTap: () => context.push(Routes.trip(list[i].id)),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;
  const _TripCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEE, MMM d • h:mm a');
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(booking.reference,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  const Spacer(),
                  StatusBadge(booking.status),
                ],
              ),
              if (booking.vehicleClass != null) ...[
                const SizedBox(height: 4),
                Text(booking.vehicleClass!.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11, letterSpacing: 1)),
              ],
              const SizedBox(height: 12),
              _line(Icons.trip_origin, booking.pickupLocation),
              if (booking.dropoffLocation != null) ...[
                const SizedBox(height: 6),
                _line(Icons.place, booking.dropoffLocation!),
              ],
              if (booking.pickupAt != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 15, color: Colors.white38),
                    const SizedBox(width: 6),
                    Text(df.format(booking.pickupAt!),
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(IconData icon, String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.white38),
          const SizedBox(width: 8),
          Expanded(child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis)),
        ],
      );
}
