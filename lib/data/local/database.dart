import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
// ignore: unused_import
import 'package:drift_flutter/drift_flutter.dart';
import 'package:finme/data/local/tables/accounts_table.dart';
import 'package:finme/data/local/tables/transactions_table.dart';
import 'package:finme/data/local/tables/budgets_table.dart';
import 'package:finme/data/local/tables/net_worth_table.dart';
import 'package:finme/data/local/tables/sync_queue_table.dart';
import 'package:finme/data/local/tables/user_settings_table.dart';
import 'package:finme/data/local/daos/accounts_dao.dart';
import 'package:finme/data/local/daos/transactions_dao.dart';
import 'package:finme/data/local/daos/budgets_dao.dart';
import 'package:finme/data/local/daos/net_worth_dao.dart';
import 'package:finme/data/local/daos/sync_queue_dao.dart';
import 'package:finme/data/local/daos/user_settings_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Accounts,
    Transactions,
    Budgets,
    NetWorthSnapshots,
    SyncQueue,
    UserSettings,
  ],
  daos: [
    AccountsDao,
    TransactionsDao,
    BudgetsDao,
    NetWorthDao,
    SyncQueueDao,
    UserSettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  /// In-memory database for unit tests (no SQLCipher needed in tests)
  factory AppDatabase.forTesting() {
    return AppDatabase(DatabaseConnection(NativeDatabase.memory()));
  }

  /// Generates a cryptographically random 256-bit hex key
  static String generateEncryptionKey() {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
