# Firebase Setup Guide — FinMe

## Status: COMPLETE

Firebase is fully configured and initialized for this project.

| Item | Value |
|---|---|
| **Firebase Project ID** | `finme-0000` |
| **Package name / applicationId** | `com.finme.finme` |
| **Android namespace** | `com.finme.finme` |
| **App label** | `finme` |
| **Flutter version** | `3.41.5` |
| **Dart SDK** | `>=3.3.0 <4.0.0` |
| **Java version** | `17` |
| **Kotlin plugin** | `2.2.20` |
| **AGP** | `8.11.1` |
| **Cloud Functions region** | `asia-south1` |
| **Cloud Functions Node** | `20` |
| **Firestore collection for sync** | `sync_ops` |
| **Firestore user docs path** | `users/{userId}/{document=**}` |
| **CI coverage gate** | `60%` |

### What's Done

- [x] Firebase project created (`finme-0000`)
- [x] Android app registered with SHA-1/SHA-256
- [x] `google-services.json` placed at `android/app/`
- [x] Google Services plugin added to `android/settings.gradle.kts` and `android/app/build.gradle.kts`
- [x] `flutterfire configure` run — generated `lib/firebase_options.dart`
- [x] `Firebase.initializeApp()` uncommented in `lib/main.dart`
- [x] `.firebaserc` configured with default project
- [x] Firestore rules defined in `firestore.rules`
- [x] Cloud Functions scaffolded in `functions/`
- [x] AA (Account Aggregator) feature removed — replaced by SMS-based transaction import (`lib/features/sms_import/`)

---

## Reference: Setup Steps (for new environments)

### Prerequisites

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
```

### SHA-1 Key (needed for Phone Auth)

```bash
cd android && ./gradlew signingReport
```

Copy both **SHA-1** and **SHA-256** from the `debug` variant.

### Register Android App

1. Firebase Console → project → **Add app** → Android
2. Package name: `com.finme.finme`
3. Paste SHA-1 from signing report
4. Download `google-services.json` → place at `android/app/google-services.json`

### Gradle Plugins

`android/settings.gradle.kts`:

```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

`android/app/build.gradle.kts`:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}
```

### FlutterFire Configure

```bash
flutterfire configure --project=finme-0000
```

### Enable Phone Auth

1. Firebase Console → **Authentication** → **Get started**
2. **Sign-in method** → **Phone** → **Enable**
3. Add test numbers (e.g. `+919999999999` / `123456`)

### Create Firestore Database

1. Firebase Console → **Firestore Database** → **Create database**
2. Location: `asia-south1 (Mumbai)`
3. Start in test mode, then deploy rules:

```bash
firebase deploy --only firestore:rules --project=finme-0000
```

### Deploy Cloud Functions

Requires Blaze plan (pay-as-you-go, free tier covers dev usage).

```bash
cd functions && npm install && cd ..
firebase deploy --only functions --project=finme-0000
```

### GitHub Actions Secrets

| Secret | Where to find |
|---|---|
| `FIREBASE_APP_ID_ANDROID` | Firebase Console → Project settings → Your apps → Android app ID |
| `FIREBASE_SERVICE_ACCOUNT` | Google Cloud Console → IAM → Service Accounts → firebase-adminsdk → Keys → JSON |

---

## Quick Verification

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
```
