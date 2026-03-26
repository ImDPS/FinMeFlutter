import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/data/local/database_provider.dart';
import 'package:finme/features/transactions/data/transactions_repository.dart';

part 'transactions_provider.g.dart';

typedef TransactionList = List<Transaction>;

@riverpod
Future<TransactionsRepository> transactionsRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return TransactionsRepository(db: db);
}

@riverpod
class TransactionsNotifier extends _$TransactionsNotifier {
  @override
  Future<TransactionList> build() async {
    final repo = await ref.read(transactionsRepositoryProvider.future);
    return repo.getAllTransactions();
  }

  Future<void> add({
    required String accountId,
    required int amount,
    required String merchant,
    required String category,
    required DateTime date,
    String note = '',
  }) async {
    final repo = await ref.read(transactionsRepositoryProvider.future);
    await repo.addTransaction(
      accountId: accountId,
      amount: amount,
      merchant: merchant,
      category: category,
      date: date,
      note: note,
    );
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    final repo = await ref.read(transactionsRepositoryProvider.future);
    await repo.deleteTransaction(id);
    ref.invalidateSelf();
  }
}
