import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/features/sms_import/data/sms_parser_service.dart';

const _uuid = Uuid();

/// Platform-agnostic SMS message container.
/// Decouples from the `telephony` package so tests can use plain data.
class SmsMessage {
  const SmsMessage({
    required this.sender,
    required this.body,
    required this.timestamp,
  });

  final String sender;
  final String body;
  final DateTime timestamp;
}

/// Orchestrates SMS parsing, deduplication, and transaction import.
class SmsImportRepository {
  SmsImportRepository({required AppDatabase db}) : _db = db;

  final AppDatabase _db;
  final SmsParserService _parser = const SmsParserService();

  /// Parses [messages], deduplicates against existing imports, and inserts
  /// new transactions. Returns the count of newly imported transactions.
  Future<int> importFromSms(List<SmsMessage> messages) async {
    final existingHashes = await _db.transactionsDao.getAllSmsHashes();
    var imported = 0;

    for (final msg in messages) {
      final parsed = _parser.parse(msg.sender, msg.body, msg.timestamp);
      if (parsed == null) continue;
      if (existingHashes.contains(parsed.smsHash)) continue;

      final amount = parsed.type == 'debit'
          ? -parsed.amount.truncate()
          : parsed.amount.truncate();

      await _db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: _uuid.v4(),
          accountId: parsed.accountSuffix ?? 'unknown',
          amount: amount,
          merchant: parsed.merchant ?? parsed.bankName,
          category: const Value('uncategorized'),
          date: parsed.date,
          note: Value(msg.body),
          source: 'sms_import',
          smsHash: Value(parsed.smsHash),
        ),
      );

      existingHashes.add(parsed.smsHash);
      imported++;
    }

    return imported;
  }

  /// Returns all SMS hashes already stored in the transactions table.
  Future<List<String>> getImportedSmsHashes() async {
    final hashes = await _db.transactionsDao.getAllSmsHashes();
    return hashes.toList();
  }
}
