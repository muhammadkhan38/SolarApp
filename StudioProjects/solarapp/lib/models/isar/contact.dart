import 'package:isar/isar.dart';

part 'contact.g.dart';

@collection
class Contact {
  Contact();

  Id id = Isar.autoIncrement;

  /// Human-readable code like CUS-001 / SUP-001.
  @Index(unique: true)
  late String code;

  late String name;
  String? phone;

  /// True => supplier, False => customer.
  late bool isSupplier;

  /// Debit/Credit balance:
  /// - Customer: positive => customer owes shop
  /// - Supplier: positive => shop owes supplier
  late double currentBalance;

  /// Aggregate watts for ledger display.
  late int totalWatts;

  DateTime? lastPaymentDate;
  double lastPaymentAmount = 0;
}
