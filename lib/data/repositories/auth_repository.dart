import 'package:firebase_auth/firebase_auth.dart';

import '../../core/firebase/auth_service.dart';
import '../../core/utils/result.dart';

/// 包裝 [AuthService]，把 FirebaseAuthException / [AuthCancelledException]
/// 轉成 [AuthError]，對外回傳 `Result<T, AuthError>`。
class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);

  User? get currentUser => _service.currentUser;

  String? get currentUserId => _service.currentUserId;

  Stream<User?> get userChanges => _service.userChanges();

  Future<Result<User, AuthError>> signInAnonymously() =>
      _wrapCredential(_service.signInAnonymously);

  Future<Result<User, AuthError>> linkWithGoogle() =>
      _wrapCredential(_service.linkWithGoogle);

  Future<Result<User, AuthError>> linkWithApple() =>
      _wrapCredential(_service.linkWithApple);

  Future<Result<void, AuthError>> unlinkProvider(String providerId) async {
    try {
      await _service.unlinkProvider(providerId);
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseException(e));
    } catch (e) {
      return Result.failure(AuthUnknownError(e.toString()));
    }
  }

  Future<Result<void, AuthError>> signOut() async {
    try {
      await _service.signOut();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AuthUnknownError(e.toString()));
    }
  }

  Future<Result<User, AuthError>> _wrapCredential(
    Future<UserCredential> Function() fn,
  ) async {
    try {
      final cred = await fn();
      final user = cred.user;
      if (user == null) {
        return const Result.failure(
            AuthUnknownError('credential.user is null'));
      }
      return Result.success(user);
    } on AuthCancelledException {
      return const Result.failure(AuthCancelledError());
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseException(e));
    } catch (e) {
      return Result.failure(AuthUnknownError(e.toString()));
    }
  }

  AuthError _mapFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return AuthNetworkError(e.message ?? 'network unavailable');
      case 'operation-not-allowed':
        return AuthOperationNotAllowedError(
            e.message ?? 'operation not allowed');
      // 該 Google/Apple 帳號之前已綁定其他 UID → 同視為 AccountExists，
      // UI 提示「請改用該帳號登入」（切換 UID 流程留給 Step 9）。
      case 'account-exists-with-different-credential':
      case 'credential-already-in-use':
      case 'email-already-in-use':
        return AuthAccountExistsError(
          email: e.email,
          message: e.message ?? 'account exists with different credential',
        );
      default:
        return AuthUnknownError('[${e.code}] ${e.message ?? ''}');
    }
  }
}
