import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/activity_controller.dart';
import '../controllers/inventory_controller.dart';
import '../models/activity_log.dart';
import '../models/isar/product.dart';
import '../widgets/app_card.dart';
import '../widgets/app_page.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_theme.dart';
import '../widgets/app_spacing.dart';
import '../widgets/formatters.dart';
import '../widgets/status_badge.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panelNameController = TextEditingController();
  final _wattsController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _panelNameController.dispose();
    _wattsController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= AppBreakpoints.wide;

          final form = AppCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeader(title: 'Add New Item'),
                  TextFormField(
                    controller: _panelNameController,
                    decoration: const InputDecoration(hintText: 'Panel name'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Panel name required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _wattsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Watts'),
                          validator: _validatePositiveInt,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Quantity',
                          ),
                          validator: _validatePositiveInt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Price per Watt',
                    ),
                    validator: _validatePositiveDouble,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final ok = _formKey.currentState?.validate() ?? false;
                        if (!ok) return;

                        final watts = int.parse(_wattsController.text);
                        final qty = int.parse(_quantityController.text);
                        final price = double.parse(_priceController.text);

                        context.read<InventoryController>().addPanel(
                          panelName: _panelNameController.text,
                          wattsPerPanel: watts,
                          quantity: qty,
                          pricePerWatt: price,
                        );

                        context.read<ActivityController>().add(
                          type: ActivityType.inventory,
                          title: 'New item added',
                          subtitle:
                              '${_panelNameController.text.trim()} - +$qty qty',
                        );

                        _panelNameController.clear();
                        _wattsController.clear();
                        _quantityController.clear();
                        _priceController.clear();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Item added.')),
                        );
                      },
                      child: const Text('Add Item'),
                    ),
                  ),
                ],
              ),
            ),
          );

          final list = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader(title: 'Stock List'),
              for (final panel in inventory.panels) ...[
                _StockCard(panel: panel),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          );

          final content = isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: form),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(flex: 6, child: list),
                  ],
                )
              : Column(
                  children: [
                    form,
                    const SizedBox(height: AppSpacing.md),
                    list,
                  ],
                );

          return AppPage(
            scroll: true,
            maxWidth: AppBreakpoints.ultraWide,
            child: content,
          );
        },
      ),
    );
  }

  String? _validatePositiveInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final parsed = int.tryParse(v.trim());
    if (parsed == null) return 'Enter a number';
    if (parsed <= 0) return 'Must be > 0';
    return null;
  }

  String? _validatePositiveDouble(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final parsed = double.tryParse(v.trim());
    if (parsed == null) return 'Enter a number';
    if (parsed <= 0) return 'Must be > 0';
    return null;
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({required this.panel});

  final Product panel;

  @override
  Widget build(BuildContext context) {
    final badge = panel.isLowStock
        ? const StatusBadge(label: 'Low Stock', kind: StatusBadgeKind.danger)
        : const StatusBadge(label: 'In Stock', kind: StatusBadgeKind.success);

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        panel.panelName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    badge,
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _KeyValue(label: 'Watts', value: '${panel.wattsPerPanel}W'),
                    _KeyValue(label: 'Qty', value: panel.quantity.toString()),
                    _KeyValue(
                      label: 'Total Value',
                      value: formatCurrency(panel.totalValue),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: () {
              context.read<InventoryController>().adjustStock(
                productId: panel.id,
                quantityDelta: 1,
              );
              context.read<ActivityController>().add(
                type: ActivityType.inventory,
                title: 'Stock adjusted',
                subtitle: '${panel.panelName} - +1 qty',
              );
            },
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Increase stock',
            color: AppColors.primaryBlue,
          ),
          IconButton(
            onPressed: () {
              context.read<InventoryController>().adjustStock(
                productId: panel.id,
                quantityDelta: -1,
              );
              context.read<ActivityController>().add(
                type: ActivityType.inventory,
                title: 'Stock adjusted',
                subtitle: '${panel.panelName} - -1 qty',
              );
            },
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: 'Decrease stock',
          ),
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
