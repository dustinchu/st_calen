import 'package:hive/hive.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../core/utils/result.dart';
import '../../models/app_settings.dart';

/// App 設定的本地（Hive）資料來源。單一 key = [kSettingsKey]（`'app'`）。
///
/// 第一次讀取無 value 時回 `Result.failure(NotFoundError)`，
/// 由 Repository 決定是否落地預設值（避免 data source 產生隱性 side-effect）。
class SettingsLocalDataSource {
  final Box<dynamic> _box;

  SettingsLocalDataSource(this._box);

  static Future<Box<dynamic>> openBox() =>
      Hive.openBox<dynamic>(kSettingsBox);

  Future<Result<AppSettings, AppError>> get() async {
    try {
      final raw = _box.get(kSettingsKey);
      if (raw == null) return const Result.failure(NotFoundError('settings not initialized'));
      return Result.success(raw as AppSettings);
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  Future<Result<void, AppError>> put(AppSettings settings) async {
    try {
      await _box.put(kSettingsKey, settings);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  /// 訂閱設定變動。emit `AppSettings?`：寫入後最新值；刪除 → null。
  /// 不會 emit 初始值（呼叫端用 [get] 補一次）。
  Stream<AppSettings?> watch() {
    return _box
        .watch(key: kSettingsKey)
        .map((event) => event.deleted ? null : event.value as AppSettings);
  }
}
