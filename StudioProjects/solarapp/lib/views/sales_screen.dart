import 'package:flutter/material.dart';

import '../models/transaction.dart';
import 'transaction_screen.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransactionScreen(type: TransactionType.sale);
  }
}
