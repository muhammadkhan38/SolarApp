import 'package:flutter/foundation.dart';

enum TransactionType { purchase, sale }

enum PaymentStatus { paid, partial, due }

@immutable
class Transaction {
  const Transaction({
    required this.id,
    required this.type,
    required this.partyId,
    required this.partyName,
    required this.panelId,
    required this.panelName,
    required this.wattsPerPanel,
    required this.quantity,
    required this.pricePerWatt,
    required this.paidAmount,
    required this.timestamp,
  });

  final String id;
  final TransactionType type;

  final String partyId;
  final String partyName;

  final String panelId;
  final String panelName;

  final int wattsPerPanel;
  final int quantity;
  final double pricePerWatt;

  final double paidAmount;
  final DateTime timestamp;

  int get totalWatts => wattsPerPanel * quantity;

  double get totalAmount => pricePerWatt * totalWatts;

  double get dueAmount => (totalAmount - paidAmount).clamp(0, double.infinity);

  PaymentStatus get paymentStatus {
    if (paidAmount >= totalAmount && totalAmount > 0) {
      return PaymentStatus.paid;
    }
    if (paidAmount > 0) {
      return PaymentStatus.partial;
    }
    return PaymentStatus.due;
  }

  Transaction copyWith({
    String? id,
    TransactionType? type,
    String? partyId,
    String? partyName,
    String? panelId,
    String? panelName,
    int? wattsPerPanel,
    int? quantity,
    double? pricePerWatt,
    double? paidAmount,
    DateTime? timestamp,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      partyId: partyId ?? this.partyId,
      partyName: partyName ?? this.partyName,
      panelId: panelId ?? this.panelId,
      panelName: panelName ?? this.panelName,
      wattsPerPanel: wattsPerPanel ?? this.wattsPerPanel,
      quantity: quantity ?? this.quantity,
      pricePerWatt: pricePerWatt ?? this.pricePerWatt,
      paidAmount: paidAmount ?? this.paidAmount,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
