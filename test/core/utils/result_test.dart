import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/core/utils/result.dart';

void main() {
  group('Result', () {
    test('Success.when 走 success 分支', () {
      const Result<int, AppError> r = Success(42);
      final out = r.when(
        success: (v) => 'ok:$v',
        failure: (e) => 'err',
      );
      expect(out, 'ok:42');
      expect(r.isSuccess, isTrue);
      expect(r.isFailure, isFalse);
    });

    test('Failure.when 走 failure 分支', () {
      const Result<int, AppError> r = Failure(NetworkError('boom', statusCode: 500));
      final out = r.when(
        success: (v) => 'ok',
        failure: (e) => 'err:${e.message}',
      );
      expect(out, 'err:boom');
      expect(r.isFailure, isTrue);
    });

    test('fold 與 when 等價', () {
      const Result<int, AppError> ok = Success(1);
      const Result<int, AppError> bad = Failure(UnknownError('x'));
      expect(ok.fold((v) => v + 1, (_) => -1), 2);
      expect(bad.fold((v) => v, (e) => -1), -1);
    });

    test('map 只變換 Success 的值，Failure 保留', () {
      const Result<int, AppError> ok = Success(3);
      final mapped = ok.map((v) => v * 2);
      expect(mapped, const Success<int, AppError>(6));

      const Result<int, AppError> bad = Failure(NotFoundError('nope'));
      final mappedBad = bad.map((v) => v * 2);
      expect(mappedBad.isFailure, isTrue);
      mappedBad.when(
        success: (_) => fail('should not reach'),
        failure: (e) => expect(e, isA<NotFoundError>()),
      );
    });

    test('factory constructors 與 Success/Failure 等價', () {
      const r1 = Result<int, AppError>.success(7);
      const r2 = Success<int, AppError>(7);
      expect(r1, r2);

      const f1 = Result<int, AppError>.failure(UnknownError('e'));
      const f2 = Failure<int, AppError>(UnknownError('e'));
      expect(f1, f2);
    });
  });
}
