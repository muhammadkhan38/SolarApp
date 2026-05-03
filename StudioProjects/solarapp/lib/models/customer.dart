import 'package:flutter/foundation.dart';

import 'party.dart';

@immutable
class Customer extends Party {
  const Customer({
    required super.id,
    required super.name,
    super.phone,
    super.totalWatts,
    super.lastPaymentDate,
    super.lastPaymentAmount,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    int? totalWatts,
    DateTime? lastPaymentDate,
    double? lastPaymentAmount,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      totalWatts: totalWatts ?? this.totalWatts,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      lastPaymentAmount: lastPaymentAmount ?? this.lastPaymentAmount,
    );
  }
}
