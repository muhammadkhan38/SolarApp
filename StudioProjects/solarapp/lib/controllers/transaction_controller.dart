import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/transaction.dart';

class TransactionController extends ChangeNotifier {
  final List<Transaction> _transactions = [
    Transaction(
      id: 'T-2001',
      type: TransactionType.sale,
      partyId: 'C-001',
      partyName: 'Ali Khan',
      panelId: 'P-1001',
      panelName: 'Mono Panel A',
      wattsPerPanel: 550,
      quantity: 4,
      pricePerWatt: 0.32,
      paidAmount: 500,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Transaction(
      id: 'T-2002',
      type: TransactionType.purchase,
      partyId: 'S-001',
      partyName: 'SunPower Traders',
      panelId: 'P-1002',
      panelName: 'Poly Panel B',
      wattsPerPanel: 450,
      quantity: 10,
      pricePerWatt: 0.28,
      paidAmount: 0,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  List<Transaction> byType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList(growable: false);
  }

  int get totalCount => _transactions.length;

  double get totalAmount =>
      _transactions.fold(0, (sum, t) => sum + t.totalAmount);

  int totalCountFor(TransactionType type) =>
      _transactions.where((t) => t.type == type).length;

  double totalAmountFor(TransactionType type) => _transactions
      .where((t) => t.type == type)
      .fold(0, (sum, t) => sum + t.totalAmount);

  void addTransaction({
    required TransactionType type,
    required String partyId,
    required String partyName,
    required String panelId,
    required String panelName,
    required int wattsPerPanel,
    required int quantity,
    required double pricePerWatt,
    required double paidAmount,
  }) {
    final newId = 'T-${2000 + Random().nextInt(8000)}';
    _transactions.insert(
      0,
      Transaction(
        id: newId,
        type: type,
        partyId: partyId,
        partyName: partyName,
        panelId: panelId,
        panelName: panelName,
        wattsPerPanel: wattsPerPanel,
        quantity: quantity,
        pricePerWatt: pricePerWatt,
        paidAmount: paidAmount,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
