import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/data/models/calendar_doc.dart';
import 'package:stock_calendar/data/models/prediction.dart';
import 'package:stock_calendar/data/models/prediction_type.dart';
import 'package:stock_calendar/features/share_image/view/templates/report_summary.dart';

/// bullish 命中判定：settled 且 hitPercent > 0 → hit。
Prediction _hit(int day) => Prediction(
      date: DateTime.utc(2026, 6, day),
      type: PredictionType.bullish,
      settled: true,
      actualClose: 110,
      hitPercent: 1.5,
    );

/// bullish 未命中：settled 且 hitPercent <= 0 → miss。
Prediction _miss(int day) => Prediction(
      date: DateTime.utc(2026, 6, day),
      type: PredictionType.bullish,
      settled: true,
      actualClose: 90,
      hitPercent: -1.5,
    );

/// 未結算。
Prediction _unsettled(int day) => Prediction(
      date: DateTime.utc(2026, 6, day),
      type: PredictionType.bullish,
    );

CalendarDoc _doc(List<Prediction> predictions) {
  final t = DateTime.utc(2026, 6, 1);
  return CalendarDoc(
    id: 'c1',
    userId: 'u1',
    symbol: '2330.TW',
    year: 2026,
    month: 6,
    title: 't',
    themeId: 'default',
    predictions: predictions,
    createdAt: t,
    updatedAt: t,
  );
}

void main() {
  group('ReportSummary.from', () {
    test('無 prediction → 全 0、命中率 0%', () {
      final s = ReportSummary.from([_doc(const [])]);
      expect(s.total, 0);
      expect(s.settled, 0);
      expect(s.hit, 0);
      expect(s.miss, 0);
      expect(s.hitRate, 0);
      expect(s.hitRatePercent, 0);
      expect(s.byType, isEmpty);
    });

    test('全 hit → 命中率 100%', () {
      final s = ReportSummary.from([
        _doc([_hit(1), _hit(2), _hit(3)]),
      ]);
      expect(s.total, 3);
      expect(s.settled, 3);
      expect(s.hit, 3);
      expect(s.miss, 0);
      expect(s.hitRatePercent, 100);
    });

    test('全 miss → 命中率 0%（分母仍為 settled 數）', () {
      final s = ReportSummary.from([
        _doc([_miss(1), _miss(2)]),
      ]);
      expect(s.total, 2);
      expect(s.settled, 2);
      expect(s.hit, 0);
      expect(s.miss, 2);
      expect(s.hitRatePercent, 0);
    });

    test('混合：unsettled 排除分母（口徑 A）', () {
      // 2 hit + 1 miss + 1 unsettled → settled=3, hit=2 → 2/3 ≈ 67%
      final s = ReportSummary.from([
        _doc([_hit(1), _hit(2), _miss(3), _unsettled(4)]),
      ]);
      expect(s.total, 4);
      expect(s.settled, 3);
      expect(s.hit, 2);
      expect(s.miss, 1);
      expect(s.hitRate, closeTo(2 / 3, 1e-9));
      expect(s.hitRatePercent, 67);
    });

    test('byType 分項統計 + 跨多 doc 累加', () {
      final s = ReportSummary.from([
        _doc([_hit(1), _miss(2)]),
        _doc([_unsettled(3)]),
      ]);
      expect(s.total, 3);
      final bullish = s.byType[PredictionType.bullish];
      expect(bullish, isNotNull);
      expect(bullish!.total, 3);
      expect(bullish.settled, 2);
      expect(bullish.hit, 1);
    });
  });
}
