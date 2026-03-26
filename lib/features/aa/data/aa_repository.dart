import 'package:drift/drift.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/features/aa/data/setu_service.dart';

class AaRepository {
  AaRepository({required AppDatabase db, required SetuService setuService})
      : _db = db,
        _setuService = setuService;

  final AppDatabase _db;
  final SetuService _setuService;

  Future<String> initiateConsent({required String phoneNumber}) =>
      _setuService.createConsentRequest(phoneNumber: phoneNumber);

  /// Called when Setu AA redirect returns with accountId + consentStatus.
  Future<void> onConsentGranted({
    required String accountId,
    required String accountName,
    required String institution,
  }) async {
    await _db.accountsDao.insertAccount(
      AccountsCompanion.insert(
        id: accountId,
        name: accountName,
        type: 'savings',
        institution: institution,
        consentStatus: const Value('active'),
      ),
    );
  }
}
