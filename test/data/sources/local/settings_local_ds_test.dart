import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stock_calendar/core/storage/hive_init.dart';
import 'package:stock_calendar/core/utils/result.dart';
import 'package:stock_calendar/data/models/app_settings.dart';
import 'package:stock_calendar/data/sources/local/settings_local_ds.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('settings_ds_test');
    Hive.init(tempDir.path);
    HiveInit.registerAdaptersForTest();
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  late Box<dynamic> box;
  late SettingsLocalDataSource ds;

  setUp(() async {
    box = await Hive.openBox<dynamic>('settings_test_${DateTime.now().microsecondsSinceEpoch}');
    ds = SettingsLocalDataSource(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  test('第一次 get 無 value 回 NotFoundError（不寫入預設值）', () async {
    final got = await ds.get();
    expect(got, isA<Failure<AppSettings, AppError>>());
    expect((got as Failure<AppSettings, AppError>).error, isA<NotFoundError>());
    expect(box.get('app'), isNull, reason: 'data source 不應自動落地預設值');
  });

  test('put 後 get 拿回相同 settings', () async {
    const s = AppSettings(themeId: 'dark', lastSelectedSymbol: '2330.TW');
    await ds.put(s);
    final got = await ds.get();
    expect((got as Success<AppSettings, AppError>).value, s);
  });

  test('put 同 key 覆寫', () async {
    await ds.put(const AppSettings(themeId: 'a'));
    await ds.put(const AppSettings(themeId: 'b'));
    final got = await ds.get();
    expect((got as Success<AppSettings, AppError>).value.themeId, 'b');
  });

  test('watch emit 寫入後最新值，刪除後 null', () async {
    final events = <AppSettings?>[];
    final sub = ds.watch().listen(events.add);

    await ds.put(const AppSettings(themeId: 'a'));
    await ds.put(const AppSettings(themeId: 'b'));
    await box.delete('app');

    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();

    expect(events.length, 3);
    expect(events[0]?.themeId, 'a');
    expect(events[1]?.themeId, 'b');
    expect(events[2], isNull);
  });
}
