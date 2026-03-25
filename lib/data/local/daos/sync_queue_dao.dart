import 'package:drift/drift.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/data/local/tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase> with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<List<SyncQueueItem>> getPendingItems() =>
      (select(syncQueue)..where((s) => s.status.equals('pending'))).get();

  Future<void> enqueue(SyncQueueCompanion entry) =>
      into(syncQueue).insert(entry);

  Future<void> deleteItem(String id) =>
      (delete(syncQueue)..where((s) => s.id.equals(id))).go();

  Future<void> markFailed(String id) =>
      (update(syncQueue)..where((s) => s.id.equals(id)))
          .write(const SyncQueueCompanion(status: Value('failed')));

  Future<void> incrementRetry(String id) async {
    final item = await (select(syncQueue)..where((s) => s.id.equals(id))).getSingle();
    await (update(syncQueue)..where((s) => s.id.equals(id)))
        .write(SyncQueueCompanion(retryCount: Value(item.retryCount + 1)));
  }
}
