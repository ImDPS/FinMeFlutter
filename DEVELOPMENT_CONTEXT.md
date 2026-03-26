# FinMe — Development Context

> **Last updated:** 2026-03-26
> **Status:** All 17 tasks complete, 33/33 tests passing, 20 commits on `master`

---

## What Was Built

FinMe is a personal finance app for the Indian market with:
- Local-first encrypted database (Drift + SQLCipher)
- Firebase Auth (phone OTP + biometric + PIN) — _not yet initialized, pending `flutterfire configure`_
- Firestore cloud sync with offline queue and retry
- Setu FIU Account Aggregator integration (WebView consent flow, Cloud Function scaffold)
- 24-hour background sync via WorkManager
- Dashboard, Transactions, Budgets, Net Worth, Settings screens
- Dark-only glass-morphism UI with Riverpod 3.x state management

---

## Tech Stack (Actual Versions)

| Package | Version | Notes |
|---------|---------|-------|
| Flutter | 3.41.5 | Dart 3.11.3 |
| flutter_riverpod | ^3.3.1 | v3 — `Ref ref` not named ref |
| riverpod_annotation | ^4.0.2 | generates `fooProvider` not `fooNotifierProvider` |
| riverpod_generator | ^4.x | build_runner codegen |
| drift | ^2.x | local DB |
| drift_flutter | ^0.2.x | SQLCipher on mobile |
| go_router | ^14.x | ShellRoute 5-tab nav |
| firebase_auth | ^5.x | |
| cloud_firestore | ^5.x | |
| cloud_functions | ^5.0.0 | bumped from ^4.x (incompatible) |
| lucide_icons | ^0.253.0 | bumped from ^0.0.4 (no published versions) |
| uuid | ^4.4.0 | added for transaction IDs |
| mocktail | latest | all test mocks |

---

## Architecture

```
lib/
├── main.dart                   # Entry point — Firebase TODO, registerBackgroundSync
├── app.dart                    # FinMeApp ConsumerWidget → appRouterProvider
├── core/
│   ├── router/
│   │   ├── app_router.dart     # @riverpod GoRouter — 5 tabs + auth routes
│   │   ├── app_router.g.dart   # generated
│   │   └── shell_scaffold.dart # NavigationBar host
│   ├── theme/
│   │   ├── app_colors.dart     # 10 semantic colors
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart      # AppTheme.dark()
│   ├── utils/
│   │   ├── currency_formatter.dart  # INR formatting
│   │   └── category_taxonomy.dart   # default categories
│   └── widgets/
│       ├── glass_card.dart     # BackdropFilter blur card
│       ├── skeleton_loader.dart # shimmer with .withValues(alpha:)
│       ├── error_card.dart
│       └── empty_state.dart
├── data/
│   ├── local/
│   │   ├── database.dart       # @DriftDatabase — AppDatabase + forTesting()
│   │   ├── tables/             # 6 tables: accounts, transactions, budgets,
│   │   │                       #   net_worth, sync_queue, user_settings
│   │   └── daos/               # 6 DAOs — full CRUD + streaming
│   └── sync/
│       ├── sync_engine.dart    # flush() — processes SyncQueue → Firestore
│       ├── firestore_service.dart  # pushOperation() — injectable
│       └── background_sync_worker.dart  # WorkManager 24hr periodic task
└── features/
    ├── auth/data/auth_repository.dart   # SHA-256 PIN, biometric, OTP lockout
    ├── aa/
    │   ├── data/setu_service.dart       # Cloud Function call → redirect URL
    │   └── presentation/screens/link_account_screen.dart  # WebView
    ├── dashboard/
    ├── transactions/
    ├── budgets/
    ├── net_worth/
    └── settings/
        └── presentation/providers/settings_provider.dart  # CSV export
```

---

## Key Patterns and Gotchas

### Riverpod v3 Breaking Changes
- `@riverpod` functions use `Ref ref` (not `AppRouterRef`, `DashboardRef`, etc.)
- `riverpod_generator 4.x` names providers **without** "Notifier" suffix:
  - `DashboardNotifier` → generates `dashboardProvider` (not `dashboardNotifierProvider`)
  - `TransactionsNotifier` → generates `transactionsProvider`

### Dart 3 / Strict Mode Fixes
- `.withOpacity()` deprecated → use `.withValues(alpha: ...)` throughout
- `fold` type inference requires explicit type param: `fold<int>(0, ...)`
- `import` statements must be at top of file (not inside function bodies)
- `List<Transaction>` conflicts with `dart:html` Transaction → use `typedef TransactionList = List<Transaction>`

