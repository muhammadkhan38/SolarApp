import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../widgets/app_page.dart';
import '../widgets/app_spacing.dart';
import 'routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      body: AppPage(
        scroll: true,
        maxWidth: AppBreakpoints.narrow,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Login to manage inventory, purchases and sales.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  autofillHints: const [AutofillHints.username],
                  decoration: const InputDecoration(
                    hintText: 'Username or Phone',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter username or phone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _passwordController,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _obscure ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter password';
                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(auth),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Checkbox(
                      value: auth.rememberMe,
                      onChanged: (v) => auth.setRememberMe(v ?? false),
                    ),
                    const Text('Remember me'),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _submit(auth),
                    child: const Text('Contact Administrator'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(AuthController auth) async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final ok = await auth.login(
      usernameOrPhone: _usernameController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Invalid login details.')));
  }
}
