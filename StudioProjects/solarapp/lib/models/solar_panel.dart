import 'package:flutter/foundation.dart';

@immutable
class SolarPanel {
  const SolarPanel({
    required this.id,
    required this.panelName,
    required this.wattsPerPanel,
    required this.quantity,
    required this.pricePerWatt,
  });

  final String id;
  final String panelName;
  final int wattsPerPanel;
  final int quantity;
  final double pricePerWatt;

  int get totalWatts => wattsPerPanel * quantity;

  double get totalValue => pricePerWatt * totalWatts;

  bool get isLowStock => quantity <= 5;

  SolarPanel copyWith({
    String? id,
    String? panelName,
    int? wattsPerPanel,
    int? quantity,
    double? pricePerWatt,
  }) {
    return SolarPanel(
      id: id ?? this.id,
      panelName: panelName ?? this.panelName,
      wattsPerPanel: wattsPerPanel ?? this.wattsPerPanel,
      quantity: quantity ?? this.quantity,
      pricePerWatt: pricePerWatt ?? this.pricePerWatt,
    );
  }
}
