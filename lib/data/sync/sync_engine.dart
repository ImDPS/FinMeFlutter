import 'package:finme/data/local/database.dart';
import 'package:finme/data/sync/firestore_service.dart';

const int _kMaxRetries = 3;

class SyncEngine {
  SyncEngine({required AppDatabase db, required FirestoreService firestoreService})
      : _db = db,
        _firestoreService = firestoreService;

  final AppDatabase _db;
  final FirestoreService _firestoreService;

  /// Flush all pending sync-queue items to Firestore.
  /// Items that succeed are deleted. Items that fail increment their retryCount.
  /// Items that exceed _kMaxRetries are marked as 'failed'.
  Future<void> flush() async {
    final pending = await _db.syncQueueDao.getPendingItems();
    for (final item in pending) {
      try {
        await _firestoreService.pushOperation(
          operation: item.operation,
          payload: item.payload,
        );
        await _db.syncQueueDao.deleteItem(item.id);
      } catch (_) {
        await _db.syncQueueDao.incrementRetry(item.id);
        if (item.retryCount + 1 >= _kMaxRetries) {
          await _db.syncQueueDao.markFailed(item.id);
        }
      }
    }
  }
}