### Database Testing
- `AppDatabase.forTesting()` uses `NativeDatabase.memory()` — no encryption, no platform channels
- **Tech debt:** Production providers currently use `AppDatabase.forTesting()` — needs real `AppDatabase.create()` with SQLCipher + flutter_secure_storage wiring

### Firebase Not Yet Initialized
- All Firebase-dependent classes use constructor injection so tests pass without Firebase
- `main.dart` has `Firebase.initializeApp()` commented out
- Unblock with: `flutterfire configure` → uncomment the init call

### build_runner
Required for Drift DAOs (`.g.dart`) and Riverpod providers (`.g.dart`):
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## What's Pending (Next Steps)

### 1. Firebase Setup (Blocker for auth/sync features)
```bash
# In finme/ directory
flutterfire configure
# Then uncomment in lib/main.dart:
# await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```
- After this: update `lib/features/auth/data/auth_repository.dart` to use real `FirebaseAuth.instance`
- Update `lib/data/sync/firestore_service.dart` to use real `FirebaseFirestore.instance`

### 2. Setu Sandbox Credentials (AA integration)
1. Register at https://bridge.setu.co → get CLIENT_ID + SECRET
2. Store in Firebase Secret Manager (not in code)
3. Update `functions/src/index.ts` — replace mock `MOCK_SETU_REDIRECT_URL` with real API call to `https://fiu-sandbox.setu.co`

### 3. Shared AppDatabase Provider (Tech debt)
Replace all `AppDatabase.forTesting()` in production providers with a real shared instance:

```dart
// lib/data/local/database_provider.dart
@Riverpod(keepAlive: true)
Future<AppDatabase> appDatabase(Ref ref) async {
  final secureStorage = FlutterSecureStorage();
  var key = await secureStorage.read(key: 'db_encryption_key');
  if (key == null) {
    key = AppDatabase.generateEncryptionKey();
    await secureStorage.write(key: 'db_encryption_key', value: key);
  }
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'finme.db');
  return AppDatabase(DatabaseConnection(
    NativeDatabase(File(path), setup: (db) {
      db.execute("PRAGMA key = '$key'");
    }),
  ));
}
```
Then update each repository provider to `await ref.watch(appDatabaseProvider.future)`.

### 4. GitHub Secrets for CI
Add to repo settings → Secrets and variables → Actions:
- `FIREBASE_APP_ID_ANDROID` — from Firebase console (Project settings → Your apps)
- `FIREBASE_SERVICE_ACCOUNT` — JSON key for Firebase App Distribution service account

---

## Git History

```
04f3544 test: fix smoke test to use FinMeApp
76b27e5 feat: add 24hr background AA sync via WorkManager
2332963 test: add ShellScaffold navigation widget tests
cd74123 ci: add GitHub Actions — test, analyze, coverage check, Android debug build
b640975 feat: settings screen with income, security, manual accounts, CSV export
2cd95b5 feat: net worth screen with expandable sections and consent expiry alerts
bd4a7b7 feat: budgets screen with progress bars and BudgetColor logic
85ea44f feat: transactions screen with search, filter, and add transaction modal
e35367c feat: dashboard screen with balance card, spend vs income, top categories
8229c24 feat: add Setu FIU consent flow, AA repository, and Cloud Function scaffold
5378509 feat: add phone OTP, biometric, PIN auth with brute-force lockout
17180eb feat: add Firestore sync engine with offline queue and retry
e67d29d feat: add Drift+SQLCipher local database with all tables and DAOs
548f659 feat: add navigation shell with GoRouter and 5-tab bottom nav
e41755e feat: add INR currency formatter and default category taxonomy
9a6402e feat: add core widgets — GlassCard, Skeleton, ErrorCard, EmptyState
85ff7a6 feat: add design system — colors, typography, dark theme
9bb08eb chore: use package imports and enable strict analysis
ec8207f feat: init Flutter project with full dependency set
```

---

## Running the Project

```bash
cd /Users/nainu/Desktop/DurgendraWorkspace/Personal/finme

# Get dependencies
flutter pub get

# Generate Drift + Riverpod code
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Run app (needs connected device or emulator)
flutter run

# Analyze
flutter analyze
```

---

## Project Docs

- **Plan:** `docs/superpowers/plans/2026-03-26-finme-app.md`
- **Design spec:** `docs/superpowers/specs/2026-03-26-personal-finance-app-design.md`
- **CI config:** `.github/workflows/ci.yml`
- **Firestore rules:** `firestore.rules`
- **Cloud Function:** `functions/src/index.ts`
