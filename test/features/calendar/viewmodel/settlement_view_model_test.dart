import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/data/models/prediction.dart';
import 'package:stock_calendar/data/models/prediction_type.dart';
import 'package:stock_calendar/features/calendar/viewmodel/settlement_view_model.dart';

Prediction _p({
  required PredictionType type,
  required bool settled,
  double? price,
  double? percent,
  double? actualClose,
  double? hitPercent,
}) =>
    Prediction(
      date: DateTime.utc(2026, 5, 1),
      type: type,
      price: price,
      percent: percent,
      settled: settled,
      actualClose: actualClose,
      hitPercent: hitPercent,
    );

void main() {
  group('settleStatusOf', () {
    test('未 settled → unsettled', () {
      expect(
        settleStatusOf(_p(type: PredictionType.bullish, settled: false)),
        SettleStatus.unsettled,
      );
    });

    test('customPrice 嚴格等於 → hit', () {
      expect(
        settleStatusOf(_p(
          type: PredictionType.customPrice,
          settled: true,
          price: 1000,
          actualClose: 1000,
          hitPercent: 0,
        )),
        SettleStatus.hit,
      );
    });

    test('customPrice 差 0.5 → miss', () {
      expect(
        settleStatusOf(_p(
          type: PredictionType.customPrice,
          settled: true,
          price: 1000,
          actualClose: 1000.5,
          hitPercent: 0.05,
        )),
        SettleStatus.miss,
      );
    });

    test('customPercent 小數第一位相等 → hit', () {
      expect(
        settleStatusOf(_p(
          type: PredictionType.customPercent,
          settled: true,
          percent: 3,
          actualClose: 103.02,
          hitPercent: 0.02,
        )),
        SettleStatus.hit,
      );
    });

    test('bullish 漲 → hit；平盤 → miss', () {
      expect(
        settleStatusOf(_p(
          type: PredictionType.bullish,
          settled: true,
          actualClose: 101,
          hitPercent: 1.0,
        )),
        SettleStatus.hit,
      );
      expect(
        settleStatusOf(_p(
          type: PredictionType.bullish,
          settled: true,
          actualClose: 100,
          hitPercent: 0.0,
        )),
        SettleStatus.miss,
      );
    });

    test('bearish 跌 → hit', () {
      expect(
        settleStatusOf(_p(
          type: PredictionType.bearish,
          settled: true,
          actualClose: 99,
          hitPercent: -1.0,
        )),
        SettleStatus.hit,
      );
    });

    test('upLimit ≥ +10% → hit', () {
      expect(
        settleStatusOf(_p(
          type: PredictionType.upLimit,
          settled: true,
          actualClose: 110,
          hitPercent: 10.0,
        )),
        SettleStatus.hit,
      );
      expect(
        settleStatusOf(_p(
          type: PredictionType.upLimit,
          settled: true,
          actualClose: 109,
          hitPercent: 9.0,
        )),
        SettleStatus.miss,
      );
    });

    test('downLimit ≤ -10% → hit', () {
      expect(
        settleStatusOf(_p(
          type: PredictionType.downLimit,
          settled: true,
          actualClose: 90,
          hitPercent: -10.0,
        )),
        SettleStatus.hit,
      );
    });

    test('flat hitPercent 0 → hit', () {
      expect(
        settleStatusOf(_p(
          type: PredictionType.flat,
          settled: true,
          actualClose: 100,
          hitPercent: 0.0,
        )),
        SettleStatus.hit,
      );
    });

    test('flat hitPercent 非 0 → miss', () {
      expect(
        settleStatusOf(_p(
          type: PredictionType.flat,
          settled: true,
          actualClose: 100.5,
          hitPercent: 0.5,
        )),
        SettleStatus.miss,
      );
    });
  });
}
