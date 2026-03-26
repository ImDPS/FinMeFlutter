import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/features/budgets/data/budgets_repository.dart';

part 'budgets_provider.g.dart';

typedef BudgetList = List<Budget>;

@riverpod
BudgetsRepository budgetsRepository(Ref ref) =>
    BudgetsRepository(db: AppDatabase.forTesting());

@riverpod
class BudgetsNotifier extends _$BudgetsNotifier {
  @override
  Future<BudgetList> build() {
    final now = DateTime.now();
    return ref.read(budgetsRepositoryProvider).getBudgetsForMonth(now.year, now.month);
  }

  Future<void> create({required String category, required int limitAmount}) async {
    final now = DateTime.now();
    await ref.read(budgetsRepositoryProvider).createBudget(
      category: category, limitAmount: limitAmount, month: now.month, year: now.year,
    );
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await ref.read(budgetsRepositoryProvider).deleteBudget(id);
    ref.invalidateSelf();
  }
}
