import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stock_calendar/core/storage/hive_init.dart';
import 'package:stock_calendar/core/utils/result.dart';
import 'package:stock_calendar/data/models/calendar_doc.dart';
import 'package:stock_calendar/data/sources/local/calendar_local_ds.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('calendar_ds_test');
    Hive.init(tempDir.path);
    HiveInit.registerAdaptersForTest();
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  late Box<dynamic> box;
  late CalendarLocalDataSource ds;

  CalendarDoc makeDoc({
    String symbol = '2330.TW',
    int year = 2026,
    int month = 6,
    String id = 'doc-1',
  }) {
    final now = DateTime.utc(2026, 6, 1);
    return CalendarDoc(
      id: id,
      userId: 'u1',
      symbol: symbol,
      year: year,
      month: month,
      title: '$symbol $month 月',
      themeId: 'def',
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() async {
    box = await Hive.openBox<dynamic>('calendars_test_${DateTime.now().microsecondsSinceEpoch}');
    ds = CalendarLocalDataSource(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  test('keyOf 格式為 symbol:YYYY-MM 並補零', () {
    expect(CalendarLocalDataSource.keyOf('2330.TW', 2026, 6), '2330.TW:2026-06');
    expect(CalendarLocalDataSource.keyOf('AAPL', 2026, 12), 'AAPL:2026-12');
  });

  test('put 後 get 拿回相同 doc', () async {
    final doc = makeDoc();
    expect((await ds.put(doc)).isSuccess, isTrue);

    final got = await ds.get(symbol: '2330.TW', year: 2026, month: 6);
    expect(got, isA<Success<CalendarDoc, AppError>>());
    expect((got as Success<CalendarDoc, AppError>).value.id, 'doc-1');
  });

  test('get 不存在 key 回 NotFoundError', () async {
    final got = await ds.get(symbol: '9999.TW', year: 2026, month: 1);
    expect(got, isA<Failure<CalendarDoc, AppError>>());
    expect((got as Failure<CalendarDoc, AppError>).error, isA<NotFoundError>());
  });

  test('delete 後 get 回 NotFoundError', () async {
    await ds.put(makeDoc());
    await ds.delete(symbol: '2330.TW', year: 2026, month: 6);
    final got = await ds.get(symbol: '2330.TW', year: 2026, month: 6);
    expect(got, isA<Failure<CalendarDoc, AppError>>());
  });

  test('getAll 回 box 內全部 CalendarDoc', () async {
    await ds.put(makeDoc(id: 'a'));
    await ds.put(makeDoc(id: 'b', month: 7));
    await ds.put(makeDoc(id: 'c', symbol: 'AAPL'));
    final r = await ds.getAll();
    expect(r, isA<Success<List<CalendarDoc>, AppError>>());
    expect((r as Success<List<CalendarDoc>, AppError>).value, hasLength(3));
  });

  test('watchByStock 只 emit 對應 symbol 的事件，刪除回 null', () async {
    final events = <CalendarDoc?>[];
    final sub = ds.watchByStock('2330.TW').listen(events.add);

    await ds.put(makeDoc(symbol: '2330.TW', month: 6));
    await ds.put(makeDoc(symbol: 'AAPL', month: 6)); // 應被過濾
    await ds.put(makeDoc(symbol: '2330.TW', month: 7));
    await ds.delete(symbol: '2330.TW', year: 2026, month: 6);

    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();

    expect(events.length, 3);
    expect(events[0]?.month, 6);
    expect(events[1]?.month, 7);
    expect(events[2], isNull);
  });
}
