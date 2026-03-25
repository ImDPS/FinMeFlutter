import 'package:flutter_test/flutter_test.dart';
import 'package:finme/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats thousands correctly', () {
      expect(CurrencyFormatter.format(1000), '₹1,000');
    });

    test('formats lakhs in Indian system', () {
      expect(CurrencyFormatter.format(123456), '₹1,23,456');
    });

    test('formats crores correctly', () {
      expect(CurrencyFormatter.format(10000000), '₹1,00,00,000');
    });

    test('handles zero', () {
      expect(CurrencyFormatter.format(0), '₹0');
    });

    test('handles negative (debit)', () {
      expect(CurrencyFormatter.format(-5000), '-₹5,000');
    });
  });
}
