import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/activity_controller.dart';
import '../controllers/customer_controller.dart';
import '../controllers/inventory_controller.dart';
import '../controllers/supplier_controller.dart';
import '../controllers/transaction_controller.dart';
import '../models/activity_log.dart';
import '../models/solar_panel.dart';
import '../models/transaction.dart';
import '../widgets/app_card.dart';
import '../widgets/app_theme.dart';
import '../widgets/formatters.dart';
import '../widgets/status_badge.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key, required this.type});

  final TransactionType type;

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedPartyId;
  String? _selectedPanelId;

  final _quantityController = TextEditingController(text: '1');
  final _paidController = TextEditingController(text: '0');

  @override
  void dispose() {
    _quantityController.dispose();
    _paidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryController>();
    final tx = context.watch<TransactionController>();

    final title = widget.type == TransactionType.purchase
        ? 'Purchase'
        : 'Sales';
    final totalCount = tx.totalCountFor(widget.type);
    final totalAmount = tx.totalAmountFor(widget.type);

    final partyItems = widget.type == TransactionType.purchase
        ? context.watch<SupplierController>().suppliers
        : context.watch<CustomerController>().customers;

    final selectedPanel = _selectedPanelId == null
        ? null
        : inventory.byId(_selectedPanelId!);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;

            final header = Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: _HeaderStat(
                      title: 'Total Count',
                      value: totalCount.toString(),
                      icon: Icons.receipt_long_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    child: _HeaderStat(
                      title: 'Total Amount',
                      value: formatCurrency(totalAmount),
                      icon: Icons.payments_outlined,
                      valueColor: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            );

            final form = AppCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Entry',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedPartyId,
                      items: [
                        for (final p in partyItems)
                          DropdownMenuItem(
                            value: p.id,
                            child: Text('${p.name} (${p.id})'),
                          ),
                      ],
                      onChanged: (v) => setState(() => _selectedPartyId = v),
                      decoration: InputDecoration(
                        hintText: widget.type == TransactionType.purchase
                            ? 'Select Supplier'
                            : 'Select Customer',
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Select one' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedPanelId,
                      items: [
                        for (final p in inventory.panels)
                          DropdownMenuItem(
                            value: p.id,
                            child: Text('${p.panelName} (${p.wattsPerPanel}W)'),
                          ),
                      ],
                      onChanged: (v) => setState(() => _selectedPanelId = v),
                      decoration: const InputDecoration(
                        hintText: 'Select Panel',
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Select panel' : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Quantity',
                            ),
                            validator: _validatePositiveInt,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _paidController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Paid amount',
                            ),
                            validator: _validateNonNegativeDouble,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    if (selectedPanel != null) ...[
                      const SizedBox(height: 12),
                      _ComputedRow(
                        panel: selectedPanel,
                        qtyText: _quantityController.text,
                        paidText: _paidController.text,
                      ),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 46,
                      width: double.infinity,
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
                          final panel = inventory.byId(_selectedPanelId!);
                          if (panel == null) return;

                          final qty = int.parse(
                            _quantityController.text.trim(),
                          );
                          final paid = double.parse(
                            _paidController.text.trim(),
                          );
                          final party = partyItems.firstWhere(
                            (p) => p.id == _selectedPartyId,
                          );

                          context.read<TransactionController>().addTransaction(
                            type: widget.type,
                            partyId: party.id,
                            partyName: party.name,
                            panelId: panel.id,
                            panelName: panel.panelName,
                            wattsPerPanel: panel.wattsPerPanel,
                            quantity: qty,
                            pricePerWatt: panel.pricePerWatt,
                            paidAmount: paid,
                          );

                          // Update inventory + ledgers.
                          final stockDelta =
                              widget.type == TransactionType.purchase
                              ? qty
                              : -qty;
                          context.read<InventoryController>().adjustStock(
                            panelId: panel.id,
                            quantityDelta: stockDelta,
                          );

                          final wattsDelta = panel.wattsPerPanel * qty;
                          if (widget.type == TransactionType.purchase) {
                            context.read<SupplierController>().addWatts(
                              party.id,
                              wattsDelta,
                            );
                          } else {
                            context.read<CustomerController>().addWatts(
                              party.id,
                              wattsDelta,
                            );
                          }

                          context.read<ActivityController>().add(
                            type: widget.type == TransactionType.purchase
                                ? ActivityType.purchase
                                : ActivityType.sale,
                            title: widget.type == TransactionType.purchase
                                ? 'Purchase recorded'
                                : 'Sale recorded',
                            subtitle:
                                '${party.name} · ${formatWatts(wattsDelta)}',
                          );

                          _quantityController.text = '1';
                          _paidController.text = '0';

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${widget.type == TransactionType.purchase ? 'Purchase' : 'Sale'} saved.',
                              ),
                            ),
                          );
                        },
                        child: const Text('Save'),
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
                  'Recent Records',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                for (final t in tx.byType(widget.type).take(12)) ...[
                  _TransactionCard(t: t),
                  const SizedBox(height: 10),
                ],
              ],
            );

            if (isWide) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    header,
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: form),
                        const SizedBox(width: 14),
                        Expanded(flex: 6, child: list),
                      ],
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  header,
                  const SizedBox(height: 14),
                  form,
                  const SizedBox(height: 14),
                  list,
                ],
              ),
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

  String? _validateNonNegativeDouble(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final parsed = double.tryParse(v.trim());
    if (parsed == null) return 'Enter a number';
    if (parsed < 0) return 'Must be >= 0';
    return null;
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.title,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
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
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF667085),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComputedRow extends StatelessWidget {
  const _ComputedRow({
    required this.panel,
    required this.qtyText,
    required this.paidText,
  });

  final String qtyText;
  final String paidText;
  final SolarPanel panel;

  @override
  Widget build(BuildContext context) {
    final qty = int.tryParse(qtyText.trim()) ?? 0;
    final paid = double.tryParse(paidText.trim()) ?? 0;

    final totalWatts = panel.wattsPerPanel * qty;
    final totalAmount = panel.pricePerWatt * totalWatts;
    final dueRaw = totalAmount - paid;
    final double due = dueRaw < 0 ? 0 : dueRaw;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 18,
        runSpacing: 8,
        children: [
          _KeyValue(label: 'Watts', value: formatWatts(totalWatts)),
          _KeyValue(label: 'Total', value: formatCurrency(totalAmount)),
          _KeyValue(label: 'Due', value: formatCurrency(due)),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.t});

  final Transaction t;

  @override
  Widget build(BuildContext context) {
    final badge = switch (t.paymentStatus) {
      PaymentStatus.paid => const StatusBadge(
        label: 'Paid',
        kind: StatusBadgeKind.success,
      ),
      PaymentStatus.partial => const StatusBadge(
        label: 'Partial',
        kind: StatusBadgeKind.neutral,
      ),
      PaymentStatus.due => const StatusBadge(
        label: 'Due',
        kind: StatusBadgeKind.danger,
      ),
    };

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.partyName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    badge,
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${t.panelName} · ${formatWatts(t.totalWatts)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(t.totalAmount),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                formatTimestamp(t.timestamp),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF667085)),
              ),
            ],
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
