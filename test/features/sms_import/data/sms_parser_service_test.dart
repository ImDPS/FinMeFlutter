import 'package:flutter_test/flutter_test.dart';
import 'package:finme/features/sms_import/data/sms_parser_service.dart';

void main() {
  late SmsParserService parser;

  setUp(() {
    parser = const SmsParserService();
  });

  group('SmsParserService.parse', () {
    group('debit transactions', () {
      test('parses HDFC debit SMS with Indian number format', () {
        final result = parser.parse(
          'VM-HDFCBK',
          'Your a/c XXXX1234 has been debited for Rs 1,23,456.00 on 25-03-26. Info: UPI/ZOMATO/ref123',
          DateTime(2026, 3, 25),
        );

        expect(result, isNotNull);
        expect(result!.amount, 123456.0);
        expect(result.type, 'debit');
        expect(result.accountSuffix, '1234');
        expect(result.bankName, 'HDFCBK');
        expect(result.smsHash, isNotEmpty);
      });

      test('parses ICICI debit SMS', () {
        final result = parser.parse(
          'JD-ICICIB',
          'ICICI Bank Acct XX4567 debited Rs. 2,500 on 25-Mar-26; Merchant: AMAZON. Avl Bal: Rs. 50,000',
          DateTime(2026, 3, 25),
        );

        expect(result, isNotNull);
        expect(result!.amount, 2500.0);
        expect(result.type, 'debit');
        expect(result.accountSuffix, '4567');
        expect(result.merchant, isNotNull);
      });

      test('parses Axis "spent" SMS', () {
        final result = parser.parse(
          'BZ-AXISBK',
          'Rs 999.00 spent on Axis Bank Card ending 8901 at NETFLIX on 25-03-2026.',
          DateTime(2026, 3, 25),
        );

        expect(result, isNotNull);
        expect(result!.amount, 999.0);
        expect(result.type, 'debit');
      });

      test('parses Kotak "Paid" SMS with UPI', () {
        final result = parser.parse(
          'BW-KOTAKB',
          'Paid Rs.350 from Kotak Bank A/C X1234 to SWIGGY via UPI on 25/03/26. Ref 456789',
          DateTime(2026, 3, 25),
        );

        expect(result, isNotNull);
        expect(result!.amount, 350.0);
        expect(result.type, 'debit');
        expect(result.accountSuffix, '1234');
      });

      test('parses "withdrawn" SMS', () {
        final result = parser.parse(
          'AD-SBIINB',
          'Dear Customer, Rs.10,000 has been withdrawn from your A/c no. XX6789 on 25-Mar-26 at ATM.',
          DateTime(2026, 3, 25),
        );

        expect(result, isNotNull);
        expect(result!.amount, 10000.0);
        expect(result.type, 'debit');
        expect(result.accountSuffix, '6789');
      });
    });

    group('credit transactions', () {
      test('parses SBI credit SMS', () {
        final result = parser.parse(
          'AD-SBIINB',
          'Dear Customer, Your A/c no. XX6789 credited by Rs.5,000.00 on 25Mar26 by NEFT Ref No: N123.',
          DateTime(2026, 3, 25),
        );

        expect(result, isNotNull);
        expect(result!.amount, 5000.0);
        expect(result.type, 'credit');
        expect(result.accountSuffix, '6789');
        expect(result.bankName, 'SBIINB');
      });

      test('parses "received" SMS', () {
        final result = parser.parse(
          'VM-HDFCBK',
          'Rs 25,000 received in your a/c XXXX5678 via NEFT from JOHN DOE on 25-03-26.',
          DateTime(2026, 3, 25),
        );

        expect(result, isNotNull);
        expect(result!.amount, 25000.0);
        expect(result.type, 'credit');
        expect(result.accountSuffix, '5678');
      });

      test('parses "refund" SMS', () {
        final result = parser.parse(
          'JD-ICICIB',
          'Refund of Rs.499.00 credited to your ICICI Bank Acct XX4567 on 25-Mar-26 for order #123.',
          DateTime(2026, 3, 25),
        );

        expect(result, isNotNull);
        expect(result!.amount, 499.0);
        expect(result.type, 'credit');
      });
    });

    group('amount parsing', () {
      test('handles Indian lakh format (1,23,456.00)', () {
        final result = parser.parse(
          'VM-HDFCBK',
          'Your a/c XX1234 debited Rs 1,23,456.00.',
          DateTime(2026, 3, 25),
        );

        expect(result, isNotNull);
        expect(result!.amount, 123456.0);
      });

      test('handles crore format (1,00,00,000)', () {
        final result = parser.parse(
          'VM-HDFCBK',
          'Your a/c XX1234 debited Rs 1,00,00,000.00.',
          DateTime(2026, 3, 25),
        );

        expect(result, isNotNull);
        expect(result!.amount, 10000000.0);
      });

      test('handles amount without decimals', () {
        final result = parser.parse(
          'VM-HDFCBK',
          'Your a/c XX1234 debited Rs 500.',
          DateTime(2026, 3, 25),
        );

        expect(result, isNotNull);
        expect(result!.amount, 500.0);
      });

      test('handles INR prefix', () {
        final result = parser.parse(
          'VM-HDFCBK',
          'Your a/c XX1234 debited INR 2,500.50.',
          DateTime(2026, 3, 25),
        );

        expect(result, isNotNull);
        expect(result!.amount, 2500.50);
      });

      test('handles amount with single decimal place', () {
        final result = parser.parse(
          'VM-HDFCBK',
          'Your a/c XX1234 debited Rs.99.5.',
          DateTime(2026, 3, 25),
        );

        expect(result, isNotNull);
        expect(result!.amount, 99.5);
      });
    });

    group('account suffix extraction', () {
      test('extracts from "a/c XXXX1234"', () {
        final result = parser.parse(
          'VM-HDFCBK',
          'Your a/c XXXX1234 debited Rs 500.',
          DateTime(2026, 3, 25),
        );
        expect(result?.accountSuffix, '1234');
      });

      test('extracts from "A/c no. XX6789"', () {
        final result = parser.parse(
          'AD-SBIINB',
          'Your A/c no. XX6789 credited Rs.500.',
          DateTime(2026, 3, 25),
        );
        expect(result?.accountSuffix, '6789');
      });

      test('extracts from "Acct XX4567"', () {
        final result = parser.parse(
          'JD-ICICIB',
          'ICICI Bank Acct XX4567 debited Rs 500.',
          DateTime(2026, 3, 25),
        );
        expect(result?.accountSuffix, '4567');
      });

      test('extracts from "A/C X1234"', () {
        final result = parser.parse(
          'BW-KOTAKB',
          'Kotak Bank A/C X1234 debited Rs 500.',
          DateTime(2026, 3, 25),
        );
        expect(result?.accountSuffix, '1234');
      });

      test('extracts from "Card ending 8901"', () {
        final result = parser.parse(
          'BZ-AXISBK',
          'Rs 500 spent on Card ending 8901 at AMAZON.',
          DateTime(2026, 3, 25),
        );
        expect(result?.accountSuffix, '8901');
      });

      test('extracts from "a/c *1234"', () {
        final result = parser.parse(
          'VM-HDFCBK',
          'Your a/c *1234 debited Rs 500.',
          DateTime(2026, 3, 25),
        );
        expect(result?.accountSuffix, '1234');
      });
    });

    group('merchant extraction', () {
      test('extracts merchant after "at"', () {
        final result = parser.parse(
          'BZ-AXISBK',
          'Rs 999.00 spent on Axis Bank Card ending 8901 at NETFLIX on 25-03-2026.',
          DateTime(2026, 3, 25),
        );
        expect(result?.merchant, isNotNull);
        expect(result!.merchant!.toUpperCase(), contains('NETFLIX'));
      });

      test('extracts merchant after "to"', () {
        final result = parser.parse(
          'BW-KOTAKB',
          'Paid Rs.350 from Kotak Bank A/C X1234 to SWIGGY via UPI on 25/03/26.',
          DateTime(2026, 3, 25),
        );
        expect(result?.merchant, isNotNull);
        expect(result!.merchant!.toUpperCase(), contains('SWIGGY'));
      });

      test('extracts merchant from UPI Info field', () {
        final result = parser.parse(
          'VM-HDFCBK',
          'Your a/c XXXX1234 has been debited for Rs 500.00. Info: UPI/ZOMATO/ref123',
          DateTime(2026, 3, 25),
        );
        expect(result?.merchant, isNotNull);
        expect(result!.merchant!.toUpperCase(), contains('ZOMATO'));
      });

      test('extracts merchant after "Merchant:"', () {
        final result = parser.parse(
          'JD-ICICIB',
          'ICICI Bank Acct XX4567 debited Rs. 2,500; Merchant: AMAZON.',
          DateTime(2026, 3, 25),
        );
        expect(result?.merchant, isNotNull);
        expect(result!.merchant!.toUpperCase(), contains('AMAZON'));
      });
    });

    group('bank name extraction', () {
      test('extracts HDFCBK from VM-HDFCBK', () {
        final result = parser.parse(
          'VM-HDFCBK',
          'Your a/c XX1234 debited Rs 500.',
          DateTime(2026, 3, 25),
        );
        expect(result?.bankName, 'HDFCBK');
      });

      test('extracts SBIINB from AD-SBIINB', () {
        final result = parser.parse(
          'AD-SBIINB',
          'Your A/c XX1234 credited Rs.500.',
          DateTime(2026, 3, 25),
        );
        expect(result?.bankName, 'SBIINB');
      });

      test('extracts ICICIB from JD-ICICIB', () {
        final result = parser.parse(
          'JD-ICICIB',
          'ICICI Bank Acct XX1234 debited Rs 500.',
          DateTime(2026, 3, 25),
        );
        expect(result?.bankName, 'ICICIB');
      });
    });

    group('hash generation', () {
      test('same SMS produces same hash', () {
        final result1 = parser.parse(
          'VM-HDFCBK',
          'Your a/c XX1234 debited Rs 500.',
          DateTime(2026, 3, 25),
        );
        final result2 = parser.parse(
          'VM-HDFCBK',
          'Your a/c XX1234 debited Rs 500.',
          DateTime(2026, 3, 25),
        );
        expect(result1?.smsHash, result2?.smsHash);
      });

      test('different SMS produces different hash', () {
        final result1 = parser.parse(
          'VM-HDFCBK',
          'Your a/c XX1234 debited Rs 500.',
          DateTime(2026, 3, 25),
        );
        final result2 = parser.parse(
          'VM-HDFCBK',
          'Your a/c XX1234 debited Rs 1000.',
          DateTime(2026, 3, 25),
        );
        expect(result1?.smsHash, isNot(result2?.smsHash));
      });
    });

    group('rejected messages', () {
      test('returns null for OTP messages', () {
        final result = parser.parse(
          'VM-HDFCBK',
          'Your OTP for transaction is 123456. Do not share with anyone.',
          DateTime(2026, 3, 25),
        );
        expect(result, isNull);
      });

      test('returns null for promotional SMS', () {
        final result = parser.parse(
          'VM-HDFCBK',
          'Get 10% cashback on your next purchase! Use code HDFC10. T&C apply.',
          DateTime(2026, 3, 25),
        );
        expect(result, isNull);
      });

      test('returns null for balance enquiry SMS', () {
        final result = parser.parse(
          'VM-HDFCBK',
          'Your a/c XXXX1234 balance is Rs 50,000.00 as on 25-03-26.',
          DateTime(2026, 3, 25),
        );
        expect(result, isNull);
      });

      test('returns null for non-bank SMS', () {
        final result = parser.parse(
          '+919876543210',
          'Hey, are you free for dinner tonight?',
          DateTime(2026, 3, 25),
        );
        expect(result, isNull);
      });

      test('returns null for SMS without amount', () {
        final result = parser.parse(
          'VM-HDFCBK',
          'Your a/c XXXX1234 has been blocked. Contact customer care.',
          DateTime(2026, 3, 25),
        );
        expect(result, isNull);
      });

      test('returns null for login alert SMS', () {
        final result = parser.parse(
          'VM-HDFCBK',
          'Alert: Login to your HDFC Bank NetBanking from new device on 25-03-26.',
          DateTime(2026, 3, 25),
        );
        expect(result, isNull);
      });
    });

    group('date handling', () {
      test('uses provided timestamp as date', () {
        final timestamp = DateTime(2026, 3, 25, 14, 30);
        final result = parser.parse(
          'VM-HDFCBK',
          'Your a/c XX1234 debited Rs 500.',
          timestamp,
        );
        expect(result?.date, timestamp);
      });
    });
  });
}
