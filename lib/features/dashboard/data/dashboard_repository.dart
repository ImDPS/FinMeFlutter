import 'package:finme/data/local/database.dart';

class DashboardRepository {
  DashboardRepository({required AppDatabase db}) : _db = db;
  final AppDatabase _db;

  Future<int> totalBalanceInr() async {
    final accounts = await _db.accountsDao.getAllAccounts();
    return accounts.fold<int>(0, (sum, a) => sum + a.balance);
  }

  Future<int> currentMonthSpend() async {
    final now = DateTime.now();
    final txs = await _db.transactionsDao.getTransactionsForMonth(now.year, now.month);
    final debits = txs.where((t) => t.amount < 0);
    return debits.fold<int>(0, (sum, t) => sum + t.amount.abs());
  }

  Future<int> currentMonthIncome() async {
    final now = DateTime.now();
    final txs = await _db.transactionsDao.getTransactionsForMonth(now.year, now.month);
    final credits = txs.where((t) => t.amount > 0);
    return credits.fold<int>(0, (sum, t) => sum + t.amount);
  }

  Future<Map<String, int>> topCategoriesThisMonth() async {
    final now = DateTime.now();
    final txs = await _db.transactionsDao.getTransactionsForMonth(now.year, now.month);
    final debits = txs.where((t) => t.amount < 0);
    final grouped = <String, int>{};
    for (final t in debits) {
      grouped[t.category] = (grouped[t.category] ?? 0) + t.amount.abs();
    }
    final sorted = grouped.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(3));
  }

  Future<List<Transaction>> recentTransactions({int limit = 5}) =>
      _db.transactionsDao.getRecentTransactions(limit: limit);
}
