import 'package:flutter/material.dart';

String formatWatts(int watts) {
  if (watts >= 1000) {
    final kw = watts / 1000;
    return '${kw.toStringAsFixed(1)} kW';
  }
  return '$watts W';
}

String formatCurrency(double amount) {
  // Keep it simple (no intl dependency).
  return 'Rs ${amount.toStringAsFixed(0)}';
}

String formatTimestamp(DateTime dt) {
  final time = TimeOfDay.fromDateTime(dt);
  final hh = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final mm = time.minute.toString().padLeft(2, '0');
  final ampm = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hh:$mm $ampm';
}
