import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stock_calendar/core/firebase/auth_service.dart';
import 'package:stock_calendar/core/storage/hive_boxes.dart';
import 'package:stock_calendar/core/storage/hive_init.dart';
import 'package:stock_calendar/core/utils/result.dart';
import 'package:stock_calendar/data/models/calendar_doc.dart';
import 'package:stock_calendar/data/repositories/calendar_repository.dart';
import 'package:stock_calendar/data/sources/local/calendar_local_ds.dart';
import 'package:stock_calendar/data/sources/remote/calendar_firestore_ds.dart';

class _MockLocal extends Mock implements CalendarLocalDataSource {}

class _MockRemote extends Mock implements CalendarFirestoreDataSource {}

class _MockAuth extends Mock implements AuthService {}

CalendarDoc _doc({
  String id = 'cal-1',
  String symbol = '2330.TW',
  int year = 2026,
  int month = 6,
}) {
  final t = DateTime.utc(2026, 5, 1);
  return CalendarDoc(
    id: id,
    userId: 'u1',
    symbol: symbol,
    year: year,
    month: month,
    title: '$symbol-$month',
    themeId: 'def',
    createdAt: t,
    updatedAt: t,
  );
}

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('cal_repo_test');
    Hive.init(tempDir.path);
    HiveInit.registerAdaptersForTest();
    registerFallbackValue(_doc());
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  late _MockLocal local;
  late _MockRemote remote;
  late _MockAuth auth;
  late Box<dynamic> metaBox;
  late CalendarRepository repo;

  setUp(() async {
    local = _MockLocal();
    remote = _MockRemote();
    auth = _MockAuth();
    metaBox = await Hive.openBox<dynamic>(
        'meta_test_${DateTime.now().microsecondsSinceEpoch}');
    repo = CalendarRepository(
      local: local,
      remote: remote,
      auth: auth,
      metaBox: metaBox,
    );
    when(() => auth.currentUserId).thenReturn('uid-1');
  });

  tearDown(() async {
    await metaBox.deleteFromDisk();
  });

  // ─── get ───────────────────────────────────────────────────────────────────

  group('get', () {
    test('local hit → 直接回 Success(doc)，不打 remote', () async {
      final d = _doc();
      when(() => local.get(symbol: '2330.TW', year: 2026, month: 6))
          .thenAnswer((_) async => Result.success(d));

      final r = await repo.get(symbol: '2330.TW', year: 2026, month: 6);

      expect(r, isA<Success<CalendarDoc?, AppError>>());
      expect((r as Success<CalendarDoc?, AppError>).value, d);
      verifyNever(() => remote.listByStock(
          uid: any(named: 'uid'), symbol: any(named: 'symbol')));
    });

    test('local miss + remote hit → 寫回 local 並回 Success(doc)', () async {
      final d = _doc();
      when(() => local.get(symbol: '2330.TW', year: 2026, month: 6))
          .thenAnswer((_) async => const Result.failure(NotFoundError()));
      when(() => remote.listByStock(uid: 'uid-1', symbol: '2330.TW'))
          .thenAnswer((_) async => Result.success([d]));
      when(() => local.put(any())).thenAnswer((_) async => const Result.success(null));

      final r = await repo.get(symbol: '2330.TW', year: 2026, month: 6);

      expect((r as Success<CalendarDoc?, AppError>).value, d);
      verify(() => local.put(d)).called(1);
    });

    test('local miss + remote 也沒這個 month → Success(null)（非 NotFoundError）',
        () async {
      when(() => local.get(symbol: '2330.TW', year: 2026, month: 6))
          .thenAnswer((_) async => const Result.failure(NotFoundError()));
      when(() => remote.listByStock(uid: 'uid-1', symbol: '2330.TW'))
          .thenAnswer((_) async => const Result.success([]));

      final r = await repo.get(symbol: '2330.TW', year: 2026, month: 6);

      expect(r.isSuccess, isTrue);
      expect((r as Success<CalendarDoc?, AppError>).value, isNull);
    });

    test('local miss + 未登入 → 不打 remote，回 Success(null)', () async {
      when(() => auth.currentUserId).thenReturn(null);
      when(() => local.get(symbol: '2330.TW', year: 2026, month: 6))
          .thenAnswer((_) async => const Result.failure(NotFoundError()));

      final r = await repo.get(symbol: '2330.TW', year: 2026, month: 6);

      expect((r as Success<CalendarDoc?, AppError>).value, isNull);
      verifyNever(() => remote.listByStock(
          uid: any(named: 'uid'), symbol: any(named: 'symbol')));
    });

    test('local miss + remote NetworkError → 傳遞 Failure', () async {
      when(() => local.get(symbol: '2330.TW', year: 2026, month: 6))
          .thenAnswer((_) async => const Result.failure(NotFoundError()));
      when(() => remote.listByStock(uid: 'uid-1', symbol: '2330.TW'))
          .thenAnswer((_) async => const Result.failure(NetworkError('down')));

      final r = await repo.get(symbol: '2330.TW', year: 2026, month: 6);

      expect(r.isFailure, isTrue);
      expect((r as Failure<CalendarDoc?, AppError>).error, isA<NetworkError>());
    });
  });

  // ─── put ───────────────────────────────────────────────────────────────────

  group('put', () {
    test('local 寫入成功 + remote 成功 → 佇列不會被加入', () async {
      final d = _doc();
      when(() => local.put(d)).thenAnswer((_) async => const Result.success(null));
      when(() => remote.put(uid: 'uid-1', doc: d))
          .thenAnswer((_) async => const Result.success(null));

      final r = await repo.put(d);
      expect(r.isSuccess, isTrue);
      await Future<void>.delayed(Duration.zero);

      expect(metaBox.get(kPendingCalendarWritesKey), anyOf(isNull, isEmpty));
    });

    test('local 寫入成功 + remote 失敗 → composite key 入 writes 佇列', () async {
      final d = _doc();
      when(() => local.put(d)).thenAnswer((_) async => const Result.success(null));
      when(() => remote.put(uid: 'uid-1', doc: d))
          .thenAnswer((_) async => const Result.failure(NetworkError('down')));

      await repo.put(d);
      await Future<void>.delayed(Duration.zero);

      final queue = (metaBox.get(kPendingCalendarWritesKey) as List).cast<String>();
      expect(queue, ['2330.TW:2026-06']);
    });

    test('重複 put 同 key 失敗 → 佇列去重，只有一筆', () async {
      final d = _doc();
      when(() => local.put(d)).thenAnswer((_) async => const Result.success(null));
      when(() => remote.put(uid: 'uid-1', doc: d))
          .thenAnswer((_) async => const Result.failure(NetworkError('down')));

      await repo.put(d);
      await repo.put(d);
      await repo.put(d);
      await Future<void>.delayed(Duration.zero);

      final queue = (metaBox.get(kPendingCalendarWritesKey) as List).cast<String>();
      expect(queue.length, 1);
    });

    test('未登入 → local 寫入成功且不嘗試 remote 也不入佇列', () async {
      when(() => auth.currentUserId).thenReturn(null);
      final d = _doc();
      when(() => local.put(d)).thenAnswer((_) async => const Result.success(null));

      final r = await repo.put(d);
      await Future<void>.delayed(Duration.zero);

      expect(r.isSuccess, isTrue);
      verifyNever(() => remote.put(uid: any(named: 'uid'), doc: any(named: 'doc')));
      expect(metaBox.get(kPendingCalendarWritesKey), anyOf(isNull, isEmpty));
    });

    test('local 寫入失敗 → 直接回 Failure，不嘗試 remote', () async {
      final d = _doc();
      when(() => local.put(d))
          .thenAnswer((_) async => const Result.failure(UnknownError('disk full')));

      final r = await repo.put(d);
      expect(r.isFailure, isTrue);
      verifyNever(() => remote.put(uid: any(named: 'uid'), doc: any(named: 'doc')));
    });
  });

  // ─── delete ────────────────────────────────────────────────────────────────

  group('delete', () {
    test('刪除成功 + remote 失敗 → calendarId 入 deletes 佇列', () async {
      final d = _doc();
      when(() => local.get(symbol: '2330.TW', year: 2026, month: 6))
          .thenAnswer((_) async => Result.success(d));
      when(() => local.delete(symbol: '2330.TW', year: 2026, month: 6))
          .thenAnswer((_) async => const Result.success(null));
      when(() => remote.delete(uid: 'uid-1', calendarId: 'cal-1'))
          .thenAnswer((_) async => const Result.failure(NetworkError('down')));

      await repo.delete(symbol: '2330.TW', year: 2026, month: 6);
      await Future<void>.delayed(Duration.zero);

      final queue =
          (metaBox.get(kPendingCalendarDeletesKey) as List).cast<String>();
      expect(queue, ['cal-1']);
    });

    test('local 沒這個 doc → 不打 remote 也不入佇列', () async {
      when(() => local.get(symbol: '2330.TW', year: 2026, month: 6))
          .thenAnswer((_) async => const Result.failure(NotFoundError()));
      when(() => local.delete(symbol: '2330.TW', year: 2026, month: 6))
          .thenAnswer((_) async => const Result.success(null));

      await repo.delete(symbol: '2330.TW', year: 2026, month: 6);
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => remote.delete(
          uid: any(named: 'uid'), calendarId: any(named: 'calendarId')));
      expect(metaBox.get(kPendingCalendarDeletesKey), anyOf(isNull, isEmpty));
    });
  });

  // ─── flushPendingWrites ────────────────────────────────────────────────────

  group('flushPendingWrites', () {
    test('write queue 全成功 → 佇列清空', () async {
      final d = _doc();
      await metaBox.put(kPendingCalendarWritesKey, ['2330.TW:2026-06']);
      when(() => local.get(symbol: '2330.TW', year: 2026, month: 6))
          .thenAnswer((_) async => Result.success(d));
      when(() => remote.put(uid: 'uid-1', doc: d))
          .thenAnswer((_) async => const Result.success(null));

      await repo.flushPendingWrites();

      expect(metaBox.get(kPendingCalendarWritesKey), isEmpty);
    });

    test('write queue 失敗 → 佇列保留', () async {
      final d = _doc();
      await metaBox.put(kPendingCalendarWritesKey, ['2330.TW:2026-06']);
      when(() => local.get(symbol: '2330.TW', year: 2026, month: 6))
          .thenAnswer((_) async => Result.success(d));
      when(() => remote.put(uid: 'uid-1', doc: d))
          .thenAnswer((_) async => const Result.failure(NetworkError('down')));

      await repo.flushPendingWrites();

      final queue =
          (metaBox.get(kPendingCalendarWritesKey) as List).cast<String>();
      expect(queue, ['2330.TW:2026-06']);
    });

    test('write queue 內 key 已被本地刪除 → drop 該筆', () async {
      await metaBox.put(kPendingCalendarWritesKey, ['2330.TW:2026-06']);
      when(() => local.get(symbol: '2330.TW', year: 2026, month: 6))
          .thenAnswer((_) async => const Result.failure(NotFoundError()));

      await repo.flushPendingWrites();

      expect(metaBox.get(kPendingCalendarWritesKey), isEmpty);
      verifyNever(() => remote.put(uid: any(named: 'uid'), doc: any(named: 'doc')));
    });

    test('delete queue 成功 → 佇列清空', () async {
      await metaBox.put(kPendingCalendarDeletesKey, ['cal-1']);
      when(() => remote.delete(uid: 'uid-1', calendarId: 'cal-1'))
          .thenAnswer((_) async => const Result.success(null));

      await repo.flushPendingWrites();

      expect(metaBox.get(kPendingCalendarDeletesKey), isEmpty);
    });

    test('未登入 → 不執行 flush（佇列原樣保留）', () async {
      when(() => auth.currentUserId).thenReturn(null);
      await metaBox.put(kPendingCalendarWritesKey, ['2330.TW:2026-06']);

      await repo.flushPendingWrites();

      expect(
        (metaBox.get(kPendingCalendarWritesKey) as List).cast<String>(),
        ['2330.TW:2026-06'],
      );
    });
  });

  // ─── watch ─────────────────────────────────────────────────────────────────

  group('watch', () {
    test('初始 emit 來自 get（local hit），之後接 local 變動並 re-read 為精準值',
        () async {
      final d1 = _doc();
      final d2 = _doc().copyWith(title: 'updated');
      final controller = StreamController<CalendarDoc?>.broadcast();

      var getCallCount = 0;
      when(() => local.get(symbol: '2330.TW', year: 2026, month: 6))
          .thenAnswer((_) async {
        getCallCount++;
        return getCallCount == 1 ? Result.success(d1) : Result.success(d2);
      });
      when(() => local.watchByStock('2330.TW'))
          .thenAnswer((_) => controller.stream);

      final events = <CalendarDoc?>[];
      final sub = repo
          .watch(symbol: '2330.TW', year: 2026, month: 6)
          .listen(events.add);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, hasLength(1));
      expect(events.first!.title, '2330.TW-6');

      // 模擬一次 local box 事件 → repo re-read → 拿 d2
      controller.add(d2);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(events, hasLength(2));
      expect(events.last!.title, 'updated');

      await sub.cancel();
      await controller.close();
    });

    test('local 變動後 re-read 為 NotFound → emit null（避免「同 symbol 別月刪除」誤觸發）',
        () async {
      final d = _doc();
      final controller = StreamController<CalendarDoc?>.broadcast();
      var calls = 0;
      when(() => local.get(symbol: '2330.TW', year: 2026, month: 6))
          .thenAnswer((_) async {
        calls++;
        return calls == 1
            ? Result.success(d)
            : const Result.failure(NotFoundError());
      });
      when(() => local.watchByStock('2330.TW'))
          .thenAnswer((_) => controller.stream);

      final events = <CalendarDoc?>[];
      final sub = repo
          .watch(symbol: '2330.TW', year: 2026, month: 6)
          .listen(events.add);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      controller.add(null); // DS emit delete
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(events, [d, null]);

      await sub.cancel();
      await controller.close();
    });
  });
}
