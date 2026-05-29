import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/data/models/calendar_doc.dart';
import 'package:stock_calendar/data/models/prediction.dart';
import 'package:stock_calendar/data/models/prediction_type.dart';
import 'package:stock_calendar/features/accuracy_report/viewmodel/accuracy_report.dart';

// aggregation 不依賴 prediction.date（只看 doc.year/month 分組與 settleStatusOf
// 的結算欄位），固定一個任意日期即可。
final _anyDate = DateTime.utc(2026, 1, 1);

/// bullish 命中（settled, hitPercent > 0）。
Prediction _hit() => Prediction(
      date: _anyDate,
      type: PredictionType.bullish,
      settled: true,
      actualClose: 110,
      hitPercent: 1.5,
    );

/// bullish 未命中（settled, hitPercent <= 0）。
Prediction _miss() => Prediction(
      date: _anyDate,
      type: PredictionType.bullish,
      settled: true,
      actualClose: 90,
      hitPercent: -1.5,
    );

/// 未結算。
Prediction _unsettled() => Prediction(
      date: _anyDate,
      type: PredictionType.bullish,
    );

CalendarDoc _doc({
  required String symbol,
  required int year,
  required int month,
  required List<Prediction> predictions,
}) {
  final t = DateTime.utc(2026, 1, 1);
  return CalendarDoc(
    id: '$symbol-$year-$month',
    userId: 'u1',
    symbol: symbol,
    year: year,
    month: month,
    title: 't',
    themeId: 'default',
    predictions: predictions,
    createdAt: t,
    updatedAt: t,
  );
}

void main() {
  // 固定「現在」= 2026-06-15，避免測試隨真實時間飄移。
  final now = DateTime.utc(2026, 6, 15);

  group('AccuracyReport.from — Tab 範圍過濾', () {
    final docs = [
      _doc(symbol: 'A', year: 2026, month: 4, predictions: [_hit()]),
      _doc(symbol: 'A', year: 2026, month: 5, predictions: [_hit()]),
      _doc(symbol: 'A', year: 2026, month: 6, predictions: [_hit()]),
      _doc(symbol: 'A', year: 2026, month: 3, predictions: [_hit()]),
      _doc(symbol: 'A', year: 2026, month: 7, predictions: [_hit()]),
    ];

    test('本月只含當月 doc', () {
      final r = AccuracyReport.from(docs, ReportTab.thisMonth, now);
      expect(r.docs.length, 1);
      expect(r.docs.single.month, 6);
    });

    test('近 3 月含本月與前兩個月，排除更早與未來', () {
      final r = AccuracyReport.from(docs, ReportTab.last3Months, now);
      final months = r.docs.map((d) => d.month).toList()..sort();
      expect(months, [4, 5, 6]);
    });

    test('全部含所有月份', () {
      final r = AccuracyReport.from(docs, ReportTab.all, now);
      expect(r.docs.length, 5);
    });
  });

  group('AccuracyReport.from — 命中率口徑與 ReportSummary 一致（settled-only）', () {
    test('2 hit + 1 miss + 1 unsettled → settled=3, hit=2, 67%', () {
      final docs = [
        _doc(
          symbol: 'A',
          year: 2026,
          month: 6,
          predictions: [_hit(), _hit(), _miss(), _unsettled()],
        ),
      ];
      final r = AccuracyReport.from(docs, ReportTab.all, now);
      expect(r.summary.total, 4);
      expect(r.summary.settled, 3);
      expect(r.summary.hit, 2);
      expect(r.summary.hitRatePercent, 67);
    });
  });

  group('AccuracyReport.from — 每月命中率序列', () {
    test('依年月升序排列，跨股票同月合併', () {
      final docs = [
        _doc(symbol: 'B', year: 2026, month: 6, predictions: [_miss()]),
        _doc(symbol: 'A', year: 2026, month: 5, predictions: [_hit()]),
        _doc(symbol: 'A', year: 2026, month: 6, predictions: [_hit()]),
      ];
      final r = AccuracyReport.from(docs, ReportTab.all, now);
      expect(r.monthlySeries.map((m) => '${m.year}-${m.month}').toList(),
          ['2026-5', '2026-6']);
      // 6 月：A hit + B miss → settled 2, hit 1 → 50%
      final june = r.monthlySeries.last;
      expect(june.settled, 2);
      expect(june.hit, 1);
      expect(june.hitRatePercent, 50);
    });

    test('有預測但全未結算的月份命中率 0%（仍入序列）', () {
      final docs = [
        _doc(symbol: 'A', year: 2026, month: 6, predictions: [_unsettled()]),
      ];
      final r = AccuracyReport.from(docs, ReportTab.all, now);
      expect(r.monthlySeries.length, 1);
      expect(r.monthlySeries.single.settled, 0);
      expect(r.monthlySeries.single.hitRatePercent, 0);
    });

    test('無預測的 doc 不進序列', () {
      final docs = [
        _doc(symbol: 'A', year: 2026, month: 6, predictions: const []),
      ];
      final r = AccuracyReport.from(docs, ReportTab.all, now);
      expect(r.monthlySeries, isEmpty);
    });
  });

  group('AccuracyReport.from — 最佳股票（min settled 門檻）', () {
    test('低於門檻（settled < 3）不參選，避免單筆 100% 奪冠', () {
      final docs = [
        // C：1 筆 hit → 100% 但 settled=1 < 3，不應奪冠
        _doc(symbol: 'C', year: 2026, month: 6, predictions: [_hit()]),
        // A：3 settled、2 hit → 67%，達門檻
        _doc(
          symbol: 'A',
          year: 2026,
          month: 6,
          predictions: [_hit(), _hit(), _miss()],
        ),
      ];
      final r = AccuracyReport.from(docs, ReportTab.all, now);
      expect(r.bestStock, isNotNull);
      expect(r.bestStock!.symbol, 'A');
      expect(r.bestStock!.hitRatePercent, 67);
    });

    test('全部低於門檻 → null', () {
      final docs = [
        _doc(symbol: 'C', year: 2026, month: 6, predictions: [_hit(), _hit()]),
      ];
      final r = AccuracyReport.from(docs, ReportTab.all, now);
      expect(r.bestStock, isNull);
    });

    test('命中率平手取命中數多者', () {
      final docs = [
        // A：3 settled、3 hit → 100%
        _doc(
          symbol: 'A',
          year: 2026,
          month: 6,
          predictions: [_hit(), _hit(), _hit()],
        ),
        // B：5 settled、5 hit → 100%，平手但命中數多 → 勝
        _doc(
          symbol: 'B',
          year: 2026,
          month: 6,
          predictions: [_hit(), _hit(), _hit(), _hit(), _hit()],
        ),
      ];
      final r = AccuracyReport.from(docs, ReportTab.all, now);
      expect(r.bestStock!.symbol, 'B');
      expect(r.bestStock!.hit, 5);
    });

    test('無資料 → null', () {
      final r = AccuracyReport.from(const [], ReportTab.all, now);
      expect(r.bestStock, isNull);
      expect(r.summary.total, 0);
      expect(r.monthlySeries, isEmpty);
    });
  });
}
