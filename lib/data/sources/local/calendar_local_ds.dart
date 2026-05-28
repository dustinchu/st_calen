import 'package:hive/hive.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../core/utils/result.dart';
import '../../models/calendar_doc.dart';

/// 月曆預測資料的本地（Hive）資料來源。
///
/// Box key 規則：`<symbol>:<YYYY-MM>`，例如 `2330.TW:2026-06`。
/// 一支股票一個月一筆 [CalendarDoc]，整份 doc（含 predictions list）整批讀寫。
class CalendarLocalDataSource {
  final Box<dynamic> _box;

  CalendarLocalDataSource(this._box);

  static Future<Box<dynamic>> openBox() =>
      Hive.openBox<dynamic>(kCalendarsBox);

  static String keyOf(String symbol, int year, int month) =>
      '$symbol:${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

  Future<Result<CalendarDoc, AppError>> get({
    required String symbol,
    required int year,
    required int month,
  }) async {
    try {
      final raw = _box.get(keyOf(symbol, year, month));
      if (raw == null) {
        return Result.failure(NotFoundError('calendar not found: $symbol $year-$month'));
      }
      return Result.success(raw as CalendarDoc);
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  Future<Result<void, AppError>> put(CalendarDoc doc) async {
    try {
      await _box.put(keyOf(doc.symbol, doc.year, doc.month), doc);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  Future<Result<void, AppError>> delete({
    required String symbol,
    required int year,
    required int month,
  }) async {
    try {
      await _box.delete(keyOf(symbol, year, month));
      return const Result.success(null);
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  Future<Result<List<CalendarDoc>, AppError>> getAll() async {
    try {
      final values = _box.values.whereType<CalendarDoc>().toList(growable: false);
      return Result.success(values);
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  /// 訂閱指定 stock 的 doc 變動。emit `CalendarDoc?`：
  /// - 寫入/更新 → 最新的 doc
  /// - 刪除 → null
  ///
  /// 不會 emit 初始值（呼叫端用 [get] 補一次）。
  Stream<CalendarDoc?> watchByStock(String symbol) {
    final prefix = '$symbol:';
    return _box.watch().where((event) {
      final key = event.key;
      return key is String && key.startsWith(prefix);
    }).map((event) => event.deleted ? null : event.value as CalendarDoc);
  }
}
