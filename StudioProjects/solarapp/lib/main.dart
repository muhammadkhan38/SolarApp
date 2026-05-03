import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/activity_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/customer_controller.dart';
import 'controllers/inventory_controller.dart';
import 'controllers/supplier_controller.dart';
import 'controllers/transaction_controller.dart';
import 'views/dashboard_screen.dart';
import 'views/inventory_screen.dart';
import 'views/ledger_screen.dart';
import 'views/login_screen.dart';
import 'views/purchase_screen.dart';
import 'views/routes.dart';
import 'views/sales_screen.dart';
import 'widgets/app_theme.dart';

void main() {
  runApp(const SolarInventoryApp());
}

class SolarInventoryApp extends StatelessWidget {
  const SolarInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => InventoryController()),
        ChangeNotifierProvider(create: (_) => TransactionController()),
        ChangeNotifierProvider(create: (_) => CustomerController()),
        ChangeNotifierProvider(create: (_) => SupplierController()),
        ChangeNotifierProvider(create: (_) => ActivityController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Solar Inventory',
        theme: AppTheme.light(),
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.dashboard: (_) => const DashboardScreen(),
          AppRoutes.inventory: (_) => const InventoryScreen(),
          AppRoutes.purchase: (_) => const PurchaseScreen(),
          AppRoutes.sales: (_) => const SalesScreen(),
          AppRoutes.customerLedger: (_) =>
              const LedgerScreen(type: LedgerType.customer),
          AppRoutes.supplierLedger: (_) =>
              const LedgerScreen(type: LedgerType.supplier),
        },
      ),
    );
  }
}
