import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/price_utils.dart';
import '../../../core/utils/result.dart';
import '../../../data/models/calendar_doc.dart';
import '../../../data/models/prediction.dart';
import '../../../data/models/prediction_type.dart';
import '../../settings/viewmodel/settings_view_model.dart';
import '../../stock/viewmodel/stock_list_view_model.dart';
import 'calendar_view_model.dart';

part 'settlement_view_model.g.dart';

/// 自動結算 ViewModel：
/// 訂閱 [calendarViewModelProvider] + autoSettleEnabled，當有「過去日 × 未 settled」
/// prediction 時，向 [StockApiClient.quotes] 拉收盤資料，計算 hit / hitPercent 並
/// read-modify-put 寫回 repo。
///
/// 失敗策略：quotes 失敗 / 某日無資料 → 保留 `settled = false`（不阻塞 UI），
/// 由 PredictionEditorSheet 的手動補價路徑補進。
///
/// 觸發時機：build() 內讀 doc 與 settings；當 doc 更新 → riverpod re-build → 重跑
/// settle 流程；autoSettleEnabled OFF → 立即 return。
@riverpod
class SettlementViewModel extends _$SettlementViewModel {
  bool _running = false;

  @override
  Future<void> build() async {
    final docAsync = ref.watch(calendarViewModelProvider);
    final settingsAsync = ref.watch(settingsViewModelProvider);
    final doc = docAsync.valueOrNull;
    final settings = settingsAsync.valueOrNull;
    if (doc == null || settings == null) return;
    if (!settings.autoSettleEnabled) return;

    final candidates = _candidates(doc);
    if (candidates.isEmpty) return;

    // 防併發 re-entry
    if (_running) return;
    _running = true;
    try {
      await _settleAll(doc, candidates);
    } finally {
      _running = false;
    }
  }

  /// 公開：手動補價（PredictionEditorSheet 用）。
  /// 給定 (date, actualClose) → 用 prevClose（自動拉前一交易日）算 settle 並寫回。
  Future<bool> manualSettle({
    required DateTime date,
    required double actualClose,
  }) async {
    final doc = ref.read(calendarViewModelProvider).valueOrNull;
    if (doc == null) return false;
    final target = _findByDay(doc, date);
    if (target == null) return false;

    final prevClose = await _fetchPrevClose(doc.symbol, date);
    final result = _computeSettle(target, prevClose, actualClose);
    if (result == null) return false;

    final updated = _writeBack(doc, target, actualClose, result);
    final r = await ref.read(calendarRepositoryProvider).put(updated);
    return r.isSuccess;
  }

  // ─── internals ───────────────────────────────────────────────────────────

  List<Prediction> _candidates(CalendarDoc doc) {
    final todayUtc = _todayUtc();
    return doc.predictions.where((p) {
      if (p.settled) return false;
      final d = DateTime.utc(
        p.date.toLocal().year,
        p.date.toLocal().month,
        p.date.toLocal().day,
      );
      return d.isBefore(todayUtc);
    }).toList(growable: false);
  }

  Future<void> _settleAll(
    CalendarDoc doc,
    List<Prediction> candidates,
  ) async {
    final client = ref.read(stockApiClientProvider);
    // 一次拉整個月 + 前一日（給 bullish/bearish/customPercent 用 prevClose）
    final dates = candidates
        .map((p) => DateTime.utc(p.date.toLocal().year,
            p.date.toLocal().month, p.date.toLocal().day))
        .toList()
      ..sort();
    final from = dates.first.subtract(const Duration(days: 5)); // 多抓週末緩衝
    final to = dates.last;

    final r = await client.quotes(symbol: doc.symbol, from: from, to: to);
    if (r is! Success<Map<DateTime, double>, AppError>) return;
    final quotes = r.value;
    if (quotes.isEmpty) return;

    var current = doc;
    var changed = false;
    for (final p in candidates) {
      final dayUtc = DateTime.utc(p.date.toLocal().year,
          p.date.toLocal().month, p.date.toLocal().day);
      final actual = quotes[dayUtc];
      if (actual == null) continue; // 無資料 → 跳過保留 unsettled
      final prevClose = _findPrevClose(quotes, dayUtc);
      final res = _computeSettle(p, prevClose, actual);
      if (res == null) continue;
      current = _writeBack(current, p, actual, res);
      changed = true;
    }
    if (!changed) return;
    await ref.read(calendarRepositoryProvider).put(current);
  }

