import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finme/core/theme/app_colors.dart';
import 'package:finme/core/theme/app_text_styles.dart';
import 'package:finme/core/utils/currency_formatter.dart';
import 'package:finme/core/widgets/glass_card.dart';
import 'package:finme/core/widgets/skeleton_loader.dart';
import 'package:finme/core/widgets/error_card.dart';
import 'package:finme/core/widgets/empty_state.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/features/dashboard/presentation/providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashState = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('FinMe', style: AppTextStyles.heading),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {},
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: dashState.isLoading
          ? _buildSkeleton()
          : dashState.error != null
              ? Center(child: ErrorCard(message: dashState.error!, onRetry: () => ref.read(dashboardProvider.notifier).load()))
              : RefreshIndicator(
                  onRefresh: () => ref.read(dashboardProvider.notifier).load(),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _BalanceCard(state: dashState),
                      const SizedBox(height: 16),
                      _SpendVsIncome(state: dashState),
                      const SizedBox(height: 16),
                      _TopCategories(state: dashState),
                      const SizedBox(height: 16),
                      _RecentTransactions(transactions: dashState.recentTransactions),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSkeleton() => ListView(
    padding: const EdgeInsets.all(20),
    children: const [
      SkeletonLoader(width: double.infinity, height: 120, borderRadius: 20),
      SizedBox(height: 16),
      SkeletonLoader(width: double.infinity, height: 80, borderRadius: 20),
    ],
  );
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Balance', style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(CurrencyFormatter.format(state.totalBalance), style: AppTextStyles.display),
        ],
      ),
    );
  }
}

class _SpendVsIncome extends StatelessWidget {
  const _SpendVsIncome({required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Expanded(child: _Metric(
            label: 'Income',
            value: CurrencyFormatter.format(state.monthIncome),
            color: AppColors.success,
          )),
          Container(width: 1, height: 40, color: AppColors.glassBorder),
          Expanded(child: _Metric(
            label: 'Spent',
            value: CurrencyFormatter.format(state.monthSpend),
            color: AppColors.danger,
          )),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: AppTextStyles.caption),
      const SizedBox(height: 4),
      Text(value, style: AppTextStyles.body.copyWith(color: color)),
    ],
  );
}

class _TopCategories extends StatelessWidget {
  const _TopCategories({required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    if (state.topCategories.isEmpty) {
      return EmptyState(
        icon: LucideIcons.pieChart,
        title: 'No Spend Yet',
        subtitle: 'Add transactions to see category breakdown',
        ctaLabel: 'Add Transaction',
        onCta: () {},
      );
    }
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Categories', style: AppTextStyles.heading),
          const SizedBox(height: 12),
          ...state.topCategories.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: AppTextStyles.body),
                Text(CurrencyFormatter.format(e.value), style: AppTextStyles.body.copyWith(color: AppColors.danger)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions({required this.transactions});
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent', style: AppTextStyles.heading),
          const SizedBox(height: 12),
          ...transactions.map((t) => _TransactionRow(tx: t)),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.tx});
  final Transaction tx;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(tx.merchant, style: AppTextStyles.body, overflow: TextOverflow.ellipsis)),
        Text(
          CurrencyFormatter.format(tx.amount),
          style: AppTextStyles.body.copyWith(color: tx.amount < 0 ? AppColors.danger : AppColors.success),
        ),
      ],
    ),
  );
}
