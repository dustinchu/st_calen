import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stock_calendar/core/storage/hive_init.dart';
import 'package:stock_calendar/core/utils/result.dart';
import 'package:stock_calendar/data/models/app_settings.dart';
import 'package:stock_calendar/data/repositories/settings_repository.dart';
import 'package:stock_calendar/data/sources/local/settings_local_ds.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('settings_repo_test');
    Hive.init(tempDir.path);
    HiveInit.registerAdaptersForTest();
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  late Box<dynamic> box;
  late SettingsLocalDataSource ds;
  late SettingsRepository repo;

  setUp(() async {
    box = await Hive.openBox<dynamic>(
        'settings_repo_test_${DateTime.now().microsecondsSinceEpoch}');
    ds = SettingsLocalDataSource(box);
    repo = SettingsRepository(local: ds);
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  test('首次 get：DS 回 NotFoundError → repo 回 Success(預設值)', () async {
    final r = await repo.get();
    expect(r, isA<Success<AppSettings, AppError>>());
    expect((r as Success<AppSettings, AppError>).value, const AppSettings());
  });

  test('update 後 get 拿回新值', () async {
    final updated = const AppSettings(themeId: 'dark', autoSettleEnabled: false);
    expect((await repo.update(updated)).isSuccess, isTrue);
    final r = await repo.get();
    expect((r as Success<AppSettings, AppError>).value, updated);
  });

  test('watch：初始 emit 預設值（box 空），之後接 update', () async {
    final events = <AppSettings>[];
    final sub = repo.watch().listen(events.add);

    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(events, hasLength(1));
    expect(events.first, const AppSettings());

    await repo.update(const AppSettings(themeId: 'dark'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(events.last.themeId, 'dark');

    await sub.cancel();
  });

  test('watch：初始時已有值 → emit 當前值', () async {
    await repo.update(const AppSettings(lastSelectedSymbol: '2330.TW'));

    final events = <AppSettings>[];
    final sub = repo.watch().listen(events.add);

    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(events.first.lastSelectedSymbol, '2330.TW');

    await sub.cancel();
  });
}
