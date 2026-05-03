import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/activity_controller.dart';
import '../controllers/inventory_controller.dart';
import '../models/activity_log.dart';
import '../models/isar/product.dart';
import '../widgets/app_card.dart';
import '../widgets/app_theme.dart';
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
      appBar: AppBar(
        title: Text(
          'Inventory',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;

            final form = AppCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Item',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _panelNameController,
                      decoration: const InputDecoration(hintText: 'Panel name'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Panel name required'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _wattsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Watts',
                            ),
                            validator: _validatePositiveInt,
                          ),
                        ),
                        const SizedBox(width: 10),
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
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
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
                Text(
                  'Stock List',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                for (final panel in inventory.panels) ...[
                  _StockCard(panel: panel),
                  const SizedBox(height: 10),
                ],
              ],
            );

            if (isWide) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: form),
                    const SizedBox(width: 14),
                    Expanded(flex: 6, child: list),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [form, const SizedBox(height: 14), list]),
            );
          },
        ),
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
                const SizedBox(height: 8),
                Wrap(
                  spacing: 18,
                  runSpacing: 8,
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
          const SizedBox(width: 8),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: const Color(0xFF667085)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
