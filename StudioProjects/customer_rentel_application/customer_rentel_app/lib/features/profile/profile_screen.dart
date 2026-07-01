import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../shared/main_nav.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _editing = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _startEditing() {
    final customer = ref.read(authControllerProvider).customer;
    if (customer == null) return;
    setState(() {
      _name.text = customer.name;
      _phone.text = customer.phone ?? '';
      _editing = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .updateProfile(name: _name.text.trim(), phone: _phone.text.trim());
    if (!mounted) return;
    if (ok) {
      setState(() => _editing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
    } else {
      final error =
          ref.read(authControllerProvider).error ??
          'Profile updates are unavailable right now.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final customer = auth.customer;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      bottomNavigationBar: const MainNav(index: 2),
      body: customer == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 12),
                Center(
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: AppTheme.surfaceHigh,
                    child: Text(
                      customer.name.isNotEmpty
                          ? customer.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 34,
                        color: AppTheme.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    customer.email,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 26),
                if (_editing)
                  _ProfileForm(
                    formKey: _formKey,
                    name: _name,
                    phone: _phone,
                    busy: auth.busy,
                    errors: auth.fieldErrors,
                    onSave: _save,
                    onCancel: () => setState(() => _editing = false),
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        _tile(Icons.person_outline, 'Name', customer.name),
                        _tile(Icons.email_outlined, 'Email', customer.email),
                        _tile(
                          Icons.phone_outlined,
                          'Phone',
                          customer.phone ?? 'Not provided',
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                if (!_editing)
                  OutlinedButton.icon(
                    onPressed: _startEditing,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit profile'),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.danger,
                    side: const BorderSide(color: AppTheme.danger),
                  ),
                  onPressed: auth.busy
                      ? null
                      : () =>
                            ref.read(authControllerProvider.notifier).logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                ),
              ],
            ),
    );
  }

  Widget _tile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.gold),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white54, fontSize: 13),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
    );
  }
}

class _ProfileForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController phone;
  final bool busy;
  final Map<String, List<String>> errors;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _ProfileForm({
    required this.formKey,
    required this.name,
    required this.phone,
    required this.busy,
    required this.errors,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: const Icon(Icons.person_outline),
              errorText: errors['name']?.first,
            ),
            validator: (value) => value == null || value.trim().length < 2
                ? 'Enter your name'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone',
              prefixIcon: const Icon(Icons.phone_outlined),
              errorText: errors['phone']?.first,
            ),
            validator: (value) => value == null || value.trim().length < 7
                ? 'Enter a phone number'
                : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : onCancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: busy ? null : onSave,
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
