import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finme/core/constants/categories.dart';
import 'package:finme/core/theme/app_colors.dart';
import 'package:finme/core/theme/app_text_styles.dart';
import 'package:finme/core/utils/currency_formatter.dart';
import 'package:finme/core/widgets/error_card.dart';
import 'package:finme/core/widgets/glass_card.dart';
import 'package:finme/core/widgets/skeleton_loader.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/features/transactions/presentation/providers/transactions_provider.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _searchQuery = '';
  String? _filterCategory;

  @override
  Widget build(BuildContext context) {
    final txsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions', style: AppTextStyles.heading),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, color: AppColors.primary),
            onPressed: () => _showAddModal(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search transactions\u2026',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(LucideIcons.search, color: AppColors.textSecondary, size: 18),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(label: 'All', selected: _filterCategory == null, onTap: () => setState(() => _filterCategory = null)),
                ...kDefaultCategories.map((c) => _FilterChip(
                  label: c.label,
                  selected: _filterCategory == c.id,
                  onTap: () => setState(() => _filterCategory = c.id),
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: txsAsync.when(
              loading: () => const SkeletonLoader(width: double.infinity, height: 200),
              error: (e, _) => ErrorCard(message: e.toString(), onRetry: () => ref.invalidate(transactionsProvider)),
              data: (List<Transaction> txs) {
                final filtered = txs
                    .where((Transaction t) => _filterCategory == null || t.category == _filterCategory)
                    .where((Transaction t) => _searchQuery.isEmpty || t.merchant.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No transactions', style: TextStyle(color: AppColors.textSecondary)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _TransactionItem(tx: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionModal(
        onSave: ({required amount, required merchant, required category, required date, required note}) {
          ref.read(transactionsProvider.notifier).add(
            accountId: 'default',
            amount: amount,
            merchant: merchant,
            category: category,
            date: date,
            note: note,
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: selected ? Colors.white : AppColors.textSecondary)),
    ),
  );
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.tx});
  final Transaction tx;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.merchant, style: AppTextStyles.body),
                Text(tx.category, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(tx.amount),
            style: AppTextStyles.body.copyWith(color: tx.amount < 0 ? AppColors.danger : AppColors.success),
          ),
        ],
      ),
    );
  }
}

class AddTransactionModal extends StatefulWidget {
  final void Function({
    required int amount,
    required String merchant,
    required String category,
    required DateTime date,
    required String note,
  }) onSave;

  const AddTransactionModal({super.key, required this.onSave});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _merchantCtrl = TextEditingController();
  final _amountCtrl   = TextEditingController();
  final _noteCtrl     = TextEditingController();
  String _category = 'other';
  bool _isDebit = true;

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: GlassCard(
        borderRadius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Transaction', style: AppTextStyles.heading),
            const SizedBox(height: 16),
            _field('Merchant', _merchantCtrl),
            const SizedBox(height: 10),
            _field('Amount (\u20b9)', _amountCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            Row(
              children: [
                _typeBtn('Debit', _isDebit, () => setState(() => _isDebit = true)),
                const SizedBox(width: 8),
                _typeBtn('Credit', !_isDebit, () => setState(() => _isDebit = false)),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _category,
              dropdownColor: const Color(0xFF1C1C1E),
              style: AppTextStyles.body,
              items: kDefaultCategories.map((c) => DropdownMenuItem(
                value: c.id,
                child: Text('${c.emoji} ${c.label}'),
              )).toList(),
              onChanged: (v) => setState(() => _category = v ?? 'other'),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            _field('Note (optional)', _noteCtrl),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String hint, TextEditingController ctrl, {TextInputType? keyboardType}) =>
      TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      );

  Widget _typeBtn(String label, bool active, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(color: active ? Colors.white : AppColors.textSecondary)),
      ),
    ),
  );

  void _save() {
    final rawAmount = int.tryParse(_amountCtrl.text) ?? 0;
    final amount = _isDebit ? -rawAmount.abs() : rawAmount.abs();
    widget.onSave(
      amount: amount,
      merchant: _merchantCtrl.text.trim().isEmpty ? 'Unknown' : _merchantCtrl.text.trim(),
      category: _category,
      date: DateTime.now(),
      note: _noteCtrl.text.trim(),
    );
    Navigator.of(context).pop();
  }
}
