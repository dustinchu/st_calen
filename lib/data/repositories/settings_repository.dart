import '../../core/utils/result.dart';
import '../models/app_settings.dart';
import '../sources/local/settings_local_ds.dart';

/// AppSettings 的 Repository。
///
/// Phase 1 決議：**不**做 Firestore 同步（避免跨裝置 settings 覆蓋衝突，
/// 也避免使用者在裝置 A 改設定，裝置 B 上次同步的舊值蓋回來）。
///
/// 預設值（[AppSettings] constructor 預設）落地在 Repository 層：DS 第一次讀
/// 為 `NotFoundError` 時 → 回 `Success(AppSettings())`，保持 DS 層「不寫入預設值」契約。
class SettingsRepository {
  final SettingsLocalDataSource _local;

  SettingsRepository({required SettingsLocalDataSource local}) : _local = local;

  Future<Result<AppSettings, AppError>> get() async {
    final r = await _local.get();
    return switch (r) {
      Success(value: final v) => Result.success(v),
      Failure(error: final e) => e is NotFoundError
          ? const Result.success(AppSettings())
          : Result.failure(e),
    };
  }

  Future<Result<void, AppError>> update(AppSettings settings) =>
      _local.put(settings);

  /// Hot stream：初始 emit 來自 [get]（NotFoundError → 預設值），
  /// 之後接 local box 變動；DS 的 null（刪除）也映射成預設值。
  Stream<AppSettings> watch() async* {
    final initial = await get();
    yield initial.fold((v) => v, (_) => const AppSettings());
    yield* _local.watch().map((s) => s ?? const AppSettings());
  }
}
