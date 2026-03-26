# FinMe — Personal Finance App
## Product Requirements Document

**Date:** 2026-03-26
**Platform:** Android + iOS (Flutter)
**Scope:** Solo personal use · India · INR only
**Status:** Approved
**Min OS:** Android API 24+ (Android 7.0) · iOS 14+

---

## 1. Product Overview & Goals

### Vision

A premium, glassmorphism-first personal finance companion for Indians — tracking spending, budgeting, and net worth in one beautifully crafted app. Built for solo personal use, not published or shared.

### Core Goals

1. Give instant clarity on where money goes (expense tracking + categorization)
2. Help stay within self-set budgets per category
3. Show real-time net worth across bank accounts, credit cards, mutual funds, and stocks
4. Pull data automatically via SMS parsing (bank transaction SMS), with manual entry as fallback
5. Work reliably offline for core flows, sync when connected

### Non-Goals (explicitly out of scope)

- Multi-user / family sharing
- International currencies or cross-border transactions
- Payments or money transfers (view-only, not transact)
- Tax filing or CA-grade reports
- Crypto tracking
- Light mode (dark-first only)

### Success Criteria

- All SMS-imported transactions reflect within minutes of receiving bank SMS
- Monthly budget vs actual visible in under 2 taps
- Net worth dashboard loads in under 1 second (from cache)
- App unlocks in under 1 second via biometric

---

## 2. Screen Architecture & Navigation

### Navigation Pattern

Bottom tab bar with 5 tabs — thumb-friendly, always visible, industry standard for finance apps.

```
Tab 1 — Home (Dashboard)
Tab 2 — Transactions
Tab 3 — Budgets
Tab 4 — Net Worth
Tab 5 — Profile & Settings
```

### Screen Breakdown

#### Tab 1 — Home Dashboard
- Total balance (sum of all linked accounts)
- Monthly spend so far vs monthly income (income = manually set figure in Settings)
- Top 3 spending categories (mini donut chart)
- Recent transactions (last 5)
- Quick action: + Add Transaction
- Net worth delta (vs last month, up/down indicator)

#### Tab 2 — Transactions
- Chronological feed of all transactions
- Filter by: account, category, date range, amount
- Search bar
- Each entry: merchant name, category icon, amount (INR), date, account tag
- Uncategorized transactions shown with a distinct "?" icon — tap to assign category
- Tap to edit category / add note
- FAB: + Manual transaction

#### Tab 3 — Budgets
- Monthly budget overview (total spent / total budgeted)
- Per-category budget cards with progress bar
- Color coded: < 70% = green · >= 70% and < 90% = amber · >= 90% = red
- Tap category to see transactions within it
- + Create budget button

#### Tab 4 — Net Worth
- Total net worth (assets minus liabilities)
- Sections: Bank Accounts · Credit Cards · Mutual Funds · Stocks
- Each section expandable — shows individual accounts/holdings
- Net worth trend chart: v1.1 feature; v1.0 shows placeholder stub ("Trends coming soon")
- Last synced timestamp per account

#### Tab 5 — Profile & Settings
- Linked accounts management (add/remove manually)
- Manual accounts (cash, informal savings)
- Monthly income setting (manual INR figure used for Dashboard spend-vs-income)
- Security (biometric toggle, change PIN, app lock timeout)
- Data & privacy (export data as CSV, delete all data)
- App version / about

### Key Overlay Flows

- Onboarding: phone OTP login → biometric setup → grant SMS permission → auto-import transactions
- Add Transaction: modal bottom sheet, accessible from any tab via FAB
- SMS import flow: request SMS read permission → scan bank SMS → parse and import transactions

### UI State Policy

Every major screen must handle three states:

| State | Behaviour |
|---|---|
| Loading | Skeleton shimmer cards — never blank white flash |
| Empty | Illustration + contextual message + primary CTA (e.g., "Link your first account") |
| Error | Inline error card with message + retry button; sync failure shows "Last sync failed — tap to retry" with timestamp |

---

## 3. Design System & Visual Language

### Design Regime

Glassmorphism · Dark-first · INR-native

### Color Palette

| Token | Hex | Usage |
|---|---|---|
| Background base | #0D0D0F | Near-black warm undertone, app background |
| Surface glass | #FFFFFF0D | White 5% opacity — frosted glass cards |
| Glass border | #FFFFFF1A | White 10% opacity — card borders |
| Primary accent | #7C6EFA | Electric indigo — CTAs, active tab, highlights |
| Secondary accent | #4ECDC4 | Teal-cyan — income, positive delta |
| Danger | #FF6B6B | Coral red — budget alerts, overspent |
| Warning | #FFD93D | Amber — approaching budget limit |
| Success | #6BCB77 | Soft green — under budget |
| Text primary | #F5F5F7 | Near-white — headings, amounts |
| Text secondary | #8E8E9A | Muted grey — labels, captions |

