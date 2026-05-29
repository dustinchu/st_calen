import '../../../core/utils/result.dart';
import '../../../data/models/market.dart';
import '../../../data/models/stock.dart';

/// 股票搜尋 / 報價 API client。
///
/// Step 14 階段先用 mock 實作（hard-code 一小張表）讓 UI 跑通，
/// Step 11 之後會用 Dio 串實際 `GET /api/v1/stocks/search?q=...&market=...`
/// 與 `GET /api/v1/stocks/{symbol}/quotes?from=...&to=...`。
abstract class StockApiClient {
  Future<Result<List<Stock>, AppError>> search(String query);

  /// 取得 [symbol] 自 [from] 至 [to]（皆 UTC、day-level）的每日收盤價（含端點）。
  ///
  /// 回傳 Map<日(UTC, time=0), close>。某日無資料（假日 / 停牌 / 未來日）→ 不出現在 Map。
  /// Step 16 mock 階段：7 支熱門股寫死過去 60 個交易日的隨機（但 deterministic）價格。
  Future<Result<Map<DateTime, double>, AppError>> quotes({
    required String symbol,
    required DateTime from,
    required DateTime to,
  });
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

  /// 各股票基準價（mock 用，從基準價沿時間做小幅 deterministic 抖動）。
  static const Map<String, double> _basePrice = {
    '2330.TW': 1000.0,
    '2317.TW': 200.0,
    '0050.TW': 180.0,
    '2454.TW': 1200.0,
    'AAPL': 220.0,
    'NVDA': 140.0,
    'TSLA': 250.0,
  };

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

  @override
  Future<Result<Map<DateTime, double>, AppError>> quotes({
    required String symbol,
    required DateTime from,
    required DateTime to,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final base = _basePrice[symbol];
    if (base == null) {
      return const Result.success(<DateTime, double>{});
    }
    final today = DateTime.now().toUtc();
    final todayUtc = DateTime.utc(today.year, today.month, today.day);
    final fromUtc = DateTime.utc(from.year, from.month, from.day);
    final toUtc = DateTime.utc(to.year, to.month, to.day);

    final out = <DateTime, double>{};
    var d = fromUtc;
    while (!d.isAfter(toUtc)) {
      // 未來日不結算
      if (d.isAfter(todayUtc)) break;
      // 跳過週末（mock：簡化版休市）
      final weekday = d.weekday;
      if (weekday != DateTime.saturday && weekday != DateTime.sunday) {
        out[d] = _mockClose(symbol, base, d);
      }
      d = d.add(const Duration(days: 1));
    }
    return Result.success(out);
  }

  /// Deterministic 假價：base × (1 + sin(dayHash) × 0.05)，
  /// 再 snap 到 TWSE tick（台股）或直接 round 到 0.01（美股）。
  static double _mockClose(String symbol, double base, DateTime day) {
    final seed = day.year * 10000 + day.month * 100 + day.day;
    // 簡單 deterministic noise：[-0.05, +0.05]
    final phase = (seed * 2654435761) & 0xFFFFFFFF;
    final norm = (phase / 0xFFFFFFFF) * 2 - 1; // [-1, 1]
    final raw = base * (1 + norm * 0.05);
    if (symbol.endsWith('.TW')) {
      final cents = (raw * 100).round();
      final tick = _twTickCents(cents);
      return ((cents ~/ tick) * tick) / 100;
    }
    return (raw * 100).round() / 100;
  }

  static int _twTickCents(int priceCents) {
    if (priceCents < 1000) return 1;
    if (priceCents < 5000) return 5;
    if (priceCents < 10000) return 10;
    if (priceCents < 50000) return 50;
    if (priceCents < 100000) return 100;
    return 500;
  }
}
