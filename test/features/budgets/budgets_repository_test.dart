import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/features/budgets/data/budgets_repository.dart';

void main() {
  late AppDatabase db;
  late BudgetsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = BudgetsRepository(db: db);
  });

  tearDown(() async => db.close());

  group('BudgetsRepository', () {
    test('createBudget stores and retrieves budget', () async {
      await repo.createBudget(category: 'food', limitAmount: 10000, month: 3, year: 2026);
      final budgets = await repo.getBudgetsForMonth(2026, 3);
      expect(budgets.length, 1);
      expect(budgets.first.category, 'food');
      expect(budgets.first.limitAmount, 10000);
    });

    test('getBudgetColor returns green when under 70%', () {
      expect(BudgetsRepository.getBudgetColor(5000, 10000), BudgetColor.green);
    });

    test('getBudgetColor returns amber when 70-90%', () {
      expect(BudgetsRepository.getBudgetColor(8000, 10000), BudgetColor.amber);
    });

    test('getBudgetColor returns red when over 90%', () {
      expect(BudgetsRepository.getBudgetColor(9500, 10000), BudgetColor.red);
    });
  });
}
