import 'package:firebase_auth/firebase_auth.dart';

import '../../core/firebase/auth_service.dart';
import '../../core/utils/result.dart';

/// 包裝 [AuthService]，把 FirebaseAuthException 轉成 [AuthError]，
/// 對外回傳 `Result<User, AuthError>`。
class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);

  User? get currentUser => _service.currentUser;

  String? get currentUserId => _service.currentUserId;

  Stream<User?> get userChanges => _service.userChanges();

  Future<Result<User, AuthError>> signInAnonymously() async {
    try {
      final credential = await _service.signInAnonymously();
      final user = credential.user;
      if (user == null) {
        return const Result.failure(AuthUnknownError('credential.user is null'));
      }
      return Result.success(user);
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

  AuthError _mapFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return AuthNetworkError(e.message ?? 'network unavailable');
      case 'operation-not-allowed':
        return AuthOperationNotAllowedError(e.message ?? 'operation not allowed');
      case 'account-exists-with-different-credential':
        return AuthAccountExistsError(
          email: e.email,
          message: e.message ?? 'account exists with different credential',
        );
      default:
        return AuthUnknownError('[${e.code}] ${e.message ?? ''}');
    }
  }
}
