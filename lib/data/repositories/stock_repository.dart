import '../../core/utils/result.dart';
import '../models/stock.dart';
import '../sources/local/stock_local_ds.dart';

/// 用戶自選股清單的 Repository。
///
/// Phase 1 決議：自選股**不**做 Firestore 同步，純本地（Hive）。重裝 app 會消失，
/// 但自選股清單通常很小、重建成本低，可接受。未來若需要跨裝置同步，
/// 再加 `watched_stocks_firestore_ds` + 對應 queue 邏輯（對齊 calendar_repository）。
class StockRepository {
  final StockLocalDataSource _local;

  StockRepository({required StockLocalDataSource local}) : _local = local;

  Future<Result<List<Stock>, AppError>> list() => _local.getAll();

  Future<Result<void, AppError>> add(Stock stock) => _local.put(stock);

  Future<Result<void, AppError>> remove(String symbol) => _local.delete(symbol);

  /// Hot stream：初始 emit 來自 [list]，之後接 local box 變動。
  Stream<List<Stock>> watch() async* {
    final initial = await list();
    yield initial.fold((v) => v, (_) => const <Stock>[]);
    yield* _local.watchAll();
  }
}
