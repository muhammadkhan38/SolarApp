import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(authControllerProvider).driver;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: driver == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 12),
                Center(
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: AppTheme.surface,
                    child: Text(
                      driver.name.isNotEmpty ? driver.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontSize: 34, color: AppTheme.gold, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(driver.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: driver.isOnline ? Colors.green : Colors.white38,
                        ),
                      ),
                      Text(driver.status,
                          style: const TextStyle(color: Colors.white54)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      _tile(Icons.email_outlined, 'Email', driver.email),
                      if (driver.phone != null)
                        _tile(Icons.phone_outlined, 'Phone', driver.phone!),
                      _tile(Icons.badge_outlined, 'Driver ID', '#${driver.id}'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD9534F),
                    side: const BorderSide(color: Color(0xFFD9534F)),
                  ),
                  onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                ),
              ],
            ),
    );
  }

  Widget _tile(IconData icon, String label, String value) => ListTile(
        leading: Icon(icon, color: AppTheme.gold),
        title: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        subtitle: Text(value, style: const TextStyle(color: Colors.white, fontSize: 15)),
      );
}
