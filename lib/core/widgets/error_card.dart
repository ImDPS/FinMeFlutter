import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finme/core/theme/app_colors.dart';
import 'package:finme/core/theme/app_text_styles.dart';
import 'package:finme/core/widgets/glass_card.dart';

class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorCard({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          const Icon(LucideIcons.alertCircle, color: AppColors.danger, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: AppTextStyles.body)),
          TextButton(
            onPressed: onRetry,
            child: Text('Retry', style: AppTextStyles.body.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
