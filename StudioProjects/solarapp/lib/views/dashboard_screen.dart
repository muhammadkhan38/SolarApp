import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/activity_controller.dart';
import '../controllers/inventory_controller.dart';
import '../controllers/transaction_controller.dart';
import '../models/activity_log.dart';
import '../models/transaction.dart';
import '../widgets/app_card.dart';
import '../widgets/formatters.dart';
import '../widgets/summary_card.dart';
import '../widgets/app_theme.dart';
import 'routes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryController>();
    final transactions = context.watch<TransactionController>();
    final activity = context.watch<ActivityController>();

    final logsToShow = activity.logs.take(8).toList(growable: false);

    final todaySalesAmount = transactions
        .byType(TransactionType.sale)
        .where((t) {
          final now = DateTime.now();
          return t.timestamp.year == now.year &&
              t.timestamp.month == now.month &&
              t.timestamp.day == now.day;
        })
        .fold<double>(0, (sum, t) => sum + t.totalAmount);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isWide = width >= 900;
            final columns = isWide ? 3 : 2;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isWide ? 2.7 : 2.4,
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
                      if (isWide)
                        SummaryCard(
                          title: 'Inventory Value',
                          value: formatCurrency(inventory.totalInventoryValue),
                          icon: Icons.inventory_2_outlined,
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _QuickActionsGrid(
                    isWide: isWide,
                    onTap: (route) => Navigator.of(context).pushNamed(route),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppCard(
                    child: Column(
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
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.isWide, required this.onTap});

  final bool isWide;
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

    final crossAxisCount = isWide ? 5 : 2;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isWide ? 1.2 : 2.6,
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
                        const SizedBox(height: 10),
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                log.title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                log.subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF667085)),
              ),
            ],
          ),
        ),
        Text(
          formatTimestamp(log.timestamp),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: const Color(0xFF667085)),
        ),
      ],
    );
  }
}
