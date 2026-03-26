import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/features/dashboard/data/dashboard_repository.dart';

void main() {
  late AppDatabase db;
  late DashboardRepository repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = DashboardRepository(db: db);
  });

  tearDown(() async => db.close());

  group('DashboardRepository', () {
    test('totalBalanceInr returns sum of all account balances', () async {
      await db.accountsDao.insertAccount(AccountsCompanion.insert(
        id: 'a1', name: 'HDFC', type: 'savings', institution: 'HDFC',
        balance: const Value(50000),
      ));
      await db.accountsDao.insertAccount(AccountsCompanion.insert(
        id: 'a2', name: 'ICICI', type: 'savings', institution: 'ICICI',
        balance: const Value(30000),
      ));
      final total = await repo.totalBalanceInr();
      expect(total, 80000);
    });

    test('currentMonthSpend returns sum of negative transactions', () async {
      final now = DateTime.now();
      await db.transactionsDao.insertTransaction(TransactionsCompanion.insert(
        id: 'tx1', accountId: 'a1', amount: -5000,
        merchant: 'Swiggy', date: now, source: 'manual',
      ));
      await db.transactionsDao.insertTransaction(TransactionsCompanion.insert(
        id: 'tx2', accountId: 'a1', amount: -3000,
        merchant: 'Uber', date: now, source: 'manual',
      ));
      final spend = await repo.currentMonthSpend();
      expect(spend, 8000);
    });
  });
}
