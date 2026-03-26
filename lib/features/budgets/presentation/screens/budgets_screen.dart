import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finme/core/constants/categories.dart';
import 'package:finme/core/theme/app_colors.dart';
import 'package:finme/core/theme/app_text_styles.dart';
import 'package:finme/core/utils/currency_formatter.dart';
import 'package:finme/core/widgets/glass_card.dart';
import 'package:finme/core/widgets/skeleton_loader.dart';
import 'package:finme/core/widgets/empty_state.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/features/budgets/data/budgets_repository.dart';
import 'package:finme/features/budgets/presentation/providers/budgets_provider.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Budgets', style: AppTextStyles.heading),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, color: AppColors.primary),
            onPressed: () => _showAddBudgetSheet(context, ref),
          ),
        ],
      ),
      body: budgetsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(20),
          child: SkeletonLoader(width: double.infinity, height: 200),
        ),
        error: (Object e, StackTrace _) => Center(
          child: Text(e.toString(), style: AppTextStyles.caption),
        ),
        data: (BudgetList budgets) {
          if (budgets.isEmpty) {
            return EmptyState(
              icon: LucideIcons.pieChart,
              title: 'No Budgets Set',
              subtitle: 'Tap + to create your first monthly budget',
              ctaLabel: 'Add Budget',
              onCta: () => _showAddBudgetSheet(context, ref),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: budgets.length,
            itemBuilder: (BuildContext _, int i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BudgetCard(
                budget: budgets[i],
                onDelete: () => ref.read(budgetsProvider.notifier).delete(budgets[i].id),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddBudgetSheet(BuildContext context, WidgetRef ref) {
    String category = kDefaultCategories.first.id;
    final limitCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: GlassCard(
            borderRadius: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Budget', style: AppTextStyles.heading),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  dropdownColor: const Color(0xFF1C1C1E),
                  style: AppTextStyles.body,
                  items: kDefaultCategories.map((AppCategory c) => DropdownMenuItem<String>(
                    value: c.id,
                    child: Text('${c.emoji} ${c.label}'),
                  )).toList(),
                  onChanged: (String? v) => setState(() => category = v ?? category),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: limitCtrl,
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    hintText: 'Monthly limit (₹)',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final int limit = int.tryParse(limitCtrl.text) ?? 0;
                      if (limit > 0) {
                        ref.read(budgetsProvider.notifier).create(
                          category: category,
                          limitAmount: limit,
                        );
                        Navigator.of(ctx).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save Budget', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.budget, required this.onDelete});
  final Budget budget;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    // TODO: wire up actual spending from TransactionsRepository
    const int spent = 0;
    final double ratio = budget.limitAmount > 0 ? spent / budget.limitAmount : 0.0;
    final BudgetColor color = BudgetsRepository.getBudgetColor(spent, budget.limitAmount);
    final Color colorValue = BudgetsRepository.getBudgetColorValue(color);
    final AppCategory cat = kDefaultCategories.firstWhere(
      (AppCategory c) => c.id == budget.category,
      orElse: () => kDefaultCategories.last,
    );

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${cat.emoji} ${cat.label}', style: AppTextStyles.body),
              const Spacer(),
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.danger),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.format(spent),
                style: AppTextStyles.caption.copyWith(color: colorValue),
              ),
              Text(
                'of ${CurrencyFormatter.format(budget.limitAmount)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(colorValue),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
