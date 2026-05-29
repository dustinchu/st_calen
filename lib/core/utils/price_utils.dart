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

// ---------------------------------------------------------------------------
// settle helpers (Step 16)
// ---------------------------------------------------------------------------

/// Settle 結果（pure value type）。
class SettleResult {
  /// 命中與否。
  final bool hit;

  /// 「偏離百分比」：actual 相對預測值的差距。
  ///
  /// 各 type 定義：
  /// - customPrice：(actualClose - predictedPrice) / predictedPrice × 100
  /// - customPercent：actualPercent - predictedPercent（單位 pp，已是百分點）
  /// - bullish / bearish / upLimit / downLimit：actualChangePercent（漲跌幅）
  final double hitPercent;

  const SettleResult({required this.hit, required this.hitPercent});
}

/// 結算自訂價：actualClose 必須**嚴格等於** predictedPrice（台股 tick aligned）。
SettleResult settleCustomPrice({
  required double predictedPrice,
  required double actualClose,
}) {
  final diffPercent = predictedPrice <= 0
      ? 0.0
      : (actualClose - predictedPrice) / predictedPrice * 100;
  // 嚴格等於：用 cents 比對避免 double 浮點誤差
  final hit = (predictedPrice * 100).round() == (actualClose * 100).round();
  return SettleResult(hit: hit, hitPercent: diffPercent);
}

/// 結算自訂漲跌幅：比對到小數第一位（±0.05pp 容許）。
SettleResult settleCustomPercent({
  required double predictedPercent,
  required double prevClose,
  required double actualClose,
}) {
  final actualPercent = changePercent(prevClose, actualClose) ?? 0.0;
  final diff = actualPercent - predictedPercent;
  // 小數第一位相等 = 差距 < 0.05pp
  final hit = diff.abs() < 0.05;
  return SettleResult(hit: hit, hitPercent: diff);
}

/// 結算看多：actualClose **嚴格大於** prevClose（平盤算沒命中）。
SettleResult settleBullish({
  required double prevClose,
  required double actualClose,
}) {
  final pct = changePercent(prevClose, actualClose) ?? 0.0;
  return SettleResult(hit: actualClose > prevClose, hitPercent: pct);
}

/// 結算看空：actualClose **嚴格小於** prevClose（平盤算沒命中）。
SettleResult settleBearish({
  required double prevClose,
  required double actualClose,
}) {
  final pct = changePercent(prevClose, actualClose) ?? 0.0;
  return SettleResult(hit: actualClose < prevClose, hitPercent: pct);
}

/// 結算漲停預測：actual 漲幅 ≥ +10%（用 cents 嚴格比對避免浮點誤差）。
SettleResult settleUpLimit({
  required double prevClose,
  required double actualClose,
}) {
  final pct = changePercent(prevClose, actualClose) ?? 0.0;
  // ≥ +10%：actualCents × 10 ≥ prevCents × 11
  final prevCents = (prevClose * 100).round();
  final actualCents = (actualClose * 100).round();
  final hit = prevCents > 0 && actualCents * 10 >= prevCents * 11;
  return SettleResult(hit: hit, hitPercent: pct);
}

/// 結算平盤：actualClose **嚴格等於** prevClose（用 cents 整數比對避免浮點誤差）。
SettleResult settleFlat({
  required double prevClose,
  required double actualClose,
}) {
  final pct = changePercent(prevClose, actualClose) ?? 0.0;
  final hit = (prevClose * 100).round() == (actualClose * 100).round();
  return SettleResult(hit: hit, hitPercent: pct);
}

/// 結算跌停預測：actual 跌幅 ≤ -10%。
SettleResult settleDownLimit({
  required double prevClose,
  required double actualClose,
}) {
  final pct = changePercent(prevClose, actualClose) ?? 0.0;
  final prevCents = (prevClose * 100).round();
  final actualCents = (actualClose * 100).round();
  final hit = prevCents > 0 && actualCents * 10 <= prevCents * 9;
  return SettleResult(hit: hit, hitPercent: pct);
}
