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
import '../widgets/app_theme.dart';
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
                      decoration: InputDecoration(
                        hintText: 'Select $partyLabel',
                      ),
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
                    const SizedBox(height: 10),
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
                      decoration: const InputDecoration(
                        hintText: 'Select Panel',
                      ),
                      validator: (v) => (v == null) ? 'Select panel' : null,
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
                            validator: (v) =>
                                _validateQuantity(v, selectedProduct),
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
                    if (selectedProduct != null) ...[
                      const SizedBox(height: 12),
                      _ComputedRow(
                        product: selectedProduct,
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

                          final qty = int.parse(
                            _quantityController.text.trim(),
                          );
                          final paid = double.parse(
                            _paidController.text.trim(),
                          );
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
                Text(
                  'Recent Records',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                for (final t in tx.byKind(widget.kind).take(12)) ...[
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

  Future<void> _createParty(BuildContext context) async {
    final contactsController = context.read<ContactsController>();
    final messenger = ScaffoldMessenger.of(context);
    final isSupplier = widget.kind == TransactionKind.purchase;
    final label = isSupplier ? 'Supplier' : 'Customer';
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    try {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text('Add $label'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(hintText: 'Name'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name required'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Phone (optional)',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                onPressed: () {
                  final valid = formKey.currentState?.validate() ?? false;
                  if (!valid) return;
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (shouldSave != true || !mounted) return;

      final created = await contactsController.addContact(
        name: nameController.text,
        phone: phoneController.text,
        isSupplier: isSupplier,
      );

      if (!mounted) return;
      setState(() => _selectedContactId = created.id);
      messenger.showSnackBar(
        SnackBar(content: Text('$label ${created.code} added.')),
      );
    } finally {
      nameController.dispose();
      phoneController.dispose();
    }
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
                    color: const Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 8),
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
