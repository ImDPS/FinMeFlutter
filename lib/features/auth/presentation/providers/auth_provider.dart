import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finme/features/auth/data/auth_repository.dart';

part 'auth_provider.g.dart';

enum AuthStatus { idle, loading, otpSent, authenticated, error }

class AuthState {
  const AuthState({
    this.status = AuthStatus.idle,
    this.verificationId,
    this.error,
  });

  final AuthStatus status;
  final String? verificationId;
  final String? error;

  AuthState copyWith({
    AuthStatus? status,
    String? verificationId,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      verificationId: verificationId ?? this.verificationId,
      error: error,
    );
  }
}

@riverpod
AuthRepository authRepository(Ref ref) => AuthRepository();

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => const AuthState();

  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    final repo = ref.read(authRepositoryProvider);
    await repo.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (String verificationId) {
        state = AuthState(
          status: AuthStatus.otpSent,
          verificationId: verificationId,
        );
      },
      onError: (String error) {
        state = AuthState(
          status: AuthStatus.error,
          error: error,
        );
      },
    );
  }

  Future<bool> verifyOtp(String smsCode) async {
    final verificationId = state.verificationId;
    if (verificationId == null) return false;

    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      final success = await repo.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      if (success) {
        state = const AuthState(status: AuthStatus.authenticated);
      } else {
        state = const AuthState(
          status: AuthStatus.error,
          error: 'Invalid OTP',
        );
      }
      return success;
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<bool> authenticateWithBiometric() async {
    final repo = ref.read(authRepositoryProvider);
    final available = await repo.isBiometricAvailable();
    if (!available) return false;
    final success = await repo.authenticateWithBiometric();
    if (success) {
      state = const AuthState(status: AuthStatus.authenticated);
    }
    return success;
  }

  Future<bool> checkPin(String pin) async {
    final repo = ref.read(authRepositoryProvider);
    final success = await repo.checkPin(pin);
    if (success) {
      state = const AuthState(status: AuthStatus.authenticated);
    }
    return success;
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    state = const AuthState();
  }
}
