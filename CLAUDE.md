# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**FinMe** is a personal finance tracker for the Indian market (INR only). It uses a local-first encrypted database with Firebase cloud sync. Key characteristics:
- Dark-only glassmorphism UI
- Drift + SQLCipher for encrypted local storage
- Firebase Auth (phone OTP + biometric + PIN) — **initialized** (project: `finme-0000`)
- Firestore sync with offline queue and retry
- SMS-based transaction import (parses bank SMS locally on-device) with manual entry fallback

## Commands

```bash
# Setup (required after cloning or after pubspec changes)
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# All tests
flutter test

# Single test file
flutter test test/features/transactions/transactions_repository_test.dart

# Test by name
flutter test --name "addTransaction"

# Tests with coverage
flutter test --coverage

# Lint and type check
flutter analyze

# Clean
flutter clean
```

**Always run `build_runner` after modifying any file annotated with `@riverpod`, `@DriftDatabase`, `@DataClassName`, or `@UseRowClass`.** Generated files have the `.g.dart` suffix.

## Architecture

Feature-first structure with clean layer separation:

```
lib/
├── main.dart            # Firebase init, WorkManager registration
├── app.dart             # FinMeApp ConsumerWidget + GoRouter provider
├── core/
│   ├── router/          # GoRouter (5-tab ShellRoute + auth routes + /sms-import)
│   ├── theme/           # AppColors, AppTextStyles, AppTheme.dark()
│   ├── utils/           # CurrencyFormatter (INR), category taxonomy
│   └── widgets/         # GlassCard, SkeletonLoader, ErrorCard, EmptyState
├── data/
│   ├── local/
│   │   ├── database.dart          # @DriftDatabase: AppDatabase + forTesting()
│   │   ├── database_provider.dart # @riverpod shared production DB (SQLCipher)
│   │   ├── tables/                # 6 Drift table definitions
│   │   └── daos/                  # 6 DAOs with CRUD + streaming watch*() methods
│   └── sync/
│       ├── sync_engine.dart              # flush() — SyncQueue → Firestore
│       ├── firestore_service.dart        # Firestore CRUD (injectable)
│       └── background_sync_worker.dart   # WorkManager 24hr periodic task
└── features/
    ├── auth/
    │   ├── data/auth_repository.dart              # Phone OTP, SHA-256 PIN, biometric
    │   └── presentation/providers/auth_provider.dart  # AuthNotifier + AuthState
    ├── sms_import/
    │   ├── data/sms_parser_service.dart            # Regex-based bank SMS parser
    │   ├── data/sms_import_repository.dart         # Read SMS → parse → insert
    │   └── presentation/screens/sms_import_screen.dart  # SMS import UI
    ├── dashboard/
    ├── transactions/
    ├── budgets/
    ├── net_worth/
    └── settings/
```

### State Management: Riverpod 3.x

- Uses `@riverpod` annotation + code generation
- **Riverpod v3 breaking change:** provider functions take `Ref ref` (not named refs like `AppRouterRef`)
- **`riverpod_generator 4.x` naming:** `DashboardNotifier` generates `dashboardProvider` (not `dashboardNotifierProvider` — the "Notifier" suffix is dropped)
- State is always immutable with `copyWith()` pattern
- Providers use `Future.microtask(load)` to trigger async loads on build

### Navigation: GoRouter 14.x

- `app_router.dart` — `@riverpod GoRouter appRouter(Ref ref)`
- 5-tab `ShellRoute`: `/dashboard`, `/transactions`, `/budgets`, `/net-worth`, `/settings`
- Auth routes outside shell: `/onboarding` → `/otp` → `/lock`
- Standalone routes: `/sms-import`
- Initial route: `/onboarding`

### Database: Drift 2.x + SQLCipher

- Production: `appDatabaseProvider` in `database_provider.dart` — shared SQLCipher-encrypted instance with `flutter_secure_storage` key management
- Tests: `AppDatabase.forTesting()` uses `NativeDatabase.memory()` — no encryption, no platform channels
- 6 tables: `accounts`, `transactions`, `budgets`, `net_worth_snapshots`, `sync_queue`, `user_settings`

### Sync Engine

Local writes happen immediately to Drift. Operations are also enqueued in `sync_queue`. `SyncEngine.flush()` processes pending items → Firestore, incrementing retry count on failure and marking failed after 3 attempts. Background sync runs every 24hr via WorkManager.

## Testing Patterns

Tests mirror the `lib/` structure under `test/`. Pattern:

```dart
setUp(() {
  db = AppDatabase.forTesting();  // In-memory DB, no mocks needed
  repo = TransactionsRepository(db: db);
});
tearDown(() async => db.close());
```

Use `mocktail` for Firebase, Firestore, or other external services. CI requires ≥60% line coverage.

## Dart 3 / Riverpod v3 Gotchas

- **Deprecated:** `.withOpacity()` → use `.withValues(alpha: ...)` instead
- **`fold` needs explicit type:** `fold<int>(0, ...)` not `fold(0, ...)`
- **`Transaction` type conflict:** `dart:html` exports `Transaction` — use `typedef` or prefix imports if needed
- Strict analysis is enabled (`strict-casts`, `strict-inference`, `strict-raw-types`)

## Pending Tech Debt

1. **GitHub Actions secrets** — CI needs `FIREBASE_APP_ID_ANDROID` and `FIREBASE_SERVICE_ACCOUNT` for App Bundle distribution.

## CI/CD

GitHub Actions (`.github/workflows/ci.yml`):
1. **test** — `flutter analyze` + `flutter test --coverage` + lcov ≥60% gate
2. **build-android** — `flutter build apk --debug` (runs only on master/main after tests pass)
