import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../models/isar/contact.dart';
import '../models/isar/product.dart';
import '../models/isar/solar_transaction.dart';

class TransactionController extends ChangeNotifier {
  TransactionController(this._isar) {
    _sub = _isar.solarTransactions.watchLazy(fireImmediately: true).listen((_) {
      _load();
    });
    _load();
  }

  final Isar _isar;
  late final StreamSubscription<void> _sub;

  List<SolarTransaction> _transactions = const [];
  List<SolarTransaction> get transactions => List.unmodifiable(_transactions);

  List<SolarTransaction> byKind(TransactionKind kind) {
    return _transactions.where((t) => t.kind == kind).toList(growable: false);
  }

  List<SolarTransaction> byContactCode(
    String contactCode, {
    TransactionKind? kind,
  }) {
    return _transactions
        .where((t) => t.contactCode == contactCode)
        .where((t) => kind == null || t.kind == kind)
        .toList(growable: false);
  }

  int totalCountFor(TransactionKind kind) =>
      _transactions.where((t) => t.kind == kind).length;

  double totalAmountFor(TransactionKind kind) => _transactions
      .where((t) => t.kind == kind)
      .fold(0.0, (sum, t) => sum + t.totalAmount);

  Future<void> _load() async {
    _transactions = await _isar.solarTransactions
        .where()
        .sortByTimestampDesc()
        .findAll();
    notifyListeners();
  }

  /// Saves a sale/purchase, updates stock, and applies debit/credit balance.
  ///
  /// Formula: NewBalance = OldBalance + (TotalAmount - AmountPaid)
  Future<SolarTransaction?> addTransaction({
    required TransactionKind kind,
    required int contactId,
    required int productId,
    required int quantity,
    required double amountPaid,
  }) async {
    if (quantity <= 0 || amountPaid < 0) return null;

    final now = DateTime.now();
    final txCode = 'TX-${now.millisecondsSinceEpoch % 1000000}';

    SolarTransaction? created;

    await _isar.writeTxn(() async {
      final contact = await _isar.contacts.get(contactId);
      final product = await _isar.products.get(productId);
      if (contact == null || product == null) return;

      final wattsPerPanel = product.wattsPerPanel;
      final pricePerWatt = product.pricePerWatt;
      final totalWatts = wattsPerPanel * quantity;
      final totalAmount = pricePerWatt * totalWatts;
      if (kind == TransactionKind.sale && quantity > product.quantity) return;
      if (amountPaid > totalAmount) return;

      final remaining = (totalAmount - amountPaid);
      final remainingBalance = remaining < 0 ? 0.0 : remaining;

      // Update balance.
      contact.currentBalance = contact.currentBalance + remainingBalance;

      // Aggregate watts.
      contact.totalWatts = contact.totalWatts + totalWatts;

      // If user paid anything now, store in last payment metadata.
      if (amountPaid > 0) {
        contact.lastPaymentDate = now;
        contact.lastPaymentAmount = amountPaid;
      }

      await _isar.contacts.put(contact);

      // Update stock.
      final stockDelta = kind == TransactionKind.purchase
          ? quantity
          : -quantity;
      final updatedQty = product.quantity + stockDelta;
      product.quantity = updatedQty < 0 ? 0 : updatedQty;
      await _isar.products.put(product);

      // Persist transaction.
      final t = SolarTransaction()
        ..code = txCode
        ..timestamp = now
        ..kind = kind
        ..contactCode = contact.code
        ..contactName = contact.name
        ..contactPhone = contact.phone
        ..productCode = product.code
        ..panelName = product.panelName
        ..wattsPerPanel = wattsPerPanel
        ..quantity = quantity
        ..pricePerWatt = pricePerWatt
        ..totalAmount = totalAmount
        ..amountPaid = amountPaid
        ..remainingBalance = remainingBalance;

      t.contact.value = contact;
      t.product.value = product;

      await _isar.solarTransactions.put(t);
      await t.contact.save();
      await t.product.save();
      created = t;
    });

    return created;
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
