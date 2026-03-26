import 'package:finme/data/local/database.dart';

class NetWorthRepository {
  NetWorthRepository({required AppDatabase db}) : _db = db;
  final AppDatabase _db;

  Future<int> getTotalNetWorth() async {
    final accounts = await _db.accountsDao.getAllAccounts();
    return accounts.fold<int>(0, (sum, a) => sum + a.balance);
  }

  Future<int> getTotalAssets() async {
    final accounts = await _db.accountsDao.getAllAccounts();
    return accounts.where((a) => a.balance > 0).fold<int>(0, (sum, a) => sum + a.balance);
  }

  Future<int> getTotalLiabilities() async {
    final accounts = await _db.accountsDao.getAllAccounts();
    return accounts.where((a) => a.balance < 0).fold<int>(0, (sum, a) => sum + a.balance.abs());
  }

  Future<Map<String, List<Account>>> getAccountsByType() async {
    final accounts = await _db.accountsDao.getAllAccounts();
    final grouped = <String, List<Account>>{};
    for (final a in accounts) {
      (grouped[a.type] ??= []).add(a);
    }
    return grouped;
  }
}
