import 'package:drift/drift.dart';
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

    test('getExpiringConsentAccounts returns accounts expiring within 7 days', () async {
      final soonExpiry = DateTime.now().add(const Duration(days: 3));
      await db.accountsDao.insertAccount(AccountsCompanion.insert(
        id: 'a3', name: 'ICICI', type: 'savings', institution: 'ICICI',
        consentExpiryDate: Value(soonExpiry),
        consentStatus: const Value('active'),
      ));
      final expiring = await repo.getExpiringConsentAccounts();
      expect(expiring.length, 1);
    });
  });
}
