import 'package:flutter/painting.dart' show Color;
import 'package:uuid/uuid.dart';
import 'package:finme/core/theme/app_colors.dart';
import 'package:finme/data/local/database.dart';

const _uuid = Uuid();

enum BudgetColor { green, amber, red }

class BudgetsRepository {
  BudgetsRepository({required AppDatabase db}) : _db = db;
  final AppDatabase _db;

  Future<void> createBudget({
    required String category,
    required int limitAmount,
    required int month,
    required int year,
  }) async {
    await _db.budgetsDao.insertBudget(
      BudgetsCompanion.insert(
        id: _uuid.v4(),
        category: category,
        limitAmount: limitAmount,
        month: month,
        year: year,
      ),
    );
  }

  Future<List<Budget>> getBudgetsForMonth(int year, int month) =>
      _db.budgetsDao.getBudgetsForMonth(year, month);

  Future<void> deleteBudget(String id) => _db.budgetsDao.deleteBudget(id);

  /// Returns color classification based on spend vs budget.
  static BudgetColor getBudgetColor(int spent, int limit) {
    if (limit <= 0) return BudgetColor.green;
    final ratio = spent / limit;
    if (ratio >= 0.9) return BudgetColor.red;
    if (ratio >= 0.7) return BudgetColor.amber;
    return BudgetColor.green;
  }

  static Color getBudgetColorValue(BudgetColor color) => switch (color) {
    BudgetColor.green => AppColors.success,
    BudgetColor.amber => AppColors.warning,
    BudgetColor.red   => AppColors.danger,
  };
}
