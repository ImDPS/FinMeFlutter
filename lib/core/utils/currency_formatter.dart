import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Formats an integer amount using Indian number system.
  /// e.g. 123456 → ₹1,23,456
  static String format(int amountInRupees) {
    if (amountInRupees < 0) {
      return '-${_inrFormat.format(amountInRupees.abs())}';
    }
    return _inrFormat.format(amountInRupees);
  }
}
