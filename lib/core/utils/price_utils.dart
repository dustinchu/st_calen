/// 漲跌幅與台股漲跌停判定。
///
/// 台股漲跌停採嚴謹版：以 TWSE tick size 反推漲停 / 跌停價再比對。
/// 美股無漲跌停制度，一律回傳 false。
///
/// `market` 用字串 'tw' / 'us'，對齊後端 04-backend-spec.md 的 `market` 欄位
/// 與 03-data-model.md 的 `Market` enum 序列化值。Step 4 引入 enum 後可
/// 再加一個 `Market` 版本的 overload，或讓呼叫端傳 `market.name`。
library;

/// 漲跌幅（百分比）。`prev` 為 0 或負數時回傳 null（除零保護）。
double? changePercent(num prev, num current) {
  if (prev <= 0) return null;
  return (current - prev) / prev * 100;
}

/// 是否為漲停（台股）。美股直接 false。
bool isUpLimit({
  required double prev,
  required double current,
  required String market,
}) {
  if (market != 'tw') return false;
  if (prev <= 0) return false;
  final currentCents = (current * 100).round();
  return currentCents >= _twUpLimitCents(prev);
}

/// 是否為跌停（台股）。美股直接 false。
bool isDownLimit({
  required double prev,
  required double current,
  required String market,
}) {
  if (market != 'tw') return false;
  if (prev <= 0) return false;
  final currentCents = (current * 100).round();
  return currentCents <= _twDownLimitCents(prev);
}

/// 台股漲停價（元）。
double twUpLimitPrice(double prev) => _twUpLimitCents(prev) / 100;

/// 台股跌停價（元）。
double twDownLimitPrice(double prev) => _twDownLimitCents(prev) / 100;

// ---------------------------------------------------------------------------
// internals
// ---------------------------------------------------------------------------

int _twUpLimitCents(double prev) {
  final prevCents = (prev * 100).round();
  // prev * 1.1，先計算到 cents（向下取整 = TWSE 漲停定義不超過 ±10%）
  final rawCents = (prevCents * 11) ~/ 10;
  final tick = _twTickCents(rawCents);
  return (rawCents ~/ tick) * tick;
}

int _twDownLimitCents(double prev) {
  final prevCents = (prev * 100).round();
  // prev * 0.9，向上取整 = TWSE 跌停定義不低於 ±10%
  final rawCents = (prevCents * 9 + 9) ~/ 10;
  final tick = _twTickCents(rawCents);
  // ceil to multiple of tick
  return ((rawCents + tick - 1) ~/ tick) * tick;
}

/// TWSE tick size，回傳以 0.01 元為單位的整數。
/// 規則（依漲跌停價所在價格區間）：
/// <10: 0.01 / <50: 0.05 / <100: 0.1 / <500: 0.5 / <1000: 1 / >=1000: 5
int _twTickCents(int priceCents) {
  if (priceCents < 1000) return 1;
  if (priceCents < 5000) return 5;
  if (priceCents < 10000) return 10;
  if (priceCents < 50000) return 50;
  if (priceCents < 100000) return 100;
  return 500;
}
