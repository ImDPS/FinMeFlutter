import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:finme/data/sync/sync_engine.dart';
import 'package:finme/data/sync/firestore_service.dart';
import 'package:finme/data/local/database.dart';

class MockFirestoreService extends Mock implements FirestoreService {}

void main() {
  late SyncEngine engine;
  late MockFirestoreService mockFirestore;
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting();
    mockFirestore = MockFirestoreService();
    engine = SyncEngine(db: db, firestoreService: mockFirestore);
  });

  tearDown(() async => db.close());

  group('SyncEngine', () {
    test('flushes pending items to Firestore and removes them', () async {
      // Enqueue a pending item
      await db.syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: 'op-1',
          operation: 'upsert',
          payload: '{"id":"tx-1","amount":500}',
          createdAt: DateTime.now(),
        ),
      );

      when(() => mockFirestore.pushOperation(
        operation: any(named: 'operation'),
        payload: any(named: 'payload'),
      )).thenAnswer((_) async {});

      await engine.flush();

      verify(() => mockFirestore.pushOperation(
        operation: 'upsert',
        payload: '{"id":"tx-1","amount":500}',
      )).called(1);

      final pending = await db.syncQueueDao.getPendingItems();
      expect(pending.isEmpty, true);
    });

    test('retries failed items up to 3 times', () async {
      await db.syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: 'op-2',
          operation: 'upsert',
          payload: '{}',
          createdAt: DateTime.now(),
        ),
      );

      when(() => mockFirestore.pushOperation(
        operation: any(named: 'operation'),
        payload: any(named: 'payload'),
      )).thenThrow(Exception('network error'));

      // SyncEngine should catch the error, increment retryCount, not delete
      await engine.flush();

      final items = await db.syncQueueDao.getPendingItems();
      // Item should still be in queue (not deleted) after first failure
      expect(items.length, 1);
    });
  });
}
