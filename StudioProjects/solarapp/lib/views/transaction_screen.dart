import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/activity_controller.dart';
import '../controllers/contacts_controller.dart';
import '../controllers/invoice_service.dart';
import '../controllers/inventory_controller.dart';
import '../controllers/transaction_controller.dart';
import '../models/activity_log.dart';
import '../models/isar/product.dart';
import '../models/isar/solar_transaction.dart';
import '../widgets/app_card.dart';
import '../widgets/app_page.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_theme.dart';
import '../widgets/app_spacing.dart';
import '../widgets/formatters.dart';
import '../widgets/status_badge.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key, required this.kind});

  final TransactionKind kind;

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedContactId;
  int? _selectedProductId;

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
    final contacts = context.watch<ContactsController>();

    final isPurchase = widget.kind == TransactionKind.purchase;
    final title = isPurchase ? 'Purchase' : 'Sales';
    final partyLabel = isPurchase ? 'Supplier' : 'Customer';
    final totalCount = tx.totalCountFor(widget.kind);
    final totalAmount = tx.totalAmountFor(widget.kind);

    final partyItems = isPurchase ? contacts.suppliers : contacts.customers;
    final selectedContactId = partyItems.any((p) => p.id == _selectedContactId)
        ? _selectedContactId
        : null;
    final selectedProductId =
        inventory.panels.any((p) => p.id == _selectedProductId)
        ? _selectedProductId
        : null;

    Product? selectedProduct;
    if (selectedProductId != null) {
      for (final p in inventory.panels) {
        if (p.id == selectedProductId) {
          selectedProduct = p;
          break;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= AppBreakpoints.wide;

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
              const SizedBox(width: AppSpacing.xs),
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
                  const AppSectionHeader(title: 'New Entry'),
                  DropdownButtonFormField<int>(
                    // ignore: deprecated_member_use
                    value: selectedContactId,
                    isExpanded: true,
                    items: [
                      for (final p in partyItems)
                        DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            '${p.name} (${p.code})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (v) => setState(() => _selectedContactId = v),
                    decoration: InputDecoration(hintText: 'Select $partyLabel'),
                    validator: (v) => (v == null) ? 'Select one' : null,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _createParty(context),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: Text('Add $partyLabel'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  DropdownButtonFormField<int>(
                    // ignore: deprecated_member_use
                    value: selectedProductId,
                    isExpanded: true,
                    items: [
                      for (final p in inventory.panels)
                        DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            isPurchase
                                ? '${p.panelName} (${p.wattsPerPanel}W)'
                                : '${p.panelName} (${p.wattsPerPanel}W, ${p.quantity} stock)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (v) => setState(() => _selectedProductId = v),
                    decoration: const InputDecoration(hintText: 'Select Panel'),
                    validator: (v) => (v == null) ? 'Select panel' : null,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Quantity',
                          ),
                          validator: (v) =>
                              _validateQuantity(v, selectedProduct),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: selectedProduct == null
                        ? const SizedBox.shrink(key: ValueKey('no-computed'))
                        : Column(
                            key: const ValueKey('computed'),
                            children: [
                              const SizedBox(height: AppSpacing.sm),
                              _ComputedRow(
                                product: selectedProduct,
                                qtyText: _quantityController.text,
                                paidText: _paidController.text,
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final ok = _formKey.currentState?.validate() ?? false;
                        if (!ok) return;
                        if (_selectedContactId == null ||
                            _selectedProductId == null) {
                          return;
                        }
                        if (selectedProduct == null) {
                          _showMessage(context, 'Select a valid panel.');
                          return;
                        }

                        final qty = int.parse(_quantityController.text.trim());
                        final paid = double.parse(_paidController.text.trim());
                        final total =
                            selectedProduct.pricePerWatt *
                            selectedProduct.wattsPerPanel *
                            qty;

                        if (!isPurchase && qty > selectedProduct.quantity) {
                          _showMessage(
                            context,
                            'Only ${selectedProduct.quantity} panels are in stock.',
                          );
                          return;
                        }

                        if (paid > total) {
                          _showMessage(
                            context,
                            'Paid amount cannot be more than total.',
                          );
                          return;
                        }

                        final created = await context
                            .read<TransactionController>()
                            .addTransaction(
                              kind: widget.kind,
                              contactId: _selectedContactId!,
                              productId: _selectedProductId!,
                              quantity: qty,
                              amountPaid: paid,
                            );
                        if (!context.mounted) return;
                        if (created == null) {
                          _showMessage(
                            context,
                            'Could not save. Check stock and payment amount.',
                          );
                          return;
                        }

                        context.read<ActivityController>().add(
                          type: isPurchase
                              ? ActivityType.purchase
                              : ActivityType.sale,
                          title: isPurchase
                              ? 'Purchase recorded'
                              : 'Sale recorded',
                          subtitle:
                              '${created.contactName} - ${formatWatts(created.totalWatts)}',
                        );

                        _quantityController.text = '1';
                        _paidController.text = '0';

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${isPurchase ? 'Purchase' : 'Sale'} saved.',
                            ),
                          ),
                        );

                        // Auto-generate/share invoice after save.
                        try {
                          await InvoiceService.shareInvoice(tx: created);
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Could not share invoice on this platform.',
                              ),
                            ),
                          );
                        }
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
              const AppSectionHeader(title: 'Recent Records'),
              for (final t in tx.byKind(widget.kind).take(12)) ...[
                _TransactionCard(t: t),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          );

          final content = isWide
              ? Column(
                  children: [
                    header,
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: form),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(flex: 6, child: list),
                      ],
                    ),
                  ],
                )
              : Column(
                  children: [
                    header,
                    const SizedBox(height: AppSpacing.sm),
                    form,
                    const SizedBox(height: AppSpacing.sm),
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

  Future<void> _createParty(BuildContext context) async {
    final contactsController = context.read<ContactsController>();
    final messenger = ScaffoldMessenger.of(context);
    final isSupplier = widget.kind == TransactionKind.purchase;
    final label = isSupplier ? 'Supplier' : 'Customer';

    final draft = await showDialog<_PartyDraft>(
      context: context,
      builder: (dialogContext) => _AddPartyDialog(label: label),
    );

    if (draft == null || !mounted) return;

    final created = await contactsController.addContact(
      name: draft.name,
      phone: draft.phone,
      isSupplier: isSupplier,
    );

    if (!mounted) return;
    setState(() => _selectedContactId = created.id);
    messenger.showSnackBar(
      SnackBar(content: Text('$label ${created.code} added.')),
    );
  }

  String? _validatePositiveInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final parsed = int.tryParse(v.trim());
    if (parsed == null) return 'Enter a number';
    if (parsed <= 0) return 'Must be > 0';
    return null;
  }

  String? _validateQuantity(String? v, Product? selectedProduct) {
    final positiveError = _validatePositiveInt(v);
    if (positiveError != null) return positiveError;

    final qty = int.parse(v!.trim());
    if (widget.kind == TransactionKind.sale &&
        selectedProduct != null &&
        qty > selectedProduct.quantity) {
      return 'Only ${selectedProduct.quantity} in stock';
    }

    return null;
  }

  String? _validateNonNegativeDouble(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final parsed = double.tryParse(v.trim());
    if (parsed == null) return 'Enter a number';
    if (parsed < 0) return 'Must be >= 0';
    return null;
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
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

class _PartyDraft {
  const _PartyDraft({required this.name, required this.phone});

  final String name;
  final String phone;
}

class _AddPartyDialog extends StatefulWidget {
  const _AddPartyDialog({required this.label});

  final String label;

  @override
  State<_AddPartyDialog> createState() => _AddPartyDialogState();
}

class _AddPartyDialogState extends State<_AddPartyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${widget.label}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: 'Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name required' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: 'Phone (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final valid = _formKey.currentState?.validate() ?? false;
            if (!valid) return;
            Navigator.of(context).pop(
              _PartyDraft(
                name: _nameController.text,
                phone: _phoneController.text,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ComputedRow extends StatelessWidget {
  const _ComputedRow({
    required this.product,
    required this.qtyText,
    required this.paidText,
  });

  final String qtyText;
  final String paidText;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final qty = int.tryParse(qtyText.trim()) ?? 0;
    final paid = double.tryParse(paidText.trim()) ?? 0;

    final totalWatts = product.wattsPerPanel * qty;
    final totalAmount = product.pricePerWatt * totalWatts;
    final dueRaw = totalAmount - paid;
    final double due = dueRaw < 0 ? 0 : dueRaw;

    return AppCard(
      padding: AppInsets.card,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
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

  final SolarTransaction t;

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
                        t.contactName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    badge,
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${t.panelName} - ${formatWatts(t.totalWatts)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      try {
                        await InvoiceService.shareInvoice(tx: t);
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Could not share invoice on this platform.',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.ios_share, size: 18),
                    label: const Text('Share Invoice'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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
