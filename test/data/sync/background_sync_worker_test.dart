import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:finme/data/sync/sync_engine.dart';
import 'package:finme/data/sync/background_sync_worker.dart';

class MockSyncEngine extends Mock implements SyncEngine {}

void main() {
  late BackgroundSyncWorker worker;
  late MockSyncEngine mockEngine;

  setUp(() {
    mockEngine = MockSyncEngine();
    worker = BackgroundSyncWorker(syncEngine: mockEngine);
  });

  test('execute calls flush on SyncEngine', () async {
    when(() => mockEngine.flush()).thenAnswer((_) async {});
    await worker.execute();
    verify(() => mockEngine.flush()).called(1);
  });
}
