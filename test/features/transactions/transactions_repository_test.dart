import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/features/transactions/data/transactions_repository.dart';

void main() {
  late AppDatabase db;
  late TransactionsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = TransactionsRepository(db: db);
  });

  tearDown(() async => db.close());

  group('TransactionsRepository', () {
    test('addTransaction inserts and can be retrieved', () async {
      await repo.addTransaction(
        accountId: 'a1',
        amount: -1500,
        merchant: 'Zomato',
        category: 'food',
        date: DateTime(2026, 3, 15),
        note: 'Lunch',
      );
      final all = await db.transactionsDao.getAllTransactions();
      expect(all.length, 1);
      expect(all.first.merchant, 'Zomato');
      expect(all.first.amount, -1500);
    });

    test('getTransactionsForMonth returns only current month', () async {
      await db.transactionsDao.insertTransaction(TransactionsCompanion.insert(
        id: 'tx-old', accountId: 'a1', amount: -200,
        merchant: 'Old', date: DateTime(2025, 1, 10), source: 'manual',
      ));
      await db.transactionsDao.insertTransaction(TransactionsCompanion.insert(
        id: 'tx-now', accountId: 'a1', amount: -500,
        merchant: 'New', date: DateTime(2026, 3, 20), source: 'manual',
      ));
      final results = await repo.getTransactionsForMonth(2026, 3);
      expect(results.length, 1);
      expect(results.first.merchant, 'New');
    });
  });
}
