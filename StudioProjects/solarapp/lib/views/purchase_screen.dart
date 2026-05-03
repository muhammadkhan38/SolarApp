import 'package:flutter/material.dart';

import '../models/transaction.dart';
import 'transaction_screen.dart';

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransactionScreen(type: TransactionType.purchase);
  }
}
