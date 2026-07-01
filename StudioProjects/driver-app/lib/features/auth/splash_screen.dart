import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Shown while the app restores a saved session.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.car_rental, size: 64, color: AppTheme.gold),
            SizedBox(height: 16),
            Text('PRINCE LIMOUSINE',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text('Driver', style: TextStyle(color: AppTheme.goldSoft, letterSpacing: 4)),
            SizedBox(height: 28),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(color: AppTheme.gold, strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
