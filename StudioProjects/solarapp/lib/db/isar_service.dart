import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/isar/contact.dart';
import '../models/isar/product.dart';
import '../models/isar/solar_transaction.dart';

class IsarService {
  IsarService._();

  static Future<Isar> open() async {
    if (kIsWeb) {
      throw UnsupportedError('Isar is not supported on Web in this app.');
    }

    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [ContactSchema, ProductSchema, SolarTransactionSchema],
      directory: dir.path,
      inspector: true,
    );

    await _removeLegacyDefaultData(isar);
    return isar;
  }

  static Future<void> _removeLegacyDefaultData(Isar isar) async {
    final transactions = await isar.solarTransactions.where().findAll();
    final usedContactCodes = transactions.map((t) => t.contactCode).toSet();
    final usedProductCodes = transactions.map((t) => t.productCode).toSet();

    await isar.writeTxn(() async {
      for (final data in _defaultContacts) {
        if (usedContactCodes.contains(data.code)) continue;

        final contact = await isar.contacts.getByCode(data.code);
        if (contact == null) continue;
        if (contact.name != data.name ||
            contact.phone != data.phone ||
            contact.isSupplier != data.isSupplier) {
          continue;
        }

        await isar.contacts.delete(contact.id);
      }

      for (final data in _defaultProducts) {
        if (usedProductCodes.contains(data.code)) continue;

        final product = await isar.products.getByCode(data.code);
        if (product == null) continue;
        if (product.panelName != data.panelName ||
            product.wattsPerPanel != data.wattsPerPanel ||
            product.quantity != data.quantity ||
            product.pricePerWatt != data.pricePerWatt) {
          continue;
        }

        await isar.products.delete(product.id);
      }
    });
  }

  static const _defaultContacts = [
    _DefaultContact(
      code: 'CUS-001',
      name: 'Ali Khan',
      phone: '0300-0000001',
      isSupplier: false,
    ),
    _DefaultContact(
      code: 'CUS-002',
      name: 'Sara Ahmed',
      phone: '0300-0000002',
      isSupplier: false,
    ),
    _DefaultContact(
      code: 'SUP-001',
      name: 'SunPower Traders',
      phone: '042-0000001',
      isSupplier: true,
    ),
    _DefaultContact(
      code: 'SUP-002',
      name: 'Bright Solar Supplies',
      phone: '042-0000002',
      isSupplier: true,
    ),
  ];

  static const _defaultProducts = [
    _DefaultProduct(
      code: 'P-1001',
      panelName: 'Mono Panel A',
      wattsPerPanel: 550,
      quantity: 8,
      pricePerWatt: 0.32,
    ),
    _DefaultProduct(
      code: 'P-1002',
      panelName: 'Poly Panel B',
      wattsPerPanel: 450,
      quantity: 3,
      pricePerWatt: 0.28,
    ),
  ];
}

class _DefaultContact {
  const _DefaultContact({
    required this.code,
    required this.name,
    required this.phone,
    required this.isSupplier,
  });

  final String code;
  final String name;
  final String phone;
  final bool isSupplier;
}

class _DefaultProduct {
  const _DefaultProduct({
    required this.code,
    required this.panelName,
    required this.wattsPerPanel,
    required this.quantity,
    required this.pricePerWatt,
  });

  final String code;
  final String panelName;
  final int wattsPerPanel;
  final int quantity;
  final double pricePerWatt;
}
