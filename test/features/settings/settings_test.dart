import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/features/settings/data/settings_repository.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = SettingsRepository(db: db);
  });

  tearDown(() async => db.close());

  group('SettingsRepository', () {
    test('addManualAccount inserts with manual consent status', () async {
      await repo.addManualAccount(name: 'Cash', type: 'manual', balance: 5000);
      final accounts = await db.accountsDao.getAllAccounts();
      expect(accounts.length, 1);
      expect(accounts.first.consentStatus, 'manual');
      expect(accounts.first.name, 'Cash');
    });

    test('getManualAccounts returns only manual accounts', () async {
      await repo.addManualAccount(name: 'Cash', type: 'manual', balance: 5000);
      await db.accountsDao.insertAccount(AccountsCompanion.insert(
        id: 'aa-1', name: 'AA Account', type: 'savings',
        institution: 'SBI', consentStatus: const Value('active'),
      ));
      final manual = await repo.getManualAccounts();
      expect(manual.length, 1);
      expect(manual.first.name, 'Cash');
    });
  });
}