Accessibility: All text/background combinations must meet WCAG AA contrast ratio (4.5:1 minimum). Flutter Semantics widgets applied to all interactive elements. Dynamic type scaling supported.

### Typography

- Font family: Inter (Google Fonts, free, excellent legibility)
- Display / INR amounts: Inter Bold 32-40px
- Headings: Inter SemiBold 20-24px
- Body: Inter Regular 14-16px
- Caption / labels: Inter Medium 12px
- Currency: Always prefix Rs., never suffix
- Indian number format: Rs.1,23,456 (not Rs.123,456)

### Glass Card Spec

Background    : rgba(255, 255, 255, 0.05)
Border        : 1px solid rgba(255, 255, 255, 0.10)
Border radius : 20px
Blur          : BackdropFilter — blur(20px)
Shadow        : 0 8px 32px rgba(0, 0, 0, 0.37)
Padding       : 20px

### Iconography & Motion

- Icons: Lucide Icons (MIT licensed, flutter_lucide package)
- Charts: fl_chart (Flutter native, no WebView, smooth animations)
- Screen transitions: Fade + slide, 200ms ease-out
- Number counters: Animated roll-up when balance/amount loads
- Tab transitions: Hero animations between related elements

### Spacing & Grid

Base unit        : 8px
Screen padding   : 20px horizontal
Card gap         : 12px
Section gap      : 24px
Bottom nav height: 72px (safe area aware)

### Dark Mode Policy

Dark mode only. No light mode in v1.0. Glassmorphism requires a dark base to render correctly.

---

## 4. Data Architecture & Offline Strategy

### Local Storage — Drift + SQLCipher

All financial data lives on-device first. The SQLite database is encrypted using SQLCipher (sqlcipher_flutter_libs + Drift encrypted database support). The AES-256 encryption key is generated on first launch and stored in Flutter Secure Storage (Keychain on iOS / EncryptedSharedPreferences on Android). Flutter Secure Storage is a key-value store used only for secret storage — it does NOT encrypt the database directly.

Schema version: v1. Drift SchemaVersions API used for all future migrations — no schema change ships without a versioned migration step.

Schema:

accounts table:
  id, name, type, institution, balance, last_synced,
  consent_expiry_date (unused — retained for schema compatibility; null for all accounts),
  consent_status ('active' | 'manual')

transactions table:
  id, account_id, amount, category, merchant, date, note, source
  source: 'sms_import' | 'manual'
  category defaults to 'uncategorized' for SMS-imported transactions until user assigns

budgets table:
  id, category, limit_amount, month, year

net_worth_snapshots table:
  id, date, total_assets, total_liabilities, breakdown_json

sync_queue table:
  id, operation, payload, created_at,
  status ('pending' | 'failed'),
  retry_count (max 3; backoff 2s → 4s → 8s; on 3rd failure → status=failed, shown in UI)

user_settings table:
  id,
  monthly_income_inr (manually set INR figure for dashboard spend-vs-income),
  app_lock_timeout_seconds (30 default | 60 | 300)

### Transaction Category Taxonomy (Default)

SMS-imported transactions default to uncategorized. Keyword-based auto-categorization is a v1.1 enhancement. Default categories:

Food & Dining, Transport, Utilities, Shopping, Entertainment,
Health & Medical, Education, Travel, Personal Care, Other, Uncategorized

### Cloud Storage — Firestore

Region: asia-south1 (Mumbai) — all data physically resides in India.

Structure:
users/{uid}/
  accounts/{accountId}
  transactions/{transactionId}
  budgets/{budgetId}
  net_worth_snapshots/{snapshotId}

Security rules: auth.uid match enforced on every document. Only the authenticated user can read or write their own data.

### Offline Strategy

| Operation | Behaviour |
|---|---|
| READ | Always serve from local Drift DB (instant, no network needed) |
| WRITE | Write to local DB immediately + queue in sync_queue |
| SYNC | On connectivity restore, flush sync_queue to Firestore |
| CONFLICT | Local write wins (last-write wins; solo app, no conflicts) |
| SMS IMPORT | Runs on-device — scans SMS inbox on app open or manual pull-to-refresh, no internet needed |
| SYNC FAILURE | Exponential backoff 2s → 4s → 8s, max 3 retries; surface failed-sync banner in UI |

### SMS-Based Transaction Import

1. User grants SMS read permission on first launch (Android only)
2. App scans SMS inbox for bank transaction messages (debit/credit alerts)
3. Regex parser extracts: amount, bank name, account suffix, date, merchant/narration
4. Parsed transactions inserted into Drift DB with `source = 'sms_import'`
5. Duplicate detection: skip SMS already imported (match by SMS timestamp + amount + account)
6. User sees imported transactions on Transactions screen

