import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stock_calendar/core/storage/hive_boxes.dart';
import 'package:stock_calendar/core/storage/hive_init.dart';
import 'package:stock_calendar/core/storage/local_data_reset.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('reset_test');
    Hive.init(tempDir.path);
    HiveInit.registerAdaptersForTest();
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  late Box<dynamic> calendars;
  late Box<dynamic> stocks;
  late Box<dynamic> settings;
  late Box<dynamic> meta;

  setUp(() async {
    final suffix = DateTime.now().microsecondsSinceEpoch;
    calendars = await Hive.openBox<dynamic>('cal_$suffix');
    stocks = await Hive.openBox<dynamic>('stk_$suffix');
    settings = await Hive.openBox<dynamic>('set_$suffix');
    meta = await Hive.openBox<dynamic>('meta_$suffix');
  });

  tearDown(() async {
    await calendars.deleteFromDisk();
    await stocks.deleteFromDisk();
    await settings.deleteFromDisk();
    await meta.deleteFromDisk();
  });

  test('清空 calendars / stocks / settings 三個 box', () async {
    await calendars.put('c1', 'cal-data');
    await stocks.put('s1', 'stock-data');
    await settings.put(kSettingsKey, 'settings-data');

    await resetLocalData(
      calendars: calendars,
      stocks: stocks,
      settings: settings,
      meta: meta,
    );

    expect(calendars.isEmpty, isTrue);
    expect(stocks.isEmpty, isTrue);
    expect(settings.isEmpty, isTrue);
  });

  test('保留 meta 的 onboarding flag、移除待同步佇列', () async {
    await meta.put(kOnboardingCompletedKey, true);
    await meta.put(kPendingCalendarWritesKey, <String>['2330.TW:2026-05']);
    await meta.put(kPendingCalendarDeletesKey, <String>['uuid-1']);

    await resetLocalData(
      calendars: calendars,
      stocks: stocks,
      settings: settings,
      meta: meta,
    );

    expect(meta.get(kOnboardingCompletedKey), isTrue,
        reason: '重設後不應被丟回 onboarding');
    expect(meta.containsKey(kPendingCalendarWritesKey), isFalse);
    expect(meta.containsKey(kPendingCalendarDeletesKey), isFalse);
  });
}
