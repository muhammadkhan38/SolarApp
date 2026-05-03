import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/solar_panel.dart';

class InventoryController extends ChangeNotifier {
  final List<SolarPanel> _panels = [
    const SolarPanel(
      id: 'P-1001',
      panelName: 'Mono Panel A',
      wattsPerPanel: 550,
      quantity: 8,
      pricePerWatt: 0.32,
    ),
    const SolarPanel(
      id: 'P-1002',
      panelName: 'Poly Panel B',
      wattsPerPanel: 450,
      quantity: 3,
      pricePerWatt: 0.28,
    ),
  ];

  List<SolarPanel> get panels => List.unmodifiable(_panels);

  int get totalWatts => _panels.fold(0, (sum, p) => sum + p.totalWatts);

  double get totalInventoryValue =>
      _panels.fold(0, (sum, p) => sum + p.totalValue);

  SolarPanel? byId(String id) {
    try {
      return _panels.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void addPanel({
    required String panelName,
    required int wattsPerPanel,
    required int quantity,
    required double pricePerWatt,
  }) {
    final newId = 'P-${1000 + Random().nextInt(9000)}';
    _panels.insert(
      0,
      SolarPanel(
        id: newId,
        panelName: panelName.trim(),
        wattsPerPanel: wattsPerPanel,
        quantity: quantity,
        pricePerWatt: pricePerWatt,
      ),
    );
    notifyListeners();
  }

  void adjustStock({required String panelId, required int quantityDelta}) {
    final index = _panels.indexWhere((p) => p.id == panelId);
    if (index == -1) return;

    final existing = _panels[index];
    final updatedQty = max(0, existing.quantity + quantityDelta);
    _panels[index] = existing.copyWith(quantity: updatedQty);
    notifyListeners();
  }
}
