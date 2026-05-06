import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';

import 'db/isar_service.dart';
import 'controllers/activity_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/contacts_controller.dart';
import 'controllers/finance_controller.dart';
import 'controllers/inventory_controller.dart';
import 'controllers/transaction_controller.dart';
import 'views/dashboard_screen.dart';
import 'views/inventory_screen.dart';
import 'views/ledger_screen.dart';
import 'views/login_screen.dart';
import 'views/purchase_screen.dart';
import 'views/routes.dart';
import 'views/sales_screen.dart';
import 'widgets/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isar = await IsarService.open();
  runApp(SolarInventoryApp(isar: isar));
}

class SolarInventoryApp extends StatelessWidget {
  const SolarInventoryApp({super.key, required this.isar});

  final Isar isar;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Isar>.value(value: isar),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => InventoryController(isar)),
        ChangeNotifierProvider(create: (_) => TransactionController(isar)),
        ChangeNotifierProvider(create: (_) => ContactsController(isar)),
        ChangeNotifierProvider(create: (_) => FinanceController(isar)),
        ChangeNotifierProvider(create: (_) => ActivityController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Solar Inventory',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
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
