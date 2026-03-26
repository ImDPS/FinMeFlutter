import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finme/core/theme/app_colors.dart';
import 'package:finme/core/theme/app_text_styles.dart';
import 'package:finme/features/auth/presentation/providers/auth_provider.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final _pinController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/dashboard');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: AppColors.primary),
                const SizedBox(height: 24),
                Text('FinMe is locked', style: AppTextStyles.heading),
                const SizedBox(height: 8),
                Text('Use your PIN or biometrics to unlock', style: AppTextStyles.caption),
                const SizedBox(height: 32),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, letterSpacing: 8),
                  decoration: InputDecoration(
                    hintText: 'Enter PIN',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.glassBorder),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _unlockWithPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Unlock with PIN', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _unlockWithBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Unlock with Biometrics'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _unlockWithPin() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) return;
    final success = await ref.read(authProvider.notifier).checkPin(pin);
    if (!success && mounted) {
      setState(() => _error = 'Incorrect PIN');
    }
  }

  Future<void> _unlockWithBiometric() async {
    final success = await ref.read(authProvider.notifier).authenticateWithBiometric();
    if (!success && mounted) {
      setState(() => _error = 'Biometric authentication failed');
    }
  }
}
