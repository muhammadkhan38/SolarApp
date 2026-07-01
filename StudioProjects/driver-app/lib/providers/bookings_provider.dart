import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking.dart';
import '../models/booking_status.dart';

/// Static booking data used to test the driver app without the Laravel API.
class BookingsRepository {
  BookingsRepository()
      : _bookings = {
          for (final booking in _initialBookings()) booking.id: booking,
        };

  final Map<int, Booking> _bookings;

  Future<List<Booking>> list() async {
    final list = _bookings.values
        .where((booking) =>
            booking.status != BookingStatus.completed &&
            booking.status != BookingStatus.declined)
        .toList();
    list.sort((a, b) {
      final aTime = a.pickupAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.pickupAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aTime.compareTo(bTime);
    });
    return List.unmodifiable(list);
  }

  Future<Booking> get(int id) async {
    final booking = _bookings[id];
    if (booking == null) {
      throw StateError('Booking #$id was not found in static test data.');
    }
    return booking;
  }

  Future<Booking> accept(int id) async {
    return _save(
      (await get(id)).copyWith(
        status: BookingStatus.enRoute,
        allowedTransitions: const ['arrived'],
      ),
    );
  }

  Future<void> decline(int id) async {
    _save(
      (await get(id)).copyWith(
        status: BookingStatus.declined,
        allowedTransitions: const [],
      ),
    );
  }

  Future<Booking?> updateStatus(int id, String status) async {
    final next = BookingStatus.fromApi(status);
    if (next == BookingStatus.declined) {
      await decline(id);
      return null;
    }

    return _save(
      (await get(id)).copyWith(
        status: next,
        allowedTransitions: _transitionsFor(next),
      ),
    );
  }

  Future<void> pushLocation(double lat, double lng) async {
    // Static test data does not send GPS pings anywhere.
  }

  Booking _save(Booking booking) {
    _bookings[booking.id] = booking;
    return booking;
  }

  List<String> _transitionsFor(BookingStatus status) {
    switch (status) {
      case BookingStatus.assigned:
        return const ['en_route', 'declined'];
      case BookingStatus.enRoute:
        return const ['arrived'];
      case BookingStatus.arrived:
        return const ['in_progress'];
      case BookingStatus.inProgress:
        return const ['completed'];
      default:
        return const [];
    }
  }
}

final bookingsRepositoryProvider =
    Provider<BookingsRepository>((ref) => BookingsRepository());

/// The driver's active trips (assigned, en_route, arrived, in_progress).
final activeBookingsProvider =
    FutureProvider.autoDispose<List<Booking>>((ref) async {
  return ref.watch(bookingsRepositoryProvider).list();
});

/// Full detail for one booking. Re-fetched by the detail screen on a timer.
final bookingDetailProvider =
    FutureProvider.autoDispose.family<Booking, int>((ref, id) async {
  return ref.watch(bookingsRepositoryProvider).get(id);
});

List<Booking> _initialBookings() {
  final now = DateTime.now();
  return [
    Booking(
      id: 1001,
      reference: 'PL-1001',
      status: BookingStatus.assigned,
      vehicleClass: 'Executive SUV',
      pickupLocation: 'JW Marriott Essex House, 160 Central Park S',
      dropoffLocation: 'John F. Kennedy International Airport, Terminal 4',
      pickupAt: now.add(const Duration(minutes: 35)),
      allowedTransitions: const ['en_route', 'declined'],
      pickupLat: 40.7664,
      pickupLng: -73.9781,
      dropoffLat: 40.6413,
      dropoffLng: -73.7781,
      hours: 2,
      total: 185,
      notes: 'Meet guest at the lobby concierge desk. Two large suitcases.',
      customer: const Contact(
        name: 'Amelia Johnson',
        phone: '+1 917 555 0118',
      ),
      vehicle: const VehicleInfo(name: 'Cadillac Escalade', plate: 'NYC 8L90'),
    ),
    Booking(
      id: 1002,
      reference: 'PL-1002',
      status: BookingStatus.enRoute,
      vehicleClass: 'Luxury Sedan',
      pickupLocation: 'The Plaza Hotel, 768 5th Ave',
      dropoffLocation: 'LaGuardia Airport, Terminal B',
      pickupAt: now.add(const Duration(minutes: 5)),
      allowedTransitions: const ['arrived'],
      pickupLat: 40.7645,
      pickupLng: -73.9743,
      dropoffLat: 40.7769,
      dropoffLng: -73.8740,
      hours: 1.5,
      total: 142.50,
      notes: 'Guest requested a quiet ride and bottled water.',
      customer: const Contact(
        name: 'Daniel Brooks',
        phone: '+1 646 555 0197',
      ),
      vehicle: const VehicleInfo(
        name: 'Mercedes-Benz S-Class',
        plate: 'NYC S550',
      ),
    ),
    Booking(
      id: 1003,
      reference: 'PL-1003',
      status: BookingStatus.arrived,
      vehicleClass: 'Sprinter Van',
      pickupLocation: 'Penn Station, 8th Ave entrance',
      dropoffLocation: 'Newark Liberty International Airport',
      pickupAt: now.subtract(const Duration(minutes: 10)),
      allowedTransitions: const ['in_progress'],
      pickupLat: 40.7506,
      pickupLng: -73.9935,
      dropoffLat: 40.6895,
      dropoffLng: -74.1745,
      hours: 2.5,
      total: 260,
      notes: 'Group of six. Hold sign with company name.',
      customer: const Contact(
        name: 'Sofia Patel',
        phone: '+1 212 555 0164',
      ),
      vehicle: const VehicleInfo(name: 'Mercedes Sprinter', plate: 'NYC VAN7'),
    ),
    Booking(
      id: 1004,
      reference: 'PL-1004',
      status: BookingStatus.inProgress,
      vehicleClass: 'Executive SUV',
      pickupLocation: 'Brooklyn Cruise Terminal, Pier 12',
      dropoffLocation: 'Four Seasons Hotel New York Downtown',
      pickupAt: now.subtract(const Duration(minutes: 45)),
      allowedTransitions: const ['completed'],
      pickupLat: 40.6816,
      pickupLng: -74.0132,
      dropoffLat: 40.7127,
      dropoffLng: -74.0090,
      hours: 3,
      total: 325,
      notes: 'VIP transfer. Dispatch approved route via Battery Tunnel.',
      customer: const Contact(
        name: 'Robert Chen',
        phone: '+1 718 555 0136',
      ),
      vehicle: const VehicleInfo(name: 'Lincoln Navigator', plate: 'NYC VIP4'),
    ),
  ];
}
