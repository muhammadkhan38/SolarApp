import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/activity_log.dart';

class ActivityController extends ChangeNotifier {
  final List<ActivityLog> _logs = [];

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
