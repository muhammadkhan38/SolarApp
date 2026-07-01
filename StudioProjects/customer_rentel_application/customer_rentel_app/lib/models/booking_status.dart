import 'package:flutter/material.dart';

enum BookingStatus {
  confirmed('confirmed', 'Booking confirmed'),
  assigned('assigned', 'Driver assigned'),
  enRoute('en_route', 'Driver on the way'),
  arrived('arrived', 'Driver arrived'),
  inProgress('in_progress', 'Trip in progress'),
  completed('completed', 'Completed'),
  declined('declined', 'Cancelled or reassignment needed'),
  cancelled('cancelled', 'Cancelled'),
  unknown('unknown', 'Status pending');

  final String api;
  final String label;
  const BookingStatus(this.api, this.label);

  static BookingStatus fromApi(String? value) {
    return BookingStatus.values.firstWhere(
      (status) => status.api == value,
      orElse: () => BookingStatus.unknown,
    );
  }

  bool get isActive =>
      this == BookingStatus.enRoute ||
      this == BookingStatus.arrived ||
      this == BookingStatus.inProgress;

  bool get isUpcoming =>
      this == BookingStatus.confirmed ||
      this == BookingStatus.assigned ||
      isActive;

  bool get isTerminal =>
      this == BookingStatus.completed ||
      this == BookingStatus.cancelled ||
      this == BookingStatus.declined;

  Color get color {
    switch (this) {
      case BookingStatus.confirmed:
      case BookingStatus.assigned:
        return const Color(0xFFC9A24B);
      case BookingStatus.enRoute:
      case BookingStatus.arrived:
        return const Color(0xFF4F9DDE);
      case BookingStatus.inProgress:
        return const Color(0xFF3FB37F);
      case BookingStatus.completed:
        return const Color(0xFF8D98A7);
      case BookingStatus.declined:
      case BookingStatus.cancelled:
        return const Color(0xFFD9534F);
      case BookingStatus.unknown:
        return const Color(0xFF8D98A7);
    }
  }
}
