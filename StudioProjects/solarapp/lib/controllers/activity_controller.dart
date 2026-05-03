import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/activity_log.dart';

class ActivityController extends ChangeNotifier {
  final List<ActivityLog> _logs = [
    ActivityLog(
      id: 'A-1001',
      type: ActivityType.sale,
      title: 'Sale recorded',
      subtitle: 'Ali Khan · 2,200W',
      timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
    ),
    ActivityLog(
      id: 'A-1002',
      type: ActivityType.inventory,
      title: 'Inventory updated',
      subtitle: 'Mono Panel A · +8 qty',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  List<ActivityLog> get logs => List.unmodifiable(_logs);

  void add({
    required ActivityType type,
    required String title,
    required String subtitle,
  }) {
    final newId = 'A-${1000 + Random().nextInt(9000)}';
    _logs.insert(
      0,
      ActivityLog(
        id: newId,
        type: type,
        title: title,
        subtitle: subtitle,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