Supported banks (regex patterns): SBI, HDFC, ICICI, Axis, Kotak, PNB, BOB, Yes Bank, IndusInd, and other major Indian banks that send standardised debit/credit SMS.

Fallback: Manual entry for banks with non-standard SMS format or for cash transactions.

### Security Architecture

Authentication       : Firebase Auth — phone OTP (Indian mobile number)
                       Account recovery: re-verify same mobile OTP to regain access
Local DB encryption  : SQLCipher AES-256; key stored in Flutter Secure Storage
Biometric auth       : local_auth Flutter plugin (TouchID/FaceID/fingerprint)
PIN storage          : bcrypt hash in Flutter Secure Storage — never plaintext
PIN brute-force      : 5 failed attempts → 30s cooldown (doubles each round);
                       10 consecutive failures → mandatory biometric re-enrollment
App lock timeout     : Configurable — 30s (default) | 1 min | 5 min
                       App locks when backgrounded beyond timeout duration
Screen recording     : FLAG_SECURE on all financial screens (Android);
                       equivalent iOS screenshot prevention on all financial screens
SMS data             : Read-only, processed on-device — never uploaded to any server
Analytics            : None — no analytics or crash reporting SDK
Data residency       : Firebase asia-south1 (Mumbai) — DPDP Act 2023 aligned

### Full Data Deletion Scope

"Delete all data" in Settings performs the following in sequence:

1. Local Drift SQLCipher database wiped
2. All Firestore documents under users/{uid}/ deleted
3. Firebase Auth account deleted
4. App resets to onboarding screen

---

## 5. Feature Roadmap

### MVP — Version 1.0

| Feature | Description |
|---|---|
| Onboarding | Phone OTP login → biometric setup → grant SMS permission → auto-import |
| Dashboard | Total balance, monthly spend vs manual income, recent transactions, net worth delta |
| Transactions | Full list, search, filter, manual entry, category editing, uncategorized tagging |
| Budgets | Per-category budgets, progress bars, color-coded alerts |
| Net Worth | Bank + card balances, MF + stock holdings read-only; trend chart stub |
| SMS Import | Auto-import bank transactions from SMS, background periodic scan, manual refresh |
| Offline mode | Read + manual write without internet; sync queue with retry + failure state |
| Security | Biometric + PIN, brute-force lockout, configurable lock timeout, screen recording protection |
| Data export | CSV download of all transactions |
| Cloud sync | Firestore Mumbai, SQLCipher encrypted local DB, user-scoped |

### Version 1.1 — Polish & Depth

- Net worth trend chart (month-over-month line graph)
- Keyword-based auto-categorization of SMS-imported transactions
- Recurring transaction detection (auto-tag EMIs, subscriptions)
- Monthly spending report (shareable card)
- Category-wise spend trends (3/6/12 month bar charts)
- Budget rollover option
- Custom categories + custom icons
- Transaction split across categories

### Version 2.0 — Intelligence Layer

- Spend anomaly alerts
- Savings goal tracker
- Bill due date reminders
- Financial health score (spend/save ratio)
- Home screen widget (Android + iOS)

### Permanently Out of Scope

- Payments / UPI transfers
- Multi-user / family
- Multi-currency
- Tax filing
- Crypto
- Loans / credit score

---

## 6. Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| State Management | Riverpod |
| Local Database | Drift (SQLite) + SQLCipher (sqlcipher_flutter_libs) |
| Cloud Database | Firebase Firestore (asia-south1, Mumbai) |
| Authentication | Firebase Auth (phone OTP) |
| SMS Import | telephony / flutter_sms_inbox (on-device SMS reading) |
| Biometric | local_auth |
| Secure Storage | flutter_secure_storage (DB key + PIN hash) |
| Charts | fl_chart |
| Icons | Lucide Icons (flutter_lucide) |
| HTTP Client | Dio |
| Backend Functions | Firebase Cloud Functions (Node.js) |
| CI/CD | GitHub Actions → Firebase App Distribution |
| Min Android | API 24 (Android 7.0) |
| Min iOS | iOS 14 |

---

## 7. Privacy Summary

- No analytics SDK
- No crash reporting with remote upload
- All financial data encrypted at rest (SQLCipher AES-256) and in transit (TLS)
- Firestore data physically stored in Mumbai (asia-south1)
- SMS parsing is entirely on-device — no bank data leaves the phone (no third-party API calls)
- App is for personal use only — not published on Play Store or App Store publicly
- Full data deletion (local DB + Firestore + Firebase Auth) available from Settings
- Screen recording and screenshots blocked on all financial screens
- DPDP Act 2023 aligned (Indian data residency)
- WCAG AA contrast compliance verified on all text/background combinations
