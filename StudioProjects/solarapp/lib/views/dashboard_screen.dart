import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/activity_controller.dart';
import '../controllers/finance_controller.dart';
import '../controllers/inventory_controller.dart';
import '../controllers/transaction_controller.dart';
import '../models/activity_log.dart';
import '../models/isar/solar_transaction.dart';
import '../widgets/app_card.dart';
import '../widgets/formatters.dart';
import '../widgets/summary_card.dart';
import '../widgets/app_theme.dart';
import '../widgets/app_page.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_states.dart';
import '../widgets/app_spacing.dart';
import 'routes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryController>();
    final transactions = context.watch<TransactionController>();
    final finance = context.watch<FinanceController>();
    final activity = context.watch<ActivityController>();

    final logsToShow = activity.logs.take(8).toList(growable: false);

    final todaySalesAmount = transactions
        .byKind(TransactionKind.sale)
        .where((t) {
          final now = DateTime.now();
          return t.timestamp.year == now.year &&
              t.timestamp.month == now.month &&
              t.timestamp.day == now.day;
        })
        .fold<double>(0, (sum, t) => sum + t.totalAmount);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isWide = width >= 900;
          final summaryColumns = width >= 720
              ? 3
              : width >= 520
              ? 2
              : 1;
          final summaryAspectRatio = summaryColumns == 1
              ? 3.2
              : isWide
              ? 2.7
              : 2.15;

          return AppPage(
            scroll: true,
            maxWidth: AppBreakpoints.ultraWide,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  crossAxisCount: summaryColumns,
                  mainAxisSpacing: AppSpacing.xs,
                  crossAxisSpacing: AppSpacing.xs,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: summaryAspectRatio,
                  children: [
                    SummaryCard(
                      title: 'Total Watts',
                      value: formatWatts(inventory.totalWatts),
                      icon: Icons.solar_power,
                    ),
                    SummaryCard(
                      title: "Today's Sales",
                      value: formatCurrency(todaySalesAmount),
                      icon: Icons.trending_up,
                      valueColor: AppColors.success,
                    ),
                    SummaryCard(
                      title: 'Total Pending Amount',
                      value: formatCurrency(finance.totalPendingAmount),
                      icon: Icons.account_balance_wallet_outlined,
                      valueColor: AppColors.danger,
                    ),
                    SummaryCard(
                      title: 'Total Payable Amount',
                      value: formatCurrency(finance.totalPayableAmount),
                      icon: Icons.payments_outlined,
                      valueColor: AppColors.danger,
                    ),
                    if (summaryColumns == 3)
                      SummaryCard(
                        title: 'Inventory Value',
                        value: formatCurrency(inventory.totalInventoryValue),
                        icon: Icons.inventory_2_outlined,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const AppSectionHeader(title: 'Quick Actions'),
                _QuickActionsGrid(
                  width: width,
                  onTap: (route) => Navigator.of(context).pushNamed(route),
                ),
                const SizedBox(height: AppSpacing.lg),
                const AppSectionHeader(title: 'Recent Activity'),
                AppCard(
                  child: logsToShow.isEmpty
                      ? const AppEmptyState(
                          title: 'No recent activity',
                          message:
                              'New inventory updates, sales, and payments will show up here.',
                          icon: Icons.history,
                        )
                      : Column(
                          children: [
                            for (var i = 0; i < logsToShow.length; i++) ...[
                              _ActivityRow(log: logsToShow[i]),
                              if (i != logsToShow.length - 1)
                                const Divider(height: 18),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.width, required this.onTap});

  final double width;
  final void Function(String route) onTap;

  @override
  Widget build(BuildContext context) {
    final items = <_QuickActionItem>[
      const _QuickActionItem(
        'Inventory',
        Icons.inventory_2_outlined,
        AppRoutes.inventory,
      ),
      const _QuickActionItem(
        'Purchase',
        Icons.shopping_cart_outlined,
        AppRoutes.purchase,
      ),
      const _QuickActionItem(
        'Sales',
        Icons.point_of_sale_outlined,
        AppRoutes.sales,
      ),
      const _QuickActionItem(
        'Customer Ledger',
        Icons.people_outline,
        AppRoutes.customerLedger,
      ),
      const _QuickActionItem(
        'Supplier Ledger',
        Icons.store_mall_directory_outlined,
        AppRoutes.supplierLedger,
      ),
    ];

    final isWide = width >= 900;
    final crossAxisCount = isWide
        ? 5
        : width >= 620
        ? 3
        : width >= 420
        ? 2
        : 1;
    final aspectRatio = isWide
        ? 1.2
        : crossAxisCount == 1
        ? 4.2
        : 2.6;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: AppSpacing.xs,
      crossAxisSpacing: AppSpacing.xs,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: aspectRatio,
      children: [
        for (final item in items)
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onTap(item.route),
            child: AppCard(
              child: isWide
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, color: AppColors.primaryBlue),
                        const SizedBox(height: AppSpacing.xs),
                        Text(item.title, textAlign: TextAlign.center),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item.icon, color: AppColors.primaryBlue),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
            ),
          ),
      ],
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem(this.title, this.icon, this.route);

  final String title;
  final IconData icon;
  final String route;
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.log});

  final ActivityLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final icon = switch (log.type) {
      ActivityType.inventory => Icons.inventory_2_outlined,
      ActivityType.purchase => Icons.shopping_cart_outlined,
      ActivityType.sale => Icons.point_of_sale_outlined,
      ActivityType.payment => Icons.payments_outlined,
    };

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                log.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                log.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatTimestamp(log.timestamp),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
      ],
    );
  }
}
