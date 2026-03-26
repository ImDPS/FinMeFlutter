import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finme/core/theme/app_colors.dart';
import 'package:finme/core/theme/app_text_styles.dart';
import 'package:finme/core/utils/currency_formatter.dart';
import 'package:finme/core/widgets/glass_card.dart';
import 'package:finme/core/widgets/skeleton_loader.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/features/net_worth/presentation/providers/net_worth_provider.dart';

class NetWorthScreen extends ConsumerWidget {
  const NetWorthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(netWorthProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Net Worth', style: AppTextStyles.heading),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: AppColors.textSecondary),
            onPressed: () => ref.read(netWorthProvider.notifier).load(),
          ),
        ],
      ),
      body: s.isLoading
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: SkeletonLoader(width: double.infinity, height: 160),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(netWorthProvider.notifier).load(),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Consent expiry banner
                  if (s.expiringAccounts.isNotEmpty)
                    _ConsentBanner(accounts: s.expiringAccounts),

                  // Net worth summary
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Net Worth', style: AppTextStyles.caption),
                        const SizedBox(height: 4),
                        Text(CurrencyFormatter.format(s.totalNetWorth), style: AppTextStyles.display),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _Metric(label: 'Assets', value: s.totalAssets, color: AppColors.success),
                            const SizedBox(width: 24),
                            _Metric(label: 'Liabilities', value: s.totalLiabilities, color: AppColors.danger),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Accounts by type
                  ..._buildSections(s.accountsByType),

                  // Trend stub
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Net Worth Trend', style: AppTextStyles.heading),
                        const SizedBox(height: 8),
                        Text('Trends coming soon — v1.1', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildSections(Map<String, List<Account>> byType) {
    const typeLabels = {
      'savings':     'Bank Accounts',
      'current':     'Current Accounts',
      'credit_card': 'Credit Cards',
      'mf':          'Mutual Funds',
      'equity':      'Stocks',
      'manual':      'Manual Accounts',
    };

    return byType.entries.map((entry) {
      final label = typeLabels[entry.key] ?? entry.key;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _AccountSection(label: label, accounts: entry.value),
      );
    }).toList();
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.caption),
      Text(CurrencyFormatter.format(value), style: AppTextStyles.body.copyWith(color: color)),
    ],
  );
}

class _ConsentBanner extends StatelessWidget {
  const _ConsentBanner({required this.accounts});
  final List<Account> accounts;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.warning.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
    ),
    child: Row(
      children: [
        const Icon(LucideIcons.alertTriangle, color: AppColors.warning, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(
          '${accounts.length} account(s) consent expiring soon — re-authorise to continue syncing',
          style: AppTextStyles.caption.copyWith(color: AppColors.warning),
        )),
      ],
    ),
  );
}

class _AccountSection extends StatefulWidget {
  const _AccountSection({required this.label, required this.accounts});
  final String label;
  final List<Account> accounts;

  @override
  State<_AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<_AccountSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) => GlassCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(child: Text(widget.label, style: AppTextStyles.body)),
                Icon(_expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        if (_expanded)
          ...widget.accounts.map((a) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.name, style: AppTextStyles.body),
                    Text(a.institution, style: AppTextStyles.caption),
                  ],
                )),
                Text(
                  CurrencyFormatter.format(a.balance.abs()),
                  style: AppTextStyles.body.copyWith(
                    color: a.balance < 0 ? AppColors.danger : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          )),
      ],
    ),
  );
}
