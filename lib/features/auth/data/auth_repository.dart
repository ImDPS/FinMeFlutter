import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

const _kPinKey = 'finme_pin_hash';
const _kFailedAttemptsKey = 'finme_failed_attempts';
const _kLockoutUntilKey = 'finme_lockout_until';
const int _kMaxAttempts = 5;
const Duration _kLockoutDuration = Duration(minutes: 30);

class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FlutterSecureStorage? storage,
    LocalAuthentication? localAuth,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _storage = storage ?? const FlutterSecureStorage(),
        _localAuth = localAuth ?? LocalAuthentication();

  final FirebaseAuth _auth;
  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  // ── Phone OTP ───────────────────────────────────────────────────────────

  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (e) => onError(e.message ?? 'OTP failed'),
      codeSent: (id, _) => onCodeSent(id),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<bool> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final result = await _auth.signInWithCredential(credential);
    return result.user != null;
  }

  // ── PIN ─────────────────────────────────────────────────────────────────

  /// Returns a SHA-256 hex digest of the PIN.
  String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  bool verifyPin(String pin, String storedHash) => hashPin(pin) == storedHash;

  Future<void> savePin(String pin) async {
    await _storage.write(key: _kPinKey, value: hashPin(pin));
    await _storage.write(key: _kFailedAttemptsKey, value: '0');
  }

  Future<bool> checkPin(String pin) async {
    if (await _isLockedOut()) return false;

    final storedHash = await _storage.read(key: _kPinKey);
    if (storedHash == null) return false;

    if (verifyPin(pin, storedHash)) {
      await _storage.write(key: _kFailedAttemptsKey, value: '0');
      return true;
    } else {
      await _incrementFailedAttempts();
      return false;
    }
  }

  // ── Brute-force lockout ─────────────────────────────────────────────────

  Future<bool> _isLockedOut() async {
    final until = await _storage.read(key: _kLockoutUntilKey);
    if (until == null) return false;
    final lockoutUntil = DateTime.parse(until);
    if (DateTime.now().isBefore(lockoutUntil)) return true;
    await _storage.delete(key: _kLockoutUntilKey);
    return false;
  }

  Future<void> _incrementFailedAttempts() async {
    final raw = await _storage.read(key: _kFailedAttemptsKey) ?? '0';
    final count = int.parse(raw) + 1;
    await _storage.write(key: _kFailedAttemptsKey, value: count.toString());
    if (count >= _kMaxAttempts) {
      final lockUntil = DateTime.now().add(_kLockoutDuration);
      await _storage.write(key: _kLockoutUntilKey, value: lockUntil.toIso8601String());
    }
  }

  // ── Biometric ───────────────────────────────────────────────────────────

  Future<bool> isBiometricAvailable() => _localAuth.canCheckBiometrics;

  Future<bool> authenticateWithBiometric() async {
    return _localAuth.authenticate(
      localizedReason: 'Authenticate to access FinMe',
      options: const AuthenticationOptions(stickyAuth: true),
    );
  }

  // ── Sign-out ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _auth.signOut();
    await _storage.deleteAll();
  }
}
