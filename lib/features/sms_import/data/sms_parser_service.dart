import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Parsed result from an Indian bank SMS.
class ParsedSms {
  const ParsedSms({
    required this.amount,
    required this.type,
    required this.bankName,
    required this.date,
    required this.smsHash,
    this.accountSuffix,
    this.merchant,
  });

  final double amount;
  final String type; // 'debit' | 'credit'
  final String? accountSuffix;
  final String? merchant;
  final String bankName;
  final DateTime date;
  final String smsHash;
}

/// Pure Dart SMS parser for Indian bank transaction messages.
///
/// Extracts amount, type (debit/credit), account suffix, merchant, and bank
/// name from SMS body text. Returns `null` for non-transactional messages
/// (OTPs, promos, balance alerts, non-bank SMS).
class SmsParserService {
  const SmsParserService();

  // -- Sender filter: Indian bank shortcodes like "VM-HDFCBK", "AD-SBIINB"
  static final _bankSenderPattern = RegExp(r'^[A-Z]{2}-([A-Z]{4,})$');

  // -- Amount: Rs / Rs. / INR followed by digits with optional commas and decimals
  static final _amountPattern = RegExp(
    r'(?:rs\.?|inr)\s*([0-9,]+(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );

  // -- Transaction type keywords
  static final _debitPattern = RegExp(
    r'\b(?:debited|debit|spent|paid|purchase|withdrawn|deducted|sent)\b',
    caseSensitive: false,
  );
  static final _creditPattern = RegExp(
    r'\b(?:credited|credit|received|refund|deposit|cashback)\b',
    caseSensitive: false,
  );

  // -- Account suffix patterns
  static final _accountPatterns = [
    // "a/c XXXX1234", "A/c no. XX6789", "A/C X1234", "a/c *1234"
    RegExp(
      r'(?:a\/c|ac|acct|account)\s*(?:no\.?\s*)?(?:x+|\*+|\.+)?(\d{4})',
      caseSensitive: false,
    ),
    // "Card ending 8901"
    RegExp(r'(?:card\s+ending)\s+(\d{4})', caseSensitive: false),
  ];

  // -- Merchant extraction patterns (ordered by specificity)
  static final _merchantPatterns = [
    // "Merchant: AMAZON"
    RegExp(r'Merchant:\s*([A-Za-z0-9_ ]+)', caseSensitive: false),
    // "Info: UPI/ZOMATO/ref123" → extract second segment
    RegExp(r'Info:\s*UPI/([A-Za-z0-9_ ]+)', caseSensitive: false),
    // "at NETFLIX on" or "at NETFLIX."
    RegExp(r'\bat\s+([A-Za-z0-9_ ]+?)(?:\s+on\b|\.|\s*$)', caseSensitive: false),
    // "to SWIGGY via" or "to SWIGGY on"
    RegExp(r'\bto\s+([A-Za-z0-9_ ]+?)(?:\s+(?:via|on|for)\b|\.|\s*$)', caseSensitive: false),
  ];

  // -- Rejection patterns (OTP, promo, balance, login alerts)
  static final _rejectPatterns = [
    RegExp(r'\bOTP\b', caseSensitive: false),
    RegExp(r'\bcashback\b.*\buse\s+code\b', caseSensitive: false),
    RegExp(r'\bbalance\s+is\b', caseSensitive: false),
    RegExp(r'\blogin\b.*\bdevice\b', caseSensitive: false),
    RegExp(r'\bblocked\b', caseSensitive: false),
    RegExp(r'\bT&C\s+apply\b', caseSensitive: false),
  ];

  /// Parses a single SMS message. Returns `null` if the message is not a
  /// recognizable bank transaction SMS.
  ParsedSms? parse(String sender, String body, DateTime timestamp) {
    // 1. Filter: only process messages from bank shortcodes
    final senderMatch = _bankSenderPattern.firstMatch(sender);
    if (senderMatch == null) return null;
    final bankName = senderMatch.group(1)!;

    // 2. Reject non-transactional messages
    for (final pattern in _rejectPatterns) {
      if (pattern.hasMatch(body)) return null;
    }

    // 3. Extract amount — required
    final amountMatch = _amountPattern.firstMatch(body);
    if (amountMatch == null) return null;
    final amount = _parseAmount(amountMatch.group(1)!);

    // 4. Determine debit vs credit — required
    final isDebit = _debitPattern.hasMatch(body);
    final isCredit = _creditPattern.hasMatch(body);
    if (!isDebit && !isCredit) return null;
    // If both match (e.g. "refund credited to debited account"), prefer the
    // keyword that appears first in the body.
    final String type;
    if (isDebit && isCredit) {
      final debitPos = _debitPattern.firstMatch(body)!.start;
      final creditPos = _creditPattern.firstMatch(body)!.start;
      type = debitPos < creditPos ? 'debit' : 'credit';
    } else {
      type = isDebit ? 'debit' : 'credit';
    }

    // 5. Extract account suffix (optional)
    final accountSuffix = _extractAccountSuffix(body);

    // 6. Extract merchant (optional)
    final merchant = _extractMerchant(body);

    // 7. Compute dedup hash
    final smsHash = _computeHash(sender, body, timestamp);

    return ParsedSms(
      amount: amount,
      type: type,
      accountSuffix: accountSuffix,
      merchant: merchant,
      bankName: bankName,
      date: timestamp,
      smsHash: smsHash,
    );
  }

  /// Parses an amount string like "1,23,456.00" → 123456.0.
  /// Handles both Indian (lakh/crore) and standard comma grouping.
  double _parseAmount(String raw) {
    final cleaned = raw.replaceAll(',', '');
    return double.parse(cleaned);
  }

  String? _extractAccountSuffix(String body) {
    for (final pattern in _accountPatterns) {
      final match = pattern.firstMatch(body);
      if (match != null) return match.group(1);
    }
    return null;
  }

  String? _extractMerchant(String body) {
    for (final pattern in _merchantPatterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final raw = match.group(1)!.trim();
        if (raw.isNotEmpty) return raw;
      }
    }
    return null;
  }

  /// SHA-256 of "sender|body|timestamp" for deduplication.
  String _computeHash(String sender, String body, DateTime timestamp) {
    final input = '$sender|$body|${timestamp.toIso8601String()}';
    return sha256.convert(utf8.encode(input)).toString();
  }
}
