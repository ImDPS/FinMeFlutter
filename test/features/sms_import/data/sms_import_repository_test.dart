import 'package:flutter_test/flutter_test.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/features/sms_import/data/sms_import_repository.dart';

void main() {
  late AppDatabase db;
  late SmsImportRepository repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = SmsImportRepository(db: db);
  });

  tearDown(() async => db.close());

  List<SmsMessage> sampleMessages() => [
        SmsMessage(
          sender: 'VM-HDFCBK',
          body:
              'Your a/c XXXX1234 has been debited for Rs 500.00 on 25-03-26. Info: UPI/ZOMATO/ref123',
          timestamp: DateTime(2026, 3, 25),
        ),
        SmsMessage(
          sender: 'AD-SBIINB',
          body:
              'Dear Customer, Your A/c no. XX6789 credited by Rs.5,000.00 on 25Mar26 by NEFT Ref No: N123.',
          timestamp: DateTime(2026, 3, 25),
        ),
      ];

  group('SmsImportRepository', () {
    group('importFromSms', () {
      test('imports valid bank SMS as transactions', () async {
        final count = await repo.importFromSms(sampleMessages());

        expect(count, 2);
        final transactions = await db.transactionsDao.getAllTransactions();
        expect(transactions, hasLength(2));
      });

      test('sets source to sms_import', () async {
        await repo.importFromSms(sampleMessages());

        final transactions = await db.transactionsDao.getAllTransactions();
        for (final t in transactions) {
          expect(t.source, 'sms_import');
        }
      });

      test('stores smsHash for each imported transaction', () async {
        await repo.importFromSms(sampleMessages());

        final transactions = await db.transactionsDao.getAllTransactions();
        for (final t in transactions) {
          expect(t.smsHash, isNotNull);
          expect(t.smsHash, isNotEmpty);
        }
      });

      test('stores debit amounts as negative', () async {
        await repo.importFromSms([
          SmsMessage(
            sender: 'VM-HDFCBK',
            body: 'Your a/c XX1234 has been debited for Rs 500.00.',
            timestamp: DateTime(2026, 3, 25),
          ),
        ]);

        final transactions = await db.transactionsDao.getAllTransactions();
        expect(transactions.first.amount, -500);
      });

      test('stores credit amounts as positive', () async {
        await repo.importFromSms([
          SmsMessage(
            sender: 'AD-SBIINB',
            body: 'Your A/c XX6789 credited by Rs.5,000.00.',
            timestamp: DateTime(2026, 3, 25),
          ),
        ]);

        final transactions = await db.transactionsDao.getAllTransactions();
        expect(transactions.first.amount, 5000);
      });

      test('sets category to uncategorized', () async {
        await repo.importFromSms(sampleMessages());

        final transactions = await db.transactionsDao.getAllTransactions();
        for (final t in transactions) {
          expect(t.category, 'uncategorized');
        }
      });

      test('skips non-parseable SMS and returns only successful count',
          () async {
        final messages = [
          ...sampleMessages(),
          SmsMessage(
            sender: '+919876543210',
            body: 'Hey, dinner tonight?',
            timestamp: DateTime(2026, 3, 25),
          ),
        ];

        final count = await repo.importFromSms(messages);
        expect(count, 2);
      });
    });

    group('deduplication', () {
      test('importing same SMS twice returns 0 on second call', () async {
        final messages = sampleMessages();

        final first = await repo.importFromSms(messages);
        expect(first, 2);

        final second = await repo.importFromSms(messages);
        expect(second, 0);

        final transactions = await db.transactionsDao.getAllTransactions();
        expect(transactions, hasLength(2));
      });

      test('importing mix of new and existing returns only new count',
          () async {
        await repo.importFromSms([sampleMessages().first]);

        final count = await repo.importFromSms(sampleMessages());
        expect(count, 1);
      });
    });

    group('getImportedSmsHashes', () {
      test('returns empty list when no imports exist', () async {
        final hashes = await repo.getImportedSmsHashes();
        expect(hashes, isEmpty);
      });

      test('returns hashes after import', () async {
        await repo.importFromSms(sampleMessages());

        final hashes = await repo.getImportedSmsHashes();
        expect(hashes, hasLength(2));
        for (final hash in hashes) {
          expect(hash, isNotEmpty);
        }
      });
    });
  });
}
