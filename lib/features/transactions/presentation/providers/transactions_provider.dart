import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/features/transactions/data/transactions_repository.dart';

part 'transactions_provider.g.dart';

typedef TransactionList = List<Transaction>;

@riverpod
TransactionsRepository transactionsRepository(Ref ref) =>
    TransactionsRepository(db: AppDatabase.forTesting());

@riverpod
class TransactionsNotifier extends _$TransactionsNotifier {
  @override
  Future<TransactionList> build() async {
    return ref.read(transactionsRepositoryProvider).getAllTransactions();
  }

  Future<void> add({
    required String accountId,
    required int amount,
    required String merchant,
    required String category,
    required DateTime date,
    String note = '',
  }) async {
    await ref.read(transactionsRepositoryProvider).addTransaction(
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
    await ref.read(transactionsRepositoryProvider).deleteTransaction(id);
    ref.invalidateSelf();
  }
}
