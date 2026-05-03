import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../models/isar/product.dart';

class InventoryController extends ChangeNotifier {
  InventoryController(this._isar) {
    _sub = _isar.products.watchLazy(fireImmediately: true).listen((_) {
      _load();
    });
    _load();
  }

  final Isar _isar;
  late final StreamSubscription<void> _sub;

  List<Product> _products = const [];
  List<Product> get panels => List.unmodifiable(_products);

  int get totalWatts => _products.fold(0, (sum, p) => sum + p.totalWatts);

  double get totalInventoryValue =>
      _products.fold(0, (sum, p) => sum + p.totalValue);

  Product? byCode(String code) {
    try {
      return _products.firstWhere((p) => p.code == code);
    } catch (_) {
      return null;
    }
  }

  Future<void> _load() async {
    _products = await _isar.products.where().sortByCode().findAll();
    notifyListeners();
  }

  Future<void> addPanel({
    required String panelName,
    required int wattsPerPanel,
    required int quantity,
    required double pricePerWatt,
  }) async {
    await _isar.writeTxn(() async {
      final code = 'P-${DateTime.now().millisecondsSinceEpoch % 100000}';
      final p = Product()
        ..code = code
        ..panelName = panelName.trim()
        ..wattsPerPanel = wattsPerPanel
        ..quantity = quantity
        ..pricePerWatt = pricePerWatt;

      await _isar.products.put(p);
    });
  }

  Future<void> adjustStock({
    required int productId,
    required int quantityDelta,
  }) async {
    await _isar.writeTxn(() async {
      final p = await _isar.products.get(productId);
      if (p == null) return;
      final updated = p.quantity + quantityDelta;
      p.quantity = updated < 0 ? 0 : updated;
      await _isar.products.put(p);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
