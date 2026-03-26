import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finme/core/theme/app_colors.dart';
import 'package:finme/core/theme/app_text_styles.dart';
import 'package:finme/core/widgets/glass_card.dart';
import 'package:finme/features/settings/presentation/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: AppTextStyles.heading)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Monthly Income
          _SectionHeader('Monthly Income'),
          GlassCard(
            child: Row(
              children: [
                Expanded(child: Text('Income / month', style: AppTextStyles.body)),
                TextButton(
                  onPressed: () => _editIncome(context, ref, state.monthlyIncomeInr),
                  child: Text('₹${state.monthlyIncomeInr}', style: AppTextStyles.body.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ),

          // App Lock Timeout
          const SizedBox(height: 20),
          _SectionHeader('Security'),
          GlassCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Lock timeout', style: AppTextStyles.body)),
                    DropdownButton<int>(
                      value: state.appLockTimeoutSeconds,
                      dropdownColor: const Color(0xFF1C1C1E),
                      style: AppTextStyles.body,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 30, child: Text('30 sec')),
                        DropdownMenuItem(value: 60, child: Text('1 min')),
                        DropdownMenuItem(value: 300, child: Text('5 min')),
                      ],
                      onChanged: (v) => ref.read(settingsProvider.notifier).setLockTimeout(v ?? 30),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Manual Accounts
          const SizedBox(height: 20),
          _SectionHeader('Manual Accounts'),
          GlassCard(
            child: Column(
              children: [
                ...state.manualAccounts.map((a) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(a.name, style: AppTextStyles.body),
                  subtitle: Text(a.type, style: AppTextStyles.caption),
                  trailing: IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.danger),
                    onPressed: () => ref.read(settingsProvider.notifier).deleteManualAccount(a.id),
                  ),
                )),
                TextButton.icon(
                  onPressed: () => _addManualAccount(context, ref),
                  icon: const Icon(LucideIcons.plus, color: AppColors.primary),
                  label: Text('Add Manual Account', style: AppTextStyles.body.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ),

          // Data
          const SizedBox(height: 20),
          _SectionHeader('Data & Privacy'),
          GlassCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.download, color: AppColors.primary),
                  title: Text('Export CSV', style: AppTextStyles.body),
                  onTap: () => ref.read(settingsProvider.notifier).exportCsv(),
                ),
                const Divider(color: AppColors.glassBorder),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.trash2, color: AppColors.danger),
                  title: Text('Delete All Data', style: AppTextStyles.body.copyWith(color: AppColors.danger)),
                  onTap: () => _confirmDelete(context, ref),
                ),
              ],
            ),
          ),

          // About
          const SizedBox(height: 20),
          _SectionHeader('About'),
          GlassCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('FinMe', style: AppTextStyles.body),
              subtitle: Text('Version 1.0.0', style: AppTextStyles.caption),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _editIncome(BuildContext context, WidgetRef ref, int current) {
    final ctrl = TextEditingController(text: current == 0 ? '' : current.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: Text('Monthly Income', style: AppTextStyles.heading),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: AppTextStyles.body,
          decoration: const InputDecoration(prefixText: '₹ '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text) ?? 0;
              ref.read(settingsProvider.notifier).setMonthlyIncome(v);
              Navigator.pop(ctx);
            },
            child: Text('Save', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _addManualAccount(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final balCtrl = TextEditingController();
    String type = 'manual';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: GlassCard(
            borderRadius: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Manual Account', style: AppTextStyles.heading),
                const SizedBox(height: 16),
                TextField(controller: nameCtrl, style: AppTextStyles.body,
                  decoration: InputDecoration(hintText: 'Account name',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true, fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  dropdownColor: const Color(0xFF1C1C1E),
                  style: AppTextStyles.body,
                  items: const [
                    DropdownMenuItem(value: 'manual', child: Text('Cash')),
                    DropdownMenuItem(value: 'savings', child: Text('Savings')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => type = v ?? 'manual'),
                  decoration: InputDecoration(filled: true, fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 10),
                TextField(controller: balCtrl, keyboardType: TextInputType.number, style: AppTextStyles.body,
                  decoration: InputDecoration(hintText: 'Balance (₹)',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true, fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Add', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      ref.read(settingsProvider.notifier).addManualAccount(
                        name: nameCtrl.text.trim(),
                        type: type,
                        balance: int.tryParse(balCtrl.text) ?? 0,
                      );
                      Navigator.pop(ctx);
                    },
                  )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: Text('Delete All Data?', style: AppTextStyles.heading.copyWith(color: AppColors.danger)),
        content: Text('This will delete all local data permanently. This cannot be undone.', style: AppTextStyles.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Wire up full delete sequence (DB + Firestore + Auth)
            },
            child: Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
  );
}
