import 'package:drift/drift.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/data/local/tables/budgets_table.dart';

part 'budgets_dao.g.dart';

@DriftAccessor(tables: [Budgets])
class BudgetsDao extends DatabaseAccessor<AppDatabase> with _$BudgetsDaoMixin {
  BudgetsDao(super.db);

  Future<List<Budget>> getAllBudgets() => select(budgets).get();
  Future<List<Budget>> getBudgetsForMonth(int year, int month) =>
      (select(budgets)..where((b) => b.year.equals(year) & b.month.equals(month))).get();
  Future<void> insertBudget(BudgetsCompanion entry) =>
      into(budgets).insertOnConflictUpdate(entry);
  Future<void> deleteBudget(String id) =>
      (delete(budgets)..where((b) => b.id.equals(id))).go();
}
