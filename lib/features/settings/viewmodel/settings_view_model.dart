import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/storage/hive_boxes.dart';
import '../../../core/storage/local_data_reset.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/sources/local/settings_local_ds.dart';

part 'settings_view_model.g.dart';

@Riverpod(keepAlive: true)
SettingsLocalDataSource settingsLocalDataSource(Ref ref) =>
    SettingsLocalDataSource(Hive.box<dynamic>(kSettingsBox));

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    SettingsRepository(local: ref.watch(settingsLocalDataSourceProvider));

/// Hot stream：訂閱 AppSettings 變動。第一次 emit 來自 repo.get（預設值 fallback）。
@riverpod
Stream<AppSettings> settingsViewModel(Ref ref) =>
    ref.watch(settingsRepositoryProvider).watch();

/// 更新單一欄位（read-modify-put）。
@riverpod
class SettingsController extends _$SettingsController {
  @override
  void build() {}

  Future<void> setAutoSettleEnabled(bool v) async {
    final repo = ref.read(settingsRepositoryProvider);
    final cur = (await repo.get()).fold((s) => s, (_) => const AppSettings());
    await repo.update(cur.copyWith(autoSettleEnabled: v));
  }

  Future<void> setNotificationsEnabled(bool v) async {
    final repo = ref.read(settingsRepositoryProvider);
    final cur = (await repo.get()).fold((s) => s, (_) => const AppSettings());
    await repo.update(cur.copyWith(notificationsEnabled: v));
    await notificationService.applyEnabled(v);
  }

  Future<void> setThemeId(String id) async {
    final repo = ref.read(settingsRepositoryProvider);
    final cur = (await repo.get()).fold((s) => s, (_) => const AppSettings());
    await repo.update(cur.copyWith(themeId: id));
  }

  /// 重設本地資料：清 calendars / stocks / settings + meta 待同步佇列（保留
  /// onboarding flag、不登出）。settings 清空後回預設（notificationsEnabled=true），
  /// 故重排每日提醒讓行為與預設一致。box 由 bootstrap 預先 open，sync 取得。
  Future<void> resetAllLocalData() async {
    await resetLocalData(
      calendars: Hive.box<dynamic>(kCalendarsBox),
      stocks: Hive.box<dynamic>(kStocksBox),
      settings: Hive.box<dynamic>(kSettingsBox),
      meta: Hive.box<dynamic>(kMetaBox),
    );
    await notificationService.applyEnabled(true);
  }
}
