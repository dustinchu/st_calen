import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stock_calendar/core/firebase/auth_service.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockUserCredential extends Mock implements UserCredential {}

void main() {
  group('AuthService', () {
    late _MockFirebaseAuth auth;
    late AuthService service;

    setUp(() {
      auth = _MockFirebaseAuth();
      service = AuthService(auth);
    });

    test('signInAnonymously 委派給 FirebaseAuth 並回傳 credential', () async {
      final cred = _MockUserCredential();
      when(() => auth.signInAnonymously()).thenAnswer((_) async => cred);

      final result = await service.signInAnonymously();

      expect(result, same(cred));
      verify(() => auth.signInAnonymously()).called(1);
    });

    test('signInAnonymously 例外照原樣往上拋（service 不做轉換）', () async {
      when(() => auth.signInAnonymously()).thenThrow(
        FirebaseAuthException(code: 'operation-not-allowed'),
      );

      expect(
        () => service.signInAnonymously(),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('signOut 委派給 FirebaseAuth', () async {
      when(() => auth.signOut()).thenAnswer((_) async {});

      await service.signOut();

      verify(() => auth.signOut()).called(1);
    });

    test('currentUser / currentUserId 委派給 FirebaseAuth.currentUser', () {
      final user = _MockUser();
      when(() => user.uid).thenReturn('uid-123');
      when(() => auth.currentUser).thenReturn(user);

      expect(service.currentUser, same(user));
      expect(service.currentUserId, 'uid-123');
    });

    test('currentUserId 在未登入時為 null', () {
      when(() => auth.currentUser).thenReturn(null);
      expect(service.currentUserId, isNull);
    });

    test('userChanges() emit FirebaseAuth.authStateChanges 序列', () async {
      final user = _MockUser();
      when(() => user.uid).thenReturn('uid-9');
      final controller = StreamController<User?>();
      when(() => auth.authStateChanges()).thenAnswer((_) => controller.stream);

      final emitted = <String?>[];
      final sub = service.userChanges().listen((u) => emitted.add(u?.uid));

      controller.add(user);
      controller.add(null);
      await Future<void>.delayed(Duration.zero);

      expect(emitted, ['uid-9', null]);
      await sub.cancel();
      await controller.close();
    });
  });
}
