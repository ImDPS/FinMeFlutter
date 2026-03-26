import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/data/sync/firestore_service.dart';
import 'package:finme/data/sync/sync_engine.dart';

const String kBackgroundSyncTask = 'finme.background_sync';

/// Wraps SyncEngine for WorkManager background execution.
class BackgroundSyncWorker {
  BackgroundSyncWorker({required SyncEngine syncEngine}) : _syncEngine = syncEngine;
  final SyncEngine _syncEngine;

  Future<void> execute() async {
    await _syncEngine.flush();
  }
}

/// Top-level callback dispatcher required by WorkManager.
/// Must be annotated @pragma('vm:entry-point') so tree-shaker preserves it.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == kBackgroundSyncTask) {
      // Background isolate: no Riverpod, so initialize DB + services manually.
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dir.path, 'finme.db');

      const storage = FlutterSecureStorage();
      final key = await storage.read(key: 'db_encryption_key');
      if (key == null) return true; // No DB key yet — nothing to sync

      final db = AppDatabase(
        DatabaseConnection(
          NativeDatabase(
            File(dbPath),
            setup: (rawDb) {
              rawDb.execute("PRAGMA key = '$key'");
            },
          ),
        ),
      );

      try {
        final syncEngine = SyncEngine(
          db: db,
          firestoreService: FirestoreService(),
        );
        await syncEngine.flush();
      } finally {
        await db.close();
      }
    }
    return true;
  });
}

/// Registers the 24hr periodic background sync task.
/// Call once from main() after WidgetsFlutterBinding.ensureInitialized().
Future<void> registerBackgroundSync() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    kBackgroundSyncTask,
    kBackgroundSyncTask,
    frequency: const Duration(hours: 24),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}
