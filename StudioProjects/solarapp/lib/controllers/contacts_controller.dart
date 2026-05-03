import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../models/isar/contact.dart';

class ContactsController extends ChangeNotifier {
  ContactsController(this._isar) {
    _sub = _isar.contacts.watchLazy(fireImmediately: true).listen((_) {
      _load();
    });
    _load();
  }

  final Isar _isar;
  late final StreamSubscription<void> _sub;

  List<Contact> _contacts = const [];

  List<Contact> get all => List.unmodifiable(_contacts);

  List<Contact> get customers =>
      _contacts.where((c) => !c.isSupplier).toList(growable: false);

  List<Contact> get suppliers =>
      _contacts.where((c) => c.isSupplier).toList(growable: false);

  Contact? byCode(String code) {
    try {
      return _contacts.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  Future<void> _load() async {
    _contacts = await _isar.contacts.where().sortByCode().findAll();
    notifyListeners();
  }

  Future<Contact> addContact({
    required String name,
    required String? phone,
    required bool isSupplier,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Name is required');
    }

    final cleanPhone = phone?.trim();
    Contact? created;

    await _isar.writeTxn(() async {
      final prefix = isSupplier ? 'SUP' : 'CUS';
      final existing = await _isar.contacts.where().findAll();
      var maxNumber = 0;

      for (final contact in existing.where((c) => c.isSupplier == isSupplier)) {
        final parts = contact.code.split('-');
        if (parts.length != 2 || parts.first != prefix) continue;

        final parsed = int.tryParse(parts.last);
        if (parsed != null && parsed > maxNumber) {
          maxNumber = parsed;
        }
      }

      final contact = Contact()
        ..code = '$prefix-${(maxNumber + 1).toString().padLeft(3, '0')}'
        ..name = cleanName
        ..phone = cleanPhone == null || cleanPhone.isEmpty ? null : cleanPhone
        ..isSupplier = isSupplier
        ..currentBalance = 0
        ..totalWatts = 0
        ..lastPaymentAmount = 0;

      await _isar.contacts.put(contact);
      created = contact;
    });

    await _load();
    return created!;
  }

  /// Receive/Pay reduces the current balance and records last payment metadata.
  Future<void> recordPayment({
    required int contactId,
    required double amount,
  }) async {
    if (amount <= 0) return;

    await _isar.writeTxn(() async {
      final contact = await _isar.contacts.get(contactId);
      if (contact == null) return;

      final newBalance = (contact.currentBalance - amount);
      contact.currentBalance = newBalance < 0 ? 0 : newBalance;
      contact.lastPaymentDate = DateTime.now();
      contact.lastPaymentAmount = amount;

      await _isar.contacts.put(contact);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
