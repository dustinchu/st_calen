import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// User 在 Google / Apple sign-in 對話框按取消時 service 丟出的 sentinel。
/// 由 AuthRepository 映射成 [AuthCancelledError]。
class AuthCancelledException implements Exception {
  const AuthCancelledException();
  @override
  String toString() => 'AuthCancelledException';
}

/// 純 wrapper：把 [FirebaseAuth] + Google / Apple SDK 的 API 收斂成 app 需要的形狀。
///
/// 不做錯誤轉換、不回傳 Result —— 那一層交給 `AuthRepository`。
class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  AuthService(this._auth, {GoogleSignIn? googleSignIn})
      : _google = googleSignIn ?? GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  String? get currentUserId => _auth.currentUser?.uid;

  /// 用 `userChanges()`（不是 authStateChanges）才會在 link / unlink / profile 更新時 emit，
  /// Step 6 LoginSheet 綁定完成後 UI 才能立刻反映新的 providerData。
  Stream<User?> userChanges() => _auth.userChanges();

  Future<UserCredential> signInAnonymously() => _auth.signInAnonymously();

  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  /// 將 Google 帳號綁到目前 user（匿名或已綁其他 provider）。
  /// User 按取消 → 丟 [AuthCancelledException]。
  Future<UserCredential> linkWithGoogle() async {
    final account = await _google.signIn();
    if (account == null) throw const AuthCancelledException();
    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    return _linkOrSignIn(credential);
  }

  /// 將 Apple 帳號綁到目前 user。僅 iOS 走 native flow（Android 留給後續 step）。
  Future<UserCredential> linkWithApple() async {
    final AuthorizationCredentialAppleID appleCred;
    try {
      appleCred = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthCancelledException();
      }
      rethrow;
    }
    final oauth = OAuthProvider('apple.com').credential(
      idToken: appleCred.identityToken,
      accessToken: appleCred.authorizationCode,
    );
    return _linkOrSignIn(oauth);
  }

  /// 解除某 provider。providerId 例：`google.com` / `apple.com`。
  Future<User> unlinkProvider(String providerId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'no signed-in user to unlink from',
      );
    }
    return user.unlink(providerId);
  }

  Future<UserCredential> _linkOrSignIn(AuthCredential credential) {
    final user = _auth.currentUser;
    // 沒有匿名 user（極少數狀況：bootstrap 匿名失敗）→ 直接 signIn 切換 UID。
    if (user == null) return _auth.signInWithCredential(credential);
    return user.linkWithCredential(credential);
  }
}
