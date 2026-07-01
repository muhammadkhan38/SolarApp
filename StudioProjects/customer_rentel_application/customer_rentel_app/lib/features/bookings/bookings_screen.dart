import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/router/app_router.dart';
import '../../models/booking.dart';
import '../../providers/bookings_provider.dart';
import '../shared/async_value_view.dart';
import '../shared/booking_card.dart';
import '../shared/empty_state.dart';
import '../shared/main_nav.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _poll = Timer.periodic(AppConfig.pollInterval, (_) {
      if (mounted) ref.invalidate(allBookingsProvider);
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        actions: [
          IconButton(
            tooltip: 'Create booking',
            icon: const Icon(Icons.add),
            onPressed: () => context.push(Routes.createBooking),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Active'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      bottomNavigationBar: const MainNav(index: 1),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _BookingTab(filter: BookingFilter.upcoming),
          _BookingTab(filter: BookingFilter.active),
          _BookingTab(filter: BookingFilter.past),
        ],
      ),
    );
  }
}

class _BookingTab extends ConsumerWidget {
  final BookingFilter filter;

  const _BookingTab({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(filteredBookingsProvider(filter));
    return RefreshIndicator(
      onRefresh: () => ref.refresh(allBookingsProvider.future),
      child: AsyncValueView<List<Booking>>(
        value: bookings,
        onRetry: () => ref.invalidate(allBookingsProvider),
        builder: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: _emptyIcon(filter),
              title: _emptyTitle(filter),
              message: _emptyMessage(filter),
              actionLabel: 'Create booking',
              onAction: () => context.push(Routes.createBooking),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => BookingCard(
              booking: list[index],
              onTap: () => context.push(Routes.booking(list[index].id)),
            ),
          );
        },
      ),
    );
  }

  IconData _emptyIcon(BookingFilter filter) {
    return switch (filter) {
      BookingFilter.upcoming => Icons.event_available_outlined,
      BookingFilter.active => Icons.near_me_outlined,
      BookingFilter.past => Icons.history,
    };
  }

  String _emptyTitle(BookingFilter filter) {
    return switch (filter) {
      BookingFilter.upcoming => 'No upcoming rides',
      BookingFilter.active => 'No active ride',
      BookingFilter.past => 'No ride history yet',
    };
  }

  String _emptyMessage(BookingFilter filter) {
    return switch (filter) {
      BookingFilter.upcoming =>
        'Your confirmed reservations and assigned rides will appear here.',
      BookingFilter.active =>
        'When your chauffeur is on the way, live ride details appear here.',
      BookingFilter.past => 'Completed and cancelled rides will appear here.',
    };
  }
}
