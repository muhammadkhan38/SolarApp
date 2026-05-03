import 'package:isar/isar.dart';

part 'product.g.dart';

@collection
class Product {
  Product();

  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String code;

  late String panelName;
  late int wattsPerPanel;
  late int quantity;
  late double pricePerWatt;

  int get totalWatts => wattsPerPanel * quantity;

  double get totalValue => pricePerWatt * totalWatts;

  bool get isLowStock => quantity <= 5;
}
