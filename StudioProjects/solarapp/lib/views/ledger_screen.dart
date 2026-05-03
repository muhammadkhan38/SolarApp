import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/activity_controller.dart';
import '../controllers/contacts_controller.dart';
import '../controllers/transaction_controller.dart';
import '../models/activity_log.dart';
import '../models/isar/contact.dart';
import '../models/isar/solar_transaction.dart';
import '../widgets/app_card.dart';
import '../widgets/app_page.dart';
import '../widgets/app_theme.dart';
import '../widgets/app_spacing.dart';
import '../widgets/formatters.dart';

enum LedgerType { customer, supplier }

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key, required this.type});

  final LedgerType type;

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == LedgerType.customer
        ? 'Customer Ledger'
        : 'Supplier Ledger';

    final parties = _contacts(context);
    final q = _searchController.text.trim().toLowerCase();
    final filtered = parties
        .where((p) {
          if (q.isEmpty) return true;
          return p.code.toLowerCase().contains(q) ||
              p.name.toLowerCase().contains(q) ||
              (p.phone ?? '').toLowerCase().contains(q);
        })
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createContact(context),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: Text(
          widget.type == LedgerType.customer ? 'Add Customer' : 'Add Supplier',
        ),
      ),
      body: AppPage(
        maxWidth: AppBreakpoints.wide,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search by ID, name, phone',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: filtered.isEmpty
                    ? Center(
                        key: const ValueKey('empty'),
                        child: Text(
                          q.isEmpty
                              ? 'No ${widget.type == LedgerType.customer ? 'customers' : 'suppliers'} yet.'
                              : 'No matching records.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        key: const ValueKey('list'),
                        itemCount: filtered.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final p = filtered[index];
                          return _LedgerCard(
                            party: p,
                            type: widget.type,
                            onPayReceiveNow: () {
                              _handlePayment(context, p);
                            },
                            onHistoryOrders: () {
                              _showTransactions(context, p);
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Contact> _contacts(BuildContext context) {
    final contacts = context.watch<ContactsController>();
    return widget.type == LedgerType.customer
        ? contacts.customers
        : contacts.suppliers;
  }

  Future<void> _handlePayment(BuildContext context, Contact contact) async {
    final contactsController = context.read<ContactsController>();
    final activityController = context.read<ActivityController>();
    final messenger = ScaffoldMessenger.of(context);
    final label = widget.type == LedgerType.customer
        ? 'Receive Now'
        : 'Pay Now';

    final controller = TextEditingController(
      text: contact.currentBalance.toStringAsFixed(0),
    );

    final amount = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(label),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Amount'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final v = double.tryParse(controller.text.trim());
                Navigator.of(context).pop(v);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (amount == null) return;
    if (amount <= 0) return;

    await contactsController.recordPayment(
      contactId: contact.id,
      amount: amount,
    );

    if (!mounted) return;
    activityController.add(
      type: ActivityType.payment,
      title: label,
      subtitle: '${contact.name} - ${contact.code}',
    );

    messenger.showSnackBar(SnackBar(content: Text('$label recorded.')));
  }

  Future<void> _createContact(BuildContext context) async {
    final contactsController = context.read<ContactsController>();
    final activityController = context.read<ActivityController>();
    final messenger = ScaffoldMessenger.of(context);
    final isSupplier = widget.type == LedgerType.supplier;
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
      activityController.add(
        type: ActivityType.inventory,
        title: '$label added',
        subtitle: '${created.name} - ${created.code}',
      );

      messenger.showSnackBar(
        SnackBar(content: Text('$label ${created.code} added.')),
      );
    } finally {
      nameController.dispose();
      phoneController.dispose();
    }
  }

  Future<void> _showTransactions(BuildContext context, Contact contact) async {
    final kind = widget.type == LedgerType.customer
        ? TransactionKind.sale
        : TransactionKind.purchase;
    final title = widget.type == LedgerType.customer ? 'History' : 'Orders';
    final records = context.read<TransactionController>().byContactCode(
      contact.code,
      kind: kind,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$title - ${contact.name}'),
          content: SizedBox(
            width: double.maxFinite,
            child: records.isEmpty
                ? const Text('No records yet.')
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: records.length,
                    separatorBuilder: (_, index) => const Divider(height: 18),
                    itemBuilder: (context, index) {
                      final t = records[index];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${t.panelName} - ${formatWatts(t.totalWatts)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${formatTimestamp(t.timestamp)} - Paid ${formatCurrency(t.amountPaid)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          formatCurrency(t.totalAmount),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _LedgerCard extends StatelessWidget {
  const _LedgerCard({
    required this.party,
    required this.type,
    required this.onPayReceiveNow,
    required this.onHistoryOrders,
  });

  final Contact party;
  final LedgerType type;
  final VoidCallback onPayReceiveNow;
  final VoidCallback onHistoryOrders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final label1 = type == LedgerType.customer ? 'Receive Now' : 'Pay Now';
    final label2 = type == LedgerType.customer ? 'History' : 'Orders';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  party.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                party.code,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF667085),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _KeyValue(
                label: 'Total Watts',
                value: formatWatts(party.totalWatts),
              ),
              _KeyValue(
                label: 'Balance',
                value: formatCurrency(party.currentBalance),
              ),
              _KeyValue(
                label: 'Last Payment',
                value: party.lastPaymentDate == null
                    ? 'None'
                    : formatTimestamp(party.lastPaymentDate!),
              ),
              _KeyValue(
                label: 'Amount',
                value: formatCurrency(party.lastPaymentAmount),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: onHistoryOrders,
                  child: Text(label2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: onPayReceiveNow,
                  child: Text(label1),
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
