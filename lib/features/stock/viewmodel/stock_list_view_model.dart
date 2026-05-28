import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../data/models/stock.dart';
import '../../../data/repositories/stock_repository.dart';
import '../../../data/sources/local/stock_local_ds.dart';
import '../data/stock_api_client.dart';

part 'stock_list_view_model.g.dart';

@Riverpod(keepAlive: true)
StockLocalDataSource stockLocalDataSource(Ref ref) =>
    StockLocalDataSource(Hive.box<dynamic>(kStocksBox));

@Riverpod(keepAlive: true)
StockRepository stockRepository(Ref ref) =>
    StockRepository(local: ref.watch(stockLocalDataSourceProvider));

/// Step 14 階段固定回 mock。Step 11 之後改成 Dio 實作並接 base URL。
@Riverpod(keepAlive: true)
StockApiClient stockApiClient(Ref ref) => const MockStockApiClient();

/// 訂閱 watch list；UI 用這個 provider 拿 chips bar 顯示用的清單。
@riverpod
Stream<List<Stock>> stockListViewModel(Ref ref) =>
    ref.watch(stockRepositoryProvider).watch();
