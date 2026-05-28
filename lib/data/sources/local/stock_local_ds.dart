import 'package:hive/hive.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../core/utils/result.dart';
import '../../models/stock.dart';

/// 用戶追蹤股票清單的本地（Hive）資料來源。
///
/// Box key = `symbol`（例如 `2330.TW`）。排序留給 ViewModel（依 AppSettings）。
class StockLocalDataSource {
  final Box<dynamic> _box;

  StockLocalDataSource(this._box);

  static Future<Box<dynamic>> openBox() => Hive.openBox<dynamic>(kStocksBox);

  Future<Result<List<Stock>, AppError>> getAll() async {
    try {
      final values = _box.values.whereType<Stock>().toList(growable: false);
      return Result.success(values);
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  Future<Result<Stock, AppError>> get(String symbol) async {
    try {
      final raw = _box.get(symbol);
      if (raw == null) return Result.failure(NotFoundError('stock not found: $symbol'));
      return Result.success(raw as Stock);
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  Future<Result<void, AppError>> put(Stock stock) async {
    try {
      await _box.put(stock.symbol, stock);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  Future<Result<void, AppError>> delete(String symbol) async {
    try {
      await _box.delete(symbol);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  /// 訂閱清單變動。每次 box event 觸發時 emit 當前完整列表 snapshot。
  /// 不會 emit 初始值（呼叫端用 [getAll] 補一次）。
  Stream<List<Stock>> watchAll() {
    return _box
        .watch()
        .map((_) => _box.values.whereType<Stock>().toList(growable: false));
  }
}
