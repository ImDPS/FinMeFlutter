import 'package:drift/drift.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/data/local/tables/accounts_table.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase> with _$AccountsDaoMixin {
  AccountsDao(super.db);

  Future<List<Account>> getAllAccounts() => select(accounts).get();
  Stream<List<Account>> watchAllAccounts() => select(accounts).watch();
  Future<void> insertAccount(AccountsCompanion entry) =>
      into(accounts).insertOnConflictUpdate(entry);
  Future<void> deleteAccount(String id) =>
      (delete(accounts)..where((t) => t.id.equals(id))).go();
}
