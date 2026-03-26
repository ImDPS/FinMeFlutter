import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/features/net_worth/data/net_worth_repository.dart';

void main() {
  late AppDatabase db;
  late NetWorthRepository repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = NetWorthRepository(db: db);
  });

  tearDown(() async => db.close());

  group('NetWorthRepository', () {
    test('getTotalNetWorth returns assets minus liabilities', () async {
      await db.accountsDao.insertAccount(AccountsCompanion.insert(
        id: 'a1', name: 'SBI', type: 'savings', institution: 'SBI',
        balance: const Value(100000),
      ));
      await db.accountsDao.insertAccount(AccountsCompanion.insert(
        id: 'a2', name: 'HDFC CC', type: 'credit_card', institution: 'HDFC',
        balance: const Value(-20000),
      ));
      final netWorth = await repo.getTotalNetWorth();
      expect(netWorth, 80000);
    });

    test('getAccountsByType groups accounts correctly', () async {
      await db.accountsDao.insertAccount(AccountsCompanion.insert(
        id: 'a3', name: 'ICICI', type: 'savings', institution: 'ICICI',
        balance: const Value(50000),
      ));
      final byType = await repo.getAccountsByType();
      expect(byType['savings'], isNotNull);
    });
  });
}
