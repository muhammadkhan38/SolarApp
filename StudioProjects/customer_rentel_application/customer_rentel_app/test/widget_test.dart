import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:customer_rentel_app/features/shared/status_badge.dart';
import 'package:customer_rentel_app/models/booking.dart';
import 'package:customer_rentel_app/models/booking_status.dart';

void main() {
  test('booking parser accepts Laravel-style wrapped detail fields', () {
    final booking = Booking.fromJson({
      'id': 42,
      'reference': 'PL-1042',
      'status': 'assigned',
      'pickup_location': 'JFK Terminal 4',
      'dropoff_location': 'The Plaza Hotel',
      'pickup_at': '2026-07-01T20:30:00Z',
      'vehicle_class': 'suv',
      'passenger_count': '3',
      'total': '185.50',
      'pickup_lat': '40.6413',
      'pickup_lng': '-73.7781',
      'driver_location': {'lat': 40.7, 'lng': -73.9},
      'driver': {'name': 'Marcus Reed', 'phone': '+15555550123'},
      'vehicle': {'name': 'Cadillac Escalade', 'plate': 'A2Z-777'},
      'allowed_actions': ['cancel'],
    });

    expect(booking.id, 42);
    expect(booking.reference, 'PL-1042');
    expect(booking.status, BookingStatus.assigned);
    expect(booking.passengerCount, 3);
    expect(booking.total, 185.50);
    expect(booking.hasPickupCoords, isTrue);
    expect(booking.hasDriverCoords, isTrue);
    expect(booking.driver?.name, 'Marcus Reed');
    expect(booking.vehicle?.plate, 'A2Z-777');
    expect(booking.canCancel, isTrue);
  });

  test('booking draft serializes to customer API contract', () {
    final pickupAt = DateTime.utc(2026, 7, 1, 20, 30);
    final draft = BookingDraft(
      pickupLocation: 'JFK Terminal 4',
      dropoffLocation: 'The Plaza Hotel',
      pickupAt: pickupAt,
      vehicleClass: 'suv',
      contactPhone: '+15555550123',
      hours: 2,
      passengerCount: 3,
      notes: 'Meet at arrivals',
    );

    expect(draft.toJson(), {
      'pickup_location': 'JFK Terminal 4',
      'dropoff_location': 'The Plaza Hotel',
      'pickup_at': '2026-07-01T20:30:00.000Z',
      'vehicle_class': 'suv',
      'contact_phone': '+15555550123',
      'hours': 2,
      'passenger_count': 3,
      'notes': 'Meet at arrivals',
    });
  });

  testWidgets('status badge shows customer-facing lifecycle label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusBadge(BookingStatus.enRoute)),
      ),
    );

    expect(find.text('Driver on the way'), findsOneWidget);
    expect(find.byType(Container), findsWidgets);
  });
}
