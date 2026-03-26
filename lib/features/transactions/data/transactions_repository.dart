import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:finme/data/local/database.dart';

const _uuid = Uuid();

class TransactionsRepository {
  TransactionsRepository({required AppDatabase db}) : _db = db;
  final AppDatabase _db;

  Future<void> addTransaction({
    required String accountId,
    required int amount,
    required String merchant,
    required String category,
    required DateTime date,
    String note = '',
    String source = 'manual',
  }) async {
    await _db.transactionsDao.insertTransaction(
      TransactionsCompanion.insert(
        id: _uuid.v4(),
        accountId: accountId,
        amount: amount,
        merchant: merchant,
        category: Value(category),
        date: date,
        note: Value(note),
        source: source,
      ),
    );
  }

  Future<List<Transaction>> getTransactionsForMonth(int year, int month) =>
      _db.transactionsDao.getTransactionsForMonth(year, month);

  Future<List<Transaction>> getAllTransactions() =>
      _db.transactionsDao.getAllTransactions();

  Future<void> deleteTransaction(String id) =>
      _db.transactionsDao.deleteTransaction(id);
}
