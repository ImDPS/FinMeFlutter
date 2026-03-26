import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/data/local/database_provider.dart';
import 'package:finme/features/budgets/data/budgets_repository.dart';

part 'budgets_provider.g.dart';

typedef BudgetList = List<Budget>;

@riverpod
Future<BudgetsRepository> budgetsRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return BudgetsRepository(db: db);
}

/// Returns total spending per category for the current month.
/// Used by BudgetCard to show actual spend vs limit.
@riverpod
Future<Map<String, int>> categorySpending(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final now = DateTime.now();
  final txs = await db.transactionsDao.getTransactionsForMonth(now.year, now.month);
  final spending = <String, int>{};
  for (final tx in txs) {
    if (tx.amount < 0) {
      // Debits are negative, accumulate as positive spend
      spending[tx.category] = (spending[tx.category] ?? 0) + tx.amount.abs();
    }
  }
  return spending;
}

@riverpod
class BudgetsNotifier extends _$BudgetsNotifier {
  @override
  Future<BudgetList> build() async {
    final now = DateTime.now();
    final repo = await ref.read(budgetsRepositoryProvider.future);
    return repo.getBudgetsForMonth(now.year, now.month);
  }

  Future<void> create({required String category, required int limitAmount}) async {
    final now = DateTime.now();
    final repo = await ref.read(budgetsRepositoryProvider.future);
    await repo.createBudget(
      category: category, limitAmount: limitAmount, month: now.month, year: now.year,
    );
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    final repo = await ref.read(budgetsRepositoryProvider.future);
    await repo.deleteBudget(id);
    ref.invalidateSelf();
  }
}
