import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/activity_controller.dart';
import '../controllers/customer_controller.dart';
import '../controllers/supplier_controller.dart';
import '../models/activity_log.dart';
import '../models/party.dart';
import '../widgets/app_card.dart';
import '../widgets/app_theme.dart';
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

    final parties = _parties(context);
    final q = _searchController.text.trim().toLowerCase();
    final filtered = parties
        .where((p) {
          if (q.isEmpty) return true;
          return p.id.toLowerCase().contains(q) ||
              p.name.toLowerCase().contains(q) ||
              (p.phone ?? '').toLowerCase().contains(q);
        })
        .toList(growable: false);

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
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final p = filtered[index];
                    return _LedgerCard(
                      party: p,
                      type: widget.type,
                      onPayReceiveNow: () {
                        final label = widget.type == LedgerType.customer
                            ? 'Receive Now'
                            : 'Pay Now';
                        context.read<ActivityController>().add(
                          type: ActivityType.payment,
                          title: label,
                          subtitle: '${p.name} · ${p.id}',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$label tapped for ${p.name}.'),
                          ),
                        );
                      },
                      onHistoryOrders: () {
                        final label = widget.type == LedgerType.customer
                            ? 'History'
                            : 'Orders';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$label tapped for ${p.name}.'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Party> _parties(BuildContext context) {
    if (widget.type == LedgerType.customer) {
      final list = context.watch<CustomerController>().customers;
      return list.cast<Party>();
    }
    final list = context.watch<SupplierController>().suppliers;
    return list.cast<Party>();
  }
}

class _LedgerCard extends StatelessWidget {
  const _LedgerCard({
    required this.party,
    required this.type,
    required this.onPayReceiveNow,
    required this.onHistoryOrders,
  });

  final Party party;
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
                party.id,
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
                label: 'Last Payment',
                value: party.lastPaymentDate == null
                    ? '—'
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
