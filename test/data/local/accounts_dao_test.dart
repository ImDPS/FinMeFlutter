import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finme/data/local/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting();
  });

  tearDown(() async => db.close());

  group('AccountsDao', () {
    test('inserts and retrieves an account', () async {
      await db.accountsDao.insertAccount(
        AccountsCompanion.insert(
          id: 'acc-1',
          name: 'HDFC Savings',
          type: 'savings',
          institution: 'HDFC Bank',
          balance: const Value(100000),
          consentStatus: const Value('active'),
        ),
      );
      final accounts = await db.accountsDao.getAllAccounts();
      expect(accounts.length, 1);
      expect(accounts.first.name, 'HDFC Savings');
    });
  });
}
