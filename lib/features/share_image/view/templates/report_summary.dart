import '../../../../data/models/calendar_doc.dart';
import '../../../../data/models/prediction_type.dart';
import '../../../calendar/viewmodel/settlement_view_model.dart';

/// 單一 [PredictionType] 的分項統計。
class TypeStat {
  const TypeStat({
    required this.total,
    required this.settled,
    required this.hit,
  });

  final int total;
  final int settled;
  final int hit;
}

/// 月度報告聚合：吃 [CalendarDoc] 清單，算總數 / 已結算 / 命中 / 命中率 + 分項。
///
/// 命中率口徑：分母只算 settled（unsettled 排除分母）。settled == 0 → 0。
/// TODO(step20): 與完整報告頁統一命中率口徑（目前採 settled-only）。
///
/// 純函式、無 side effect、可單測；Step 20 完整報告頁可直接重用。
class ReportSummary {
  const ReportSummary({
    required this.total,
    required this.settled,
    required this.hit,
    required this.byType,
  });

  final int total;
  final int settled;
  final int hit;
  final Map<PredictionType, TypeStat> byType;

  int get miss => settled - hit;

  double get hitRate => settled == 0 ? 0 : hit / settled;

  int get hitRatePercent => (hitRate * 100).round();

  factory ReportSummary.from(List<CalendarDoc> docs) {
    var total = 0;
    var settled = 0;
    var hit = 0;
    // type → [total, settled, hit]
    final acc = <PredictionType, List<int>>{};

    for (final doc in docs) {
      for (final p in doc.predictions) {
        total++;
        final status = settleStatusOf(p);
        final isSettled = status != SettleStatus.unsettled;
        final isHit = status == SettleStatus.hit;
        if (isSettled) settled++;
        if (isHit) hit++;
        final a = acc.putIfAbsent(p.type, () => [0, 0, 0]);
        a[0]++;
        if (isSettled) a[1]++;
        if (isHit) a[2]++;
      }
    }

    final byType = <PredictionType, TypeStat>{
      for (final e in acc.entries)
        e.key: TypeStat(total: e.value[0], settled: e.value[1], hit: e.value[2]),
    };

    return ReportSummary(
      total: total,
      settled: settled,
      hit: hit,
      byType: byType,
    );
  }
}
