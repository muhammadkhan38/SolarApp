import 'package:flutter/foundation.dart';

import '../models/supplier.dart';

class SupplierController extends ChangeNotifier {
  final List<Supplier> _suppliers = [
    Supplier(
      id: 'S-001',
      name: 'SunPower Traders',
      phone: '042-0000001',
      totalWatts: 6000,
      lastPaymentDate: DateTime.now().subtract(const Duration(days: 1)),
      lastPaymentAmount: 500,
    ),
    Supplier(
      id: 'S-002',
      name: 'Bright Solar Supplies',
      phone: '042-0000002',
      totalWatts: 1800,
      lastPaymentDate: DateTime.now().subtract(const Duration(days: 5)),
      lastPaymentAmount: 0,
    ),
  ];

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
