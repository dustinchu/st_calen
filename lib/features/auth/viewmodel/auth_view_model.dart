import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/firebase/auth_service.dart';
import '../../../core/utils/result.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_view_model.g.dart';

/// Auth UI state。匿名登入成功 → [AuthSignedIn]；尚未登入 / 失敗 → [AuthSignedOut]。
sealed class AuthState {
  const AuthState();
}

final class AuthSignedOut extends AuthState {
  /// 最近一次登入嘗試失敗的錯誤（如離線、provider 未啟用）。null = 從未嘗試或已重設。
  final AuthError? lastError;
  const AuthSignedOut({this.lastError});
}

final class AuthSignedIn extends AuthState {
  final String uid;
  final bool isAnonymous;
  const AuthSignedIn({required this.uid, required this.isAnonymous});
}

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) => AuthService(ref.watch(firebaseAuthProvider));

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(authServiceProvider));

/// StreamNotifier：訂閱 FirebaseAuth.authStateChanges()，映射成 [AuthState]。
/// 暴露 `signInAnonymously` / `signOut` 供 UI 觸發。
@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  @override
  Stream<AuthState> build() {
    return ref.watch(authRepositoryProvider).userChanges.map(_toState);
  }

  AuthState _toState(User? user) {
    if (user == null) return const AuthSignedOut();
    return AuthSignedIn(uid: user.uid, isAnonymous: user.isAnonymous);
  }

  Future<void> signInAnonymously() async {
    final result = await ref.read(authRepositoryProvider).signInAnonymously();
    result.when(
      success: (_) {
        // authStateChanges 會自動推 AuthSignedIn，不需在這手動 setState。
      },
      failure: (error) {
        state = AsyncValue.data(AuthSignedOut(lastError: error));
      },
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }
}
