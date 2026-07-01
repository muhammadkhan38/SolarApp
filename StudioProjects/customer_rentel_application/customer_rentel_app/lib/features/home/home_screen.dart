import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/config/app_config.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookings_provider.dart';
import '../shared/async_value_view.dart';
import '../shared/booking_card.dart';
import '../shared/empty_state.dart';
import '../shared/main_nav.dart';
import '../shared/status_badge.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(AppConfig.pollInterval, (_) {
      if (mounted) ref.invalidate(allBookingsProvider);
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(allBookingsProvider);
    final customer = ref.watch(authControllerProvider).customer;
    final firstName = customer?.name.split(' ').first;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Prince Limousine'),
            if (firstName != null && firstName.isNotEmpty)
              Text(
                'Welcome, $firstName',
                style: const TextStyle(color: AppTheme.goldSoft, fontSize: 12),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'New booking',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.push(Routes.createBooking),
          ),
        ],
      ),
      bottomNavigationBar: const MainNav(index: 0),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(allBookingsProvider.future),
        child: AsyncValueView<List<Booking>>(
          value: bookings,
          onRetry: () => ref.invalidate(allBookingsProvider),
          builder: (list) {
            final active = _bestActive(list);
            final recent = list.take(4).toList();
            if (list.isEmpty) {
              return EmptyState(
                icon: Icons.local_taxi_outlined,
                title: 'Your first ride awaits',
                message:
                    'Book airport transfers, hourly service, and executive rides from one polished place.',
                actionLabel: 'Create booking',
                onAction: () => context.push(Routes.createBooking),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _HeroAction(
                  booking: active,
                  onCreate: () => context.push(Routes.createBooking),
                  onOpen: active == null
                      ? null
                      : () => context.push(Routes.booking(active.id)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Recent bookings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go(Routes.bookings),
                      child: const Text('View all'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final booking in recent) ...[
                  BookingCard(
                    booking: booking,
                    onTap: () => context.push(Routes.booking(booking.id)),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Booking? _bestActive(List<Booking> bookings) {
    final live = bookings.where((booking) => booking.status.isActive).toList();
    if (live.isNotEmpty) return live.first;
    final upcoming = bookings
        .where((booking) => booking.status.isUpcoming)
        .where(
          (booking) =>
              booking.pickupAt == null ||
              booking.pickupAt!.isAfter(
                DateTime.now().subtract(const Duration(hours: 2)),
              ),
        )
        .toList();
    upcoming.sort((a, b) {
      final aTime = a.pickupAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.pickupAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aTime.compareTo(bTime);
    });
    return upcoming.isEmpty ? null : upcoming.first;
  }
}

class _HeroAction extends StatelessWidget {
  final Booking? booking;
  final VoidCallback onCreate;
  final VoidCallback? onOpen;

  const _HeroAction({
    required this.booking,
    required this.onCreate,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final dateFormat = DateFormat('EEE, MMM d, h:mm a');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: b == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Reserve your next black car',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Point-to-point and hourly rides with professional chauffeurs.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add),
                  label: const Text('Create booking'),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Current ride',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    StatusBadge(b.status),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  b.pickupLocation,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (b.dropoffLocation != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    b.dropoffLocation!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
                if (b.pickupAt != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    dateFormat.format(b.pickupAt!),
                    style: const TextStyle(color: AppTheme.goldSoft),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onOpen,
                        icon: const Icon(Icons.near_me_outlined),
                        label: const Text('Track ride'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.outlined(
                      tooltip: 'New booking',
                      onPressed: onCreate,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
