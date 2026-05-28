import '../../../core/utils/result.dart';
import '../../../data/models/market.dart';
import '../../../data/models/stock.dart';

/// 股票搜尋 API client。
///
/// Step 14 階段先用 mock 實作（hard-code 一小張表）讓 UI 跑通，
/// Step 11 之後會用 Dio 串實際 `GET /api/v1/stocks/search?q=...&market=...`，
/// 並把 [StockApiClient] 改成 abstract / interface 由實作版替換。
abstract class StockApiClient {
  Future<Result<List<Stock>, AppError>> search(String query);
}

/// Mock 實作。回傳預先寫死的一張表，做大小寫不敏感、symbol / name substring 模糊比對。
class MockStockApiClient implements StockApiClient {
  static const List<Stock> _seed = [
    Stock(symbol: '2330.TW', market: Market.tw, name: '台積電'),
    Stock(symbol: '2317.TW', market: Market.tw, name: '鴻海'),
    Stock(symbol: '0050.TW', market: Market.tw, name: '元大台灣50'),
    Stock(symbol: '2454.TW', market: Market.tw, name: '聯發科'),
    Stock(symbol: 'AAPL', market: Market.us, name: 'Apple Inc.'),
    Stock(symbol: 'NVDA', market: Market.us, name: 'NVIDIA Corporation'),
    Stock(symbol: 'TSLA', market: Market.us, name: 'Tesla, Inc.'),
  ];

  const MockStockApiClient();

  @override
  Future<Result<List<Stock>, AppError>> search(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const Result.success([]);
    final hits = _seed.where((s) {
      return s.symbol.toLowerCase().contains(q) ||
          s.name.toLowerCase().contains(q);
    }).toList(growable: false);
    return Result.success(hits);
  }
}
