import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:finme/data/local/database.dart';

const _uuid = Uuid();

class SettingsRepository {
  SettingsRepository({required AppDatabase db}) : _db = db;
  final AppDatabase _db;

  Future<void> addManualAccount({required String name, required String type, required int balance}) async {
    await _db.accountsDao.insertAccount(AccountsCompanion.insert(
      id: _uuid.v4(),
      name: name,
      type: type,
      institution: 'Manual',
      balance: Value(balance),
      consentStatus: const Value('manual'),
    ));
  }

  Future<List<Account>> getManualAccounts() async {
    final all = await _db.accountsDao.getAllAccounts();
    return all.where((a) => a.consentStatus == 'manual').toList();
  }

  Future<UserSetting?> getSettings() => _db.userSettingsDao.getSettings();

  Future<void> saveSettings({required int monthlyIncome, required int lockTimeout}) =>
      _db.userSettingsDao.upsertSettings(UserSettingsCompanion.insert(
        id: 'singleton',
        monthlyIncomeInr: Value(monthlyIncome),
        appLockTimeoutSeconds: Value(lockTimeout),
      ));
}
