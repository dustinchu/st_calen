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

  /// 已綁定的 provider id 清單（`google.com` / `apple.com` / `firebase` 等）。
  /// 匿名 user 為空 list。Step 6 LoginSheet 用來顯示已綁定狀態。
  final List<String> linkedProviders;
  const AuthSignedIn({
    required this.uid,
    required this.isAnonymous,
    this.linkedProviders = const [],
  });

  bool get hasGoogle => linkedProviders.contains('google.com');
  bool get hasApple => linkedProviders.contains('apple.com');
}

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) => AuthService(ref.watch(firebaseAuthProvider));

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(authServiceProvider));

/// StreamNotifier：訂閱 FirebaseAuth.userChanges()，映射成 [AuthState]。
/// 暴露 `signInAnonymously` / `linkWithGoogle` / `linkWithApple` / `unlink` / `signOut`。
@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  @override
  Stream<AuthState> build() {
    return ref.watch(authRepositoryProvider).userChanges.map(_toState);
  }

  AuthState _toState(User? user) {
    if (user == null) return const AuthSignedOut();
    return AuthSignedIn(
      uid: user.uid,
      isAnonymous: user.isAnonymous,
      linkedProviders:
          user.providerData.map((p) => p.providerId).toList(growable: false),
    );
  }

  Future<void> signInAnonymously() async {
    final result = await ref.read(authRepositoryProvider).signInAnonymously();
    _applyFailure(result);
  }

  Future<AuthError?> linkWithGoogle() async {
    final result = await ref.read(authRepositoryProvider).linkWithGoogle();
    return _applyFailure(result);
  }

  Future<AuthError?> linkWithApple() async {
    final result = await ref.read(authRepositoryProvider).linkWithApple();
    return _applyFailure(result);
  }

  Future<AuthError?> unlinkProvider(String providerId) async {
    final result =
        await ref.read(authRepositoryProvider).unlinkProvider(providerId);
    return result.when(
      success: (_) => null,
      failure: (error) {
        state = AsyncValue.data(AuthSignedOut(lastError: error));
        return error;
      },
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }

  /// 失敗時把 lastError 寫進 state；成功時不動 state（userChanges 會自動推新值）。
  AuthError? _applyFailure(Result<User, AuthError> result) {
    return result.when(
      success: (_) => null,
      failure: (error) {
        state = AsyncValue.data(AuthSignedOut(lastError: error));
        return error;
      },
    );
  }
}
