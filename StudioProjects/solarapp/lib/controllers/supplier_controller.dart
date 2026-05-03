import 'package:flutter/foundation.dart';

import '../models/supplier.dart';

class SupplierController extends ChangeNotifier {
  final List<Supplier> _suppliers = [];

  List<Supplier> get suppliers => List.unmodifiable(_suppliers);

  Supplier? byId(String id) {
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  void addWatts(String supplierId, int wattsDelta) {
    final index = _suppliers.indexWhere((s) => s.id == supplierId);
    if (index == -1) return;

    final existing = _suppliers[index];
    _suppliers[index] = existing.copyWith(
      totalWatts: existing.totalWatts + wattsDelta,
    );
    notifyListeners();
  }

  void recordPayment(String supplierId, double amount) {
    final index = _suppliers.indexWhere((s) => s.id == supplierId);
    if (index == -1) return;

    final existing = _suppliers[index];
    _suppliers[index] = existing.copyWith(
      lastPaymentDate: DateTime.now(),
      lastPaymentAmount: amount,
    );
    notifyListeners();
  }
}
