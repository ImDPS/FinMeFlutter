# Prompt: Replace Setu AA with SMS-Based Transaction Import

> Copy-paste this entire prompt into a new Claude Code session.

---

## Context

FinMe is a personal finance app for the Indian market. We've decided to **remove the Setu Account Aggregator (AA) integration** because it requires company registration with RBI, which is unnecessary for a personal-use app. We're replacing it with **SMS-based transaction import** — parsing bank SMS messages on-device using regex patterns.

**All planning docs have already been updated** (CLAUDE.md, DEVELOPMENT_CONTEXT.md, spec, plan, FIREBASE_SETUP.md). The codebase still has the old AA code that needs to be replaced.

Read `CLAUDE.md` and `DEVELOPMENT_CONTEXT.md` first for full project context.

---

## Task

Use `/plan` to create a detailed implementation plan, then execute it using `/tdd` methodology. Use the code-reviewer agent after each major step.

### What to DELETE (old AA code)

1. **`lib/features/aa/`** — entire directory (3 files):
   - `data/setu_service.dart` — Cloud Functions call to Setu
   - `data/aa_repository.dart` — AA consent + account insertion
   - `presentation/screens/link_account_screen.dart` — WebView for AA consent

2. **`test/features/aa/setu_service_test.dart`** — old test

3. **`lib/data/sync/background_sync_worker.dart`** — rename `kAARefreshTask` constant to `kBackgroundSyncTask` (it's referenced as `'finme.aa_refresh'` — change to `'finme.background_sync'`)

4. **`lib/features/net_worth/data/net_worth_repository.dart`** — remove `getExpiringConsentAccounts()` method (lines 31-40) which checks `consentExpiryDate` and `consentStatus`. This method is no longer needed.

### What to CREATE (new SMS import)

Create `lib/features/sms_import/` with these files:

#### 1. `lib/features/sms_import/data/sms_parser_service.dart`

Pure Dart class (no Flutter/platform dependencies) that parses Indian bank SMS:

```
Class: SmsParserService
Method: ParsedSms? parse(String sender, String body, DateTime timestamp)

ParsedSms fields:
  - double amount
  - String type ('debit' | 'credit')
  - String? accountSuffix (last 4 digits, e.g. '1234')
  - String? merchant (narration/description)
  - String bankName (extracted from sender ID)
  - DateTime date
  - String smsHash (SHA-256 of "$sender|$body|$timestamp" — for dedup)
```

Regex patterns to support (Indian bank SMS formats):
- **Debit:** "debited by Rs.1,234.00", "Rs 5000 debited", "withdrawn Rs.1,234"
- **Credit:** "credited with Rs.1,234.00", "Rs 5000 credited", "received Rs.1,234"
- **Account:** "A/c XX1234", "a/c *1234", "Acct 1234"
- **Known senders:** VM-HDFCBK, AD-SBIINB, JD-ICICIB, BZ-AXISBK, BW-KOTAKB, etc.
- Must return `null` for OTP messages, promo SMS, balance alerts, and non-bank SMS

Use Indian number format: 1,23,456.00 (lakh/crore commas)

#### 2. `lib/features/sms_import/data/sms_import_repository.dart`

```
Class: SmsImportRepository
Constructor: SmsImportRepository({required AppDatabase db})

Methods:
  - Future<int> importFromSms(List<SmsMessage> messages)
    → parse each SMS using SmsParserService
    → check for duplicates (smsHash column in transactions table)
    → insert new transactions with source = 'sms_import', category = 'uncategorized'
    → return count of newly imported transactions

  - Future<List<String>> getImportedSmsHashes()
    → return all smsHash values already in DB (for dedup)
```

#### 3. `lib/features/sms_import/presentation/providers/sms_import_provider.dart`

Riverpod provider using `@riverpod` annotation:
```
@riverpod
class SmsImport extends _$SmsImport {
  // State: SmsImportState { status: idle/importing/done/error, importedCount: int, error: String? }
  // Method: Future<void> importSms() → request permission, read SMS, call repository
}
```

Use the `telephony` package to read SMS inbox on Android.

### What to MODIFY

1. **`lib/data/local/tables/accounts_table.dart`** — keep `consentExpiryDate` and `consentStatus` columns for now (avoid schema migration complexity), but note in a comment that `consentExpiryDate` is unused

2. **`lib/data/sync/background_sync_worker.dart`** — rename the constant:
   - `kAARefreshTask` → `kBackgroundSyncTask`
   - `'finme.aa_refresh'` → `'finme.background_sync'`

3. **`lib/features/net_worth/data/net_worth_repository.dart`** — remove `getExpiringConsentAccounts()` method entirely

4. **`pubspec.yaml`** — add `telephony: ^0.2.0` dependency, remove `webview_flutter` if it has no other usages

5. **`android/app/src/main/AndroidManifest.xml`** — add SMS permissions:
   ```xml
   <uses-permission android:name="android.permission.READ_SMS"/>
   <uses-permission android:name="android.permission.RECEIVE_SMS"/>
   ```

6. **Any test files** referencing `SetuService`, `AaRepository`, or `setu_service_test.dart` — update or remove

### DB Schema Note

The `transactions` table has a `source` column. Currently the plan says `'aa_sync' | 'manual'`. In code, check what values are actually used. New SMS-imported transactions should use `source = 'sms_import'`.

Add a `sms_hash` column to the `transactions` table for deduplication. This requires a Drift schema migration (version bump).

---

## Implementation Order

1. Delete `lib/features/aa/` and `test/features/aa/`
2. Rename `kAARefreshTask` in background_sync_worker.dart
3. Remove `getExpiringConsentAccounts()` from net_worth_repository.dart
4. Add `telephony` to pubspec.yaml, remove `webview_flutter`
5. Add SMS permissions to AndroidManifest.xml
6. **TDD: Write tests for SmsParserService** — test regex against real Indian bank SMS samples
7. **Implement SmsParserService** — make tests pass
8. **TDD: Write tests for SmsImportRepository** — test dedup, insertion, counting
9. **Implement SmsImportRepository** — make tests pass
10. Create SmsImportProvider (Riverpod)
11. Run `dart run build_runner build --delete-conflicting-outputs`
12. Run `flutter test` — all tests must pass
13. Run `flutter analyze` — no errors

---

## Key Constraints

- **Riverpod v3:** Provider functions use `Ref ref` (not named refs). `riverpod_generator 4.x` drops "Notifier" suffix from generated provider names.
- **Dart 3 strict mode:** No `.withOpacity()` — use `.withValues(alpha:)`. `fold` needs explicit type param.
- **Immutability:** All state objects must use `copyWith()`. Never mutate existing objects.
- **File size:** Keep files under 400 lines. Extract utilities if needed.
- **Testing:** Use `AppDatabase.forTesting()` for DB tests. Use `mocktail` for external services. Target 80%+ coverage.
- **Generated files:** Run `build_runner` after modifying any `@riverpod`, `@DriftDatabase`, `@DataClassName` annotated file.
