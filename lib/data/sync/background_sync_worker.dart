import 'package:workmanager/workmanager.dart';
import 'package:finme/data/sync/sync_engine.dart';

const String kAARefreshTask = 'finme.aa_refresh';

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
    if (task == kAARefreshTask) {
      // In production: initialize AppDatabase + SyncEngine + FirestoreService here
      // For now, we register the task but skip heavy init in the background isolate
    }
    return true;
  });
}

/// Registers the 24hr periodic background sync task.
/// Call once from main() after WidgetsFlutterBinding.ensureInitialized().
Future<void> registerBackgroundSync() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    kAARefreshTask,
    kAARefreshTask,
    frequency: const Duration(hours: 24),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}
