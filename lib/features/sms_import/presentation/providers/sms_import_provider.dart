import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finme/data/local/database_provider.dart';
import 'package:finme/features/sms_import/data/sms_import_repository.dart';

part 'sms_import_provider.g.dart';

enum SmsImportStatus { idle, importing, done, error }

/// Immutable state for SMS import.
class SmsImportState {
  const SmsImportState({
    this.status = SmsImportStatus.idle,
    this.importedCount = 0,
    this.error,
  });

  final SmsImportStatus status;
  final int importedCount;
  final String? error;

  SmsImportState copyWith({
    SmsImportStatus? status,
    int? importedCount,
    String? error,
  }) {
    return SmsImportState(
      status: status ?? this.status,
      importedCount: importedCount ?? this.importedCount,
      error: error,
    );
  }
}

@riverpod
Future<SmsImportRepository> smsImportRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return SmsImportRepository(db: db);
}

@riverpod
class SmsImportNotifier extends _$SmsImportNotifier {
  @override
  SmsImportState build() => const SmsImportState();

  /// Import transactions from a list of SMS messages.
  /// Call this after reading SMS from the device via the `telephony` package.
  Future<void> importSms(List<SmsMessage> messages) async {
    state = state.copyWith(status: SmsImportStatus.importing);
    try {
      final repo = await ref.read(smsImportRepositoryProvider.future);
      final count = await repo.importFromSms(messages);
      state = state.copyWith(
        status: SmsImportStatus.done,
        importedCount: count,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        status: SmsImportStatus.error,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const SmsImportState();
  }
}
