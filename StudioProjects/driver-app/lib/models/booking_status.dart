import 'package:flutter/material.dart';

/// Booking statuses exactly as the Laravel API emits them (lowercase strings).
/// The driver-facing lifecycle is:
///   assigned → en_route → arrived → in_progress → completed
/// with `declined` returning a trip to dispatch (status becomes `confirmed`).
enum BookingStatus {
  assigned('assigned', 'Assigned'),
  enRoute('en_route', 'En route'),
  arrived('arrived', 'Arrived'),
  inProgress('in_progress', 'In progress'),
  completed('completed', 'Completed'),
  confirmed('confirmed', 'Confirmed'),
  declined('declined', 'Declined'),
  unknown('unknown', 'Unknown');

  final String api;
  final String label;
  const BookingStatus(this.api, this.label);

  static BookingStatus fromApi(String? value) {
    return BookingStatus.values.firstWhere(
      (s) => s.api == value,
      orElse: () => BookingStatus.unknown,
    );
  }

  /// True while the trip is live and should be worked / GPS-streamed.
  bool get isActive =>
      this == BookingStatus.enRoute ||
      this == BookingStatus.arrived ||
      this == BookingStatus.inProgress;

  Color get color {
    switch (this) {
      case BookingStatus.assigned:
        return const Color(0xFFC9A24B); // gold — needs action
      case BookingStatus.enRoute:
      case BookingStatus.arrived:
        return const Color(0xFF4F9DDE);
      case BookingStatus.inProgress:
        return const Color(0xFF3FB37F);
      case BookingStatus.completed:
        return const Color(0xFF7E8A97);
      case BookingStatus.declined:
        return const Color(0xFFD9534F);
      default:
        return const Color(0xFF7E8A97);
    }
  }

  /// Human label for the action that advances OUT of this status.
  String? get advanceLabel {
    switch (this) {
      case BookingStatus.enRoute:
        return 'Mark arrived';
      case BookingStatus.arrived:
        return 'Start trip';
      case BookingStatus.inProgress:
        return 'Complete trip';
      default:
        return null;
    }
  }
}
