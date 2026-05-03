import 'package:isar/isar.dart';

import 'contact.dart';
import 'product.dart';

part 'solar_transaction.g.dart';

enum TransactionKind { purchase, sale }

enum PaymentStatus { paid, partial, due }

@collection
class SolarTransaction {
  SolarTransaction();

  Id id = Isar.autoIncrement;

  /// Human-readable code like TX-0001.
  @Index(unique: true)
  late String code;

  late DateTime timestamp;

  @enumerated
  late TransactionKind kind;

  final contact = IsarLink<Contact>();
  final product = IsarLink<Product>();

  /// Snapshot fields for invoice/history.
  late String contactCode;
  late String contactName;
  String? contactPhone;

  late String productCode;
  late String panelName;

  late int wattsPerPanel;
  late int quantity;
  late double pricePerWatt;

  late double totalAmount;
  late double amountPaid;

  /// Stored remaining balance for this transaction only.
  late double remainingBalance;

  int get totalWatts => wattsPerPanel * quantity;

  @ignore
  PaymentStatus get paymentStatus {
    if (totalAmount <= 0) return PaymentStatus.due;
    if (amountPaid >= totalAmount) return PaymentStatus.paid;
    if (amountPaid > 0) return PaymentStatus.partial;
    return PaymentStatus.due;
  }
}
