import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stock_calendar/core/firebase/auth_service.dart';
import 'package:stock_calendar/core/utils/result.dart';
import 'package:stock_calendar/data/repositories/auth_repository.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockUser extends Mock implements User {}

class _MockUserCredential extends Mock implements UserCredential {}

void main() {
  group('AuthRepository.signInAnonymously', () {
    late _MockAuthService service;
    late AuthRepository repo;

    setUp(() {
      service = _MockAuthService();
      repo = AuthRepository(service);
    });

    test('成功時包成 Result.success(User)', () async {
      final user = _MockUser();
      when(() => user.uid).thenReturn('uid-1');
      final cred = _MockUserCredential();
      when(() => cred.user).thenReturn(user);
      when(() => service.signInAnonymously()).thenAnswer((_) async => cred);

      final result = await repo.signInAnonymously();

      expect(result, isA<Success<User, AuthError>>());
      expect((result as Success<User, AuthError>).value.uid, 'uid-1');
    });

    test('credential.user 為 null 時回 AuthUnknownError', () async {
      final cred = _MockUserCredential();
      when(() => cred.user).thenReturn(null);
      when(() => service.signInAnonymously()).thenAnswer((_) async => cred);

      final result = await repo.signInAnonymously();

      expect(result, isA<Failure<User, AuthError>>());
      expect((result as Failure<User, AuthError>).error, isA<AuthUnknownError>());
    });

    test('FirebaseAuthException network-request-failed → AuthNetworkError', () async {
      when(() => service.signInAnonymously()).thenThrow(
        FirebaseAuthException(code: 'network-request-failed', message: 'offline'),
      );

      final result = await repo.signInAnonymously();

      final err = (result as Failure<User, AuthError>).error;
      expect(err, isA<AuthNetworkError>());
    });

    test('FirebaseAuthException operation-not-allowed → AuthOperationNotAllowedError', () async {
      when(() => service.signInAnonymously()).thenThrow(
        FirebaseAuthException(code: 'operation-not-allowed'),
      );

      final result = await repo.signInAnonymously();

      expect((result as Failure<User, AuthError>).error,
          isA<AuthOperationNotAllowedError>());
    });

    test('其他 FirebaseAuthException → AuthUnknownError 帶 code', () async {
      when(() => service.signInAnonymously()).thenThrow(
        FirebaseAuthException(code: 'too-many-requests', message: 'rate limited'),
      );

      final result = await repo.signInAnonymously();

      final err = (result as Failure<User, AuthError>).error as AuthUnknownError;
      expect(err.message, contains('too-many-requests'));
    });

    test('非 FirebaseAuthException 也包成 AuthUnknownError', () async {
      when(() => service.signInAnonymously()).thenThrow(StateError('boom'));

      final result = await repo.signInAnonymously();

      expect((result as Failure<User, AuthError>).error, isA<AuthUnknownError>());
    });
  });

  group('AuthRepository.signOut', () {
    late _MockAuthService service;
    late AuthRepository repo;

    setUp(() {
      service = _MockAuthService();
      repo = AuthRepository(service);
    });

    test('成功時回 Result.success(null)', () async {
      when(() => service.signOut()).thenAnswer((_) async {});

      final result = await repo.signOut();

      expect(result, isA<Success<void, AuthError>>());
    });

    test('例外時回 AuthUnknownError', () async {
      when(() => service.signOut()).thenThrow(StateError('boom'));

      final result = await repo.signOut();

      expect((result as Failure<void, AuthError>).error, isA<AuthUnknownError>());
    });
  });
}