  /// 找 [dayUtc] 之前最近一筆 quote 當作前一交易日收盤。
  double? _findPrevClose(Map<DateTime, double> quotes, DateTime dayUtc) {
    final earlier = quotes.keys.where((d) => d.isBefore(dayUtc)).toList()
      ..sort();
    if (earlier.isEmpty) return null;
    return quotes[earlier.last];
  }

  Future<double?> _fetchPrevClose(String symbol, DateTime day) async {
    final dayUtc = DateTime.utc(day.year, day.month, day.day);
    final r = await ref.read(stockApiClientProvider).quotes(
          symbol: symbol,
          from: dayUtc.subtract(const Duration(days: 7)),
          to: dayUtc.subtract(const Duration(days: 1)),
        );
    if (r is! Success<Map<DateTime, double>, AppError>) return null;
    if (r.value.isEmpty) return null;
    final sorted = r.value.keys.toList()..sort();
    return r.value[sorted.last];
  }

  /// 純函式：依 type 派發到 price_utils 的 settle helper。
  /// prevClose null 但 type 需要它（bullish/bearish/customPercent/upLimit/downLimit）→ 回 null。
  SettleResult? _computeSettle(
      Prediction p, double? prevClose, double actualClose) {
    switch (p.type) {
      case PredictionType.customPrice:
        final price = p.price;
        if (price == null) return null;
        return settleCustomPrice(
            predictedPrice: price, actualClose: actualClose);
      case PredictionType.customPercent:
        final pct = p.percent;
        if (pct == null || prevClose == null) return null;
        return settleCustomPercent(
            predictedPercent: pct,
            prevClose: prevClose,
            actualClose: actualClose);
      case PredictionType.bullish:
        if (prevClose == null) return null;
        return settleBullish(prevClose: prevClose, actualClose: actualClose);
      case PredictionType.bearish:
        if (prevClose == null) return null;
        return settleBearish(prevClose: prevClose, actualClose: actualClose);
      case PredictionType.upLimit:
        if (prevClose == null) return null;
        return settleUpLimit(prevClose: prevClose, actualClose: actualClose);
      case PredictionType.downLimit:
        if (prevClose == null) return null;
        return settleDownLimit(prevClose: prevClose, actualClose: actualClose);
      case PredictionType.flat:
        if (prevClose == null) return null;
        return settleFlat(prevClose: prevClose, actualClose: actualClose);
    }
  }

  CalendarDoc _writeBack(
    CalendarDoc doc,
    Prediction original,
    double actualClose,
    SettleResult res,
  ) {
    final updated = Prediction(
      date: original.date,
      type: original.type,
      price: original.price,
      percent: original.percent,
      note: original.note,
      settled: true,
      actualClose: actualClose,
      hitPercent: res.hitPercent,
    );
    final preds = doc.predictions
        .map((p) => identical(p, original) ||
                _sameDay(p.date, original.date)
            ? updated
            : p)
        .toList(growable: false);
    return doc.copyWith(
      predictions: preds,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Prediction? _findByDay(CalendarDoc doc, DateTime date) {
    for (final p in doc.predictions) {
      if (_sameDay(p.date, date)) return p;
    }
    return null;
  }

  static bool _sameDay(DateTime a, DateTime b) {
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }

  static DateTime _todayUtc() {
    final now = DateTime.now().toUtc();
    return DateTime.utc(now.year, now.month, now.day);
  }
}

/// Day → 結算狀態（marker 染色用）。
enum SettleStatus { unsettled, hit, miss }

SettleStatus settleStatusOf(Prediction p) {
  if (!p.settled) return SettleStatus.unsettled;
  return _judgeHit(p) ? SettleStatus.hit : SettleStatus.miss;
}

bool _judgeHit(Prediction p) {
  final actual = p.actualClose;
  if (actual == null) return false;
  final pct = p.hitPercent ?? 0.0;
  switch (p.type) {
    case PredictionType.customPrice:
      final price = p.price;
      if (price == null) return false;
      return (price * 100).round() == (actual * 100).round();
    case PredictionType.customPercent:
      final target = p.percent;
      if (target == null) return false;
      // hitPercent = actual - target；|.| < 0.05pp 算命中（小數第一位相等）
      return pct.abs() < 0.05;
    case PredictionType.bullish:
      return pct > 0; // 看多：actual 漲幅 > 0
    case PredictionType.bearish:
      return pct < 0;
    case PredictionType.upLimit:
      return pct >= 10.0 - 1e-9;
    case PredictionType.downLimit:
      return pct <= -10.0 + 1e-9;
    case PredictionType.flat:
      // settle 寫入時 cents 嚴格等於 → hitPercent 必為 0.0。
      return pct == 0.0;
  }
}
