import 'package:flutter/foundation.dart';

import '../models/customer.dart';

class CustomerController extends ChangeNotifier {
  final List<Customer> _customers = [
    Customer(id: 'C-001', name: 'Ali Khan', phone: '0300-0000001', totalWatts: 2200, lastPaymentDate: DateTime.now(), lastPaymentAmount: 150),
    Customer(id: 'C-002', name: 'Sara Ahmed', phone: '0300-0000002', totalWatts: 900, lastPaymentDate: DateTime.now().subtract(const Duration(days: 2)), lastPaymentAmount: 0),
  ];

  List<Customer> get customers => List.unmodifiable(_customers);

  Customer? byId(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void addWatts(String customerId, int wattsDelta) {
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index == -1) return;

    final existing = _customers[index];
    _customers[index] = existing.copyWith(totalWatts: existing.totalWatts + wattsDelta);
    notifyListeners();
  }

  void recordPayment(String customerId, double amount) {
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index == -1) return;

    final existing = _customers[index];
    _customers[index] = existing.copyWith(lastPaymentDate: DateTime.now(), lastPaymentAmount: amount);
    notifyListeners();
  }
}
