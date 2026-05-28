import 'package:firebase_auth/firebase_auth.dart';

/// 純 wrapper：把 [FirebaseAuth] 的 API 收斂成 app 需要的形狀。
///
/// 不做任何錯誤轉換、不回傳 Result —— 那一層交給 `AuthRepository`。
/// Step 6 接 Google / Apple 時在此補 `linkWithGoogle()` / `linkWithApple()`。
class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  User? get currentUser => _auth.currentUser;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<User?> userChanges() => _auth.authStateChanges();

  Future<UserCredential> signInAnonymously() => _auth.signInAnonymously();

  Future<void> signOut() => _auth.signOut();
}
