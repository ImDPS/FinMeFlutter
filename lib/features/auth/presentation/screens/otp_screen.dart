import 'package:flutter/material.dart';
import 'package:finme/core/theme/app_colors.dart';
import 'package:finme/core/theme/app_text_styles.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter the 6-digit code', style: AppTextStyles.heading),
            const SizedBox(height: 8),
            Text('sent to your phone number', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            TextField(
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '------',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
