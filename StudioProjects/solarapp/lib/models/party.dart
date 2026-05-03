import 'package:flutter/foundation.dart';

@immutable
abstract class Party {
  const Party({
    required this.id,
    required this.name,
    this.phone,
    this.totalWatts = 0,
    this.lastPaymentDate,
    this.lastPaymentAmount = 0,
  });

  final String id;
  final String name;
  final String? phone;

  /// Aggregate watts associated with this party.
  final int totalWatts;

  /// Last payment recorded in the ledger.
  final DateTime? lastPaymentDate;
  final double lastPaymentAmount;
}
