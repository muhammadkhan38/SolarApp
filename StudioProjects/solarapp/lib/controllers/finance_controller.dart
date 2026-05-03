import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../models/isar/contact.dart';

class FinanceController extends ChangeNotifier {
  FinanceController(this._isar) {
    _sub = _isar.contacts.watchLazy(fireImmediately: true).listen((_) {
      _recalc();
    });
    _recalc();
  }

  final Isar _isar;
  late final StreamSubscription<void> _sub;

  double _totalPendingAmount = 0;
  double _totalPayableAmount = 0;

  double get totalPendingAmount => _totalPendingAmount;
  double get totalPayableAmount => _totalPayableAmount;

  Future<void> _recalc() async {
    final contacts = await _isar.contacts.where().findAll();

    _totalPendingAmount = contacts
        .where((c) => !c.isSupplier)
        .fold(0.0, (sum, c) => sum + (c.currentBalance));

    _totalPayableAmount = contacts
        .where((c) => c.isSupplier)
        .fold(0.0, (sum, c) => sum + (c.currentBalance));

    notifyListeners();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
