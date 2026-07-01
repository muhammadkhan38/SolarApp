import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: PrinceDriverApp()));
}

class PrinceDriverApp extends ConsumerStatefulWidget {
  const PrinceDriverApp({super.key});

  @override
  ConsumerState<PrinceDriverApp> createState() => _PrinceDriverAppState();
}

class _PrinceDriverAppState extends ConsumerState<PrinceDriverApp> {
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
      title: 'Prince Limousine Driver',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
