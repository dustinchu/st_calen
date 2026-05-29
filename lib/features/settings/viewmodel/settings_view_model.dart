import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/hive_boxes.dart';
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

  Future<void> setThemeId(String id) async {
    final repo = ref.read(settingsRepositoryProvider);
    final cur = (await repo.get()).fold((s) => s, (_) => const AppSettings());
    await repo.update(cur.copyWith(themeId: id));
  }
}
