import 'package:flutter/material.dart';

import 'app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.kind});

  final String label;
  final StatusBadgeKind kind;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      StatusBadgeKind.success => (
        AppColors.success.withValues(alpha: 0.12),
        AppColors.success,
      ),
      StatusBadgeKind.danger => (
        AppColors.danger.withValues(alpha: 0.12),
        AppColors.danger,
      ),
      StatusBadgeKind.neutral => (
        const Color(0xFFEFF1F5),
        const Color(0xFF4B5563),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

enum StatusBadgeKind { success, danger, neutral }
