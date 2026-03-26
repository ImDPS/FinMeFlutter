import 'package:flutter/material.dart';
import 'package:finme/core/theme/app_colors.dart';
import 'package:finme/core/theme/app_text_styles.dart';

class AppLockScreen extends StatelessWidget {
  const AppLockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: AppColors.primary),
              const SizedBox(height: 24),
              Text('FinMe is locked', style: AppTextStyles.heading),
              const SizedBox(height: 8),
              Text('Use your PIN or biometrics to unlock', style: AppTextStyles.caption),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.fingerprint),
                label: const Text('Unlock with Biometrics'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
