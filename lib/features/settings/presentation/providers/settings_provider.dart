import 'dart:io';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/data/local/database_provider.dart';

part 'settings_provider.g.dart';

const _uuid = Uuid();

class SettingsState {
  const SettingsState({
    this.monthlyIncomeInr = 0,
    this.appLockTimeoutSeconds = 30,
    this.manualAccounts = const [],
  });

  final int monthlyIncomeInr;
  final int appLockTimeoutSeconds;
  final List<Account> manualAccounts;
}

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  AppDatabase? _db;

  Future<AppDatabase> _getDb() async {
    final db = _db;
    if (db != null) return db;
    final newDb = await ref.read(appDatabaseProvider.future);
    _db = newDb;
    return newDb;
  }

  @override
  SettingsState build() {
    Future.microtask(_load);
    return const SettingsState();
  }

  Future<void> _load() async {
    final db = await _getDb();
    final settings = await db.userSettingsDao.getSettings();
    final allAccounts = await db.accountsDao.getAllAccounts();
    state = SettingsState(
      monthlyIncomeInr: settings?.monthlyIncomeInr ?? 0,
      appLockTimeoutSeconds: settings?.appLockTimeoutSeconds ?? 30,
      manualAccounts: allAccounts.where((a) => a.consentStatus == 'manual').toList(),
    );
  }

  Future<void> setMonthlyIncome(int amount) async {
    final db = await _getDb();
    await db.userSettingsDao.upsertSettings(
      UserSettingsCompanion.insert(
        id: 'singleton',
        monthlyIncomeInr: Value(amount),
        appLockTimeoutSeconds: Value(state.appLockTimeoutSeconds),
      ),
    );
    state = SettingsState(
      monthlyIncomeInr: amount,
      appLockTimeoutSeconds: state.appLockTimeoutSeconds,
      manualAccounts: state.manualAccounts,
    );
  }

  Future<void> setLockTimeout(int seconds) async {
    final db = await _getDb();
    await db.userSettingsDao.upsertSettings(
      UserSettingsCompanion.insert(
        id: 'singleton',
        monthlyIncomeInr: Value(state.monthlyIncomeInr),
        appLockTimeoutSeconds: Value(seconds),
      ),
    );
    state = SettingsState(
      monthlyIncomeInr: state.monthlyIncomeInr,
      appLockTimeoutSeconds: seconds,
      manualAccounts: state.manualAccounts,
    );
  }

  Future<void> addManualAccount({required String name, required String type, required int balance}) async {
    final db = await _getDb();
    await db.accountsDao.insertAccount(AccountsCompanion.insert(
      id: _uuid.v4(),
      name: name,
      type: type,
      institution: 'Manual',
      balance: Value(balance),
      consentStatus: const Value('manual'),
    ));
    await _load();
  }

  Future<void> deleteManualAccount(String id) async {
    final db = await _getDb();
    await db.accountsDao.deleteAccount(id);
    await _load();
  }

  Future<void> exportCsv() async {
    final db = await _getDb();
    final txs = await db.transactionsDao.getAllTransactions();
    final rows = [
      ['Date', 'Merchant', 'Amount', 'Category', 'AccountId', 'Note', 'Source'],
      ...txs.map((t) => [
        t.date.toIso8601String().split('T').first,
        t.merchant,
        t.amount.toString(),
        t.category,
        t.accountId,
        t.note,
        t.source,
      ]),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/finme_transactions.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'FinMe Transactions Export');
  }
}
