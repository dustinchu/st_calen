import '../../../data/models/calendar_doc.dart';
import '../../share_image/view/templates/report_summary.dart';

/// 準度報告的時間範圍 Tab。三個 Tab 皆「跨所有股票」聚合（最佳股票才有意義）。
enum ReportTab {
  thisMonth('本月'),
  last3Months('近 3 月'),
  all('全部');

  const ReportTab(this.label);

  final String label;
}

/// 單一年月的命中率（折線圖一個點）。命中率口徑沿用 settled-only。
class MonthlyHitRate {
  const MonthlyHitRate({
    required this.year,
    required this.month,
    required this.settled,
    required this.hit,
  });

  final int year;
  final int month;
  final int settled;
  final int hit;

  double get hitRate => settled == 0 ? 0 : hit / settled;

  int get hitRatePercent => (hitRate * 100).round();
}

/// 單一股票的命中率（最佳股票用）。
class StockHitRate {
  const StockHitRate({
    required this.symbol,
    required this.settled,
    required this.hit,
  });

  final String symbol;
  final int settled;
  final int hit;

  double get hitRate => settled == 0 ? 0 : hit / settled;

  int get hitRatePercent => (hitRate * 100).round();
}

/// 準度報告純函式聚合：吃「本地所有 [CalendarDoc]」+ Tab + now，產出
/// 過濾後 docs（CTA 重用）/ 整體 summary / 每月命中率序列 / 最佳股票。
///
/// 命中率口徑：全程透過 [ReportSummary.from]（settled-only）聚合，與 Step 19
/// 報告卡口徑結構性一致——unsettled 不入分母，settled == 0 → 命中率 0。
class AccuracyReport {
  const AccuracyReport({
    required this.tab,
    required this.docs,
    required this.summary,
    required this.monthlySeries,
    required this.bestStock,
  });

  /// 最佳股票最小樣本門檻：settled 須 >= 此值，避免「1 筆 100%」奪冠。
  static const int kBestStockMinSettled = 3;

  final ReportTab tab;

  /// 該 Tab 範圍過濾後的 docs（CTA 分享報告卡直接重用）。
  final List<CalendarDoc> docs;

  final ReportSummary summary;

  /// 每月命中率，依年月升序。無預測的月份不入序列；有預測但全未結算 → 0%。
  final List<MonthlyHitRate> monthlySeries;

  /// 命中率最高且達門檻的股票；無達門檻者 → null。
  final StockHitRate? bestStock;

  factory AccuracyReport.from(
    List<CalendarDoc> allDocs,
    ReportTab tab,
    DateTime now, {
    int minSettled = kBestStockMinSettled,
  }) {
    final filtered = _filterByTab(allDocs, tab, now);
    return AccuracyReport(
      tab: tab,
      docs: filtered,
      summary: ReportSummary.from(filtered),
      monthlySeries: _monthlySeries(filtered),
      bestStock: _bestStock(filtered, minSettled),
    );
  }

  // ─── pure helpers ──────────────────────────────────────────────────────────

  /// 月份序號：year * 12 + (month - 1)，單調遞增、可直接排序。
  static int _monthIndex(int year, int month) => year * 12 + (month - 1);

  static List<CalendarDoc> _filterByTab(
    List<CalendarDoc> docs,
    ReportTab tab,
    DateTime now,
  ) {
    switch (tab) {
      case ReportTab.all:
        return List.unmodifiable(docs);
      case ReportTab.thisMonth:
        return docs
            .where((d) => d.year == now.year && d.month == now.month)
            .toList(growable: false);
      case ReportTab.last3Months:
        final nowIdx = _monthIndex(now.year, now.month);
        return docs.where((d) {
          final idx = _monthIndex(d.year, d.month);
          return idx <= nowIdx && idx >= nowIdx - 2;
        }).toList(growable: false);
    }
  }

  static List<MonthlyHitRate> _monthlySeries(List<CalendarDoc> docs) {
    // 跨股票同年月合併。
    final byMonth = <int, List<CalendarDoc>>{};
    for (final d in docs) {
      byMonth.putIfAbsent(_monthIndex(d.year, d.month), () => []).add(d);
    }
    final keys = byMonth.keys.toList()..sort();
    final out = <MonthlyHitRate>[];
    for (final k in keys) {
      final s = ReportSummary.from(byMonth[k]!);
      if (s.total == 0) continue; // 無預測月跳過
      out.add(MonthlyHitRate(
        year: k ~/ 12,
        month: k % 12 + 1,
        settled: s.settled,
        hit: s.hit,
      ));
    }
    return out;
  }

  static StockHitRate? _bestStock(List<CalendarDoc> docs, int minSettled) {
    final bySymbol = <String, List<CalendarDoc>>{};
    for (final d in docs) {
      bySymbol.putIfAbsent(d.symbol, () => []).add(d);
    }
    StockHitRate? best;
    for (final entry in bySymbol.entries) {
      final s = ReportSummary.from(entry.value);
      if (s.settled < minSettled) continue; // 未達樣本門檻
      final candidate =
          StockHitRate(symbol: entry.key, settled: s.settled, hit: s.hit);
      if (best == null ||
          candidate.hitRate > best.hitRate ||
          (candidate.hitRate == best.hitRate && candidate.hit > best.hit)) {
        best = candidate;
      }
    }
    return best;
  }
}
