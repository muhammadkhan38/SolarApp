import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: PrinceCustomerApp()));
}

class PrinceCustomerApp extends ConsumerStatefulWidget {
  const PrinceCustomerApp({super.key});

  @override
  ConsumerState<PrinceCustomerApp> createState() => _PrinceCustomerAppState();
}

class _PrinceCustomerAppState extends ConsumerState<PrinceCustomerApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Prince Limousine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
