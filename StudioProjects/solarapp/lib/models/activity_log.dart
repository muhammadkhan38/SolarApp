import 'package:flutter/foundation.dart';

enum ActivityType { inventory, purchase, sale, payment }

@immutable
class ActivityLog {
  const ActivityLog({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  final String id;
  final ActivityType type;
  final String title;
  final String subtitle;
  final DateTime timestamp;
}
