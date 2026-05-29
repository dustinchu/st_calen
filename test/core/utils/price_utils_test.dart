import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/core/utils/price_utils.dart';

void main() {
  group('changePercent', () {
    test('正常漲幅', () {
      expect(changePercent(100, 110), closeTo(10, 1e-9));
    });

    test('正常跌幅', () {
      expect(changePercent(100, 90), closeTo(-10, 1e-9));
    });

    test('prev 為 0 時回 null（除零保護）', () {
      expect(changePercent(0, 10), isNull);
    });

    test('prev 為負時回 null', () {
      expect(changePercent(-5, 10), isNull);
    });
  });

  group('台股漲跌停價（依 TWSE tick 反推）', () {
    test('prev=100 → 漲停 110.0 / 跌停 90.0（tick 0.5）', () {
      expect(twUpLimitPrice(100), 110.0);
      expect(twDownLimitPrice(100), 90.0);
    });

    test('prev=10 → 漲停 11.0 / 跌停 9.0（tick 0.05）', () {
      expect(twUpLimitPrice(10), 11.0);
      expect(twDownLimitPrice(10), 9.0);
    });

    test('prev=1000 → 漲停 1100 / 跌停 900（tick 5）', () {
      expect(twUpLimitPrice(1000), 1100.0);
      expect(twDownLimitPrice(1000), 900.0);
    });

    test('prev=9.5 → 漲停 10.45（tick 0.05，落在 10~50 區間）', () {
      expect(twUpLimitPrice(9.5), closeTo(10.45, 1e-9));
    });

    test('prev=53.6 → 漲停依 tick 0.1 floor 至 58.9', () {
      // 53.6 * 1.1 = 58.96, tick 0.1 (50~100) → floor 58.9
      expect(twUpLimitPrice(53.6), closeTo(58.9, 1e-9));
    });
  });

  group('isUpLimit / isDownLimit', () {
    test('台股：剛好漲停價為 true', () {
      expect(
        isUpLimit(prev: 100, current: 110, market: 'tw'),
        isTrue,
      );
    });

    test('台股：低於漲停為 false', () {
      expect(
        isUpLimit(prev: 100, current: 109.5, market: 'tw'),
        isFalse,
      );
    });

    test('台股：剛好跌停價為 true', () {
      expect(
        isDownLimit(prev: 100, current: 90, market: 'tw'),
        isTrue,
      );
    });

    test('美股一律 false（無漲跌停）', () {
      expect(
        isUpLimit(prev: 100, current: 200, market: 'us'),
        isFalse,
      );
      expect(
        isDownLimit(prev: 100, current: 1, market: 'us'),
        isFalse,
      );
    });

    test('prev <= 0 時 false（除零保護）', () {
      expect(isUpLimit(prev: 0, current: 10, market: 'tw'), isFalse);
      expect(isDownLimit(prev: -1, current: 10, market: 'tw'), isFalse);
    });
  });

  group('settle helpers (Step 16)', () {
    test('customPrice 嚴格等於命中', () {
      final r = settleCustomPrice(predictedPrice: 1000, actualClose: 1000);
      expect(r.hit, isTrue);
      expect(r.hitPercent, closeTo(0, 1e-9));
    });

    test('customPrice 差 0.5 未命中', () {
      final r = settleCustomPrice(predictedPrice: 1000, actualClose: 1000.5);
      expect(r.hit, isFalse);
    });

    test('customPercent 小數第一位相等命中', () {
      // 預測 +3%，prev 100, actual 103.02 → actual% ≈ 3.02 → diff 0.02 < 0.05
      final r = settleCustomPercent(
          predictedPercent: 3, prevClose: 100, actualClose: 103.02);
      expect(r.hit, isTrue);
    });

    test('customPercent 差 0.1pp 未命中', () {
      final r = settleCustomPercent(
          predictedPercent: 3, prevClose: 100, actualClose: 103.1);
      expect(r.hit, isFalse);
    });

    test('bullish 收紅命中、平盤未命中', () {
      expect(settleBullish(prevClose: 100, actualClose: 101).hit, isTrue);
      expect(settleBullish(prevClose: 100, actualClose: 100).hit, isFalse);
      expect(settleBullish(prevClose: 100, actualClose: 99).hit, isFalse);
    });

    test('bearish 收綠命中、平盤未命中', () {
      expect(settleBearish(prevClose: 100, actualClose: 99).hit, isTrue);
      expect(settleBearish(prevClose: 100, actualClose: 100).hit, isFalse);
    });

    test('upLimit ≥ +10% 命中', () {
      expect(settleUpLimit(prevClose: 100, actualClose: 110).hit, isTrue);
      expect(settleUpLimit(prevClose: 100, actualClose: 109.99).hit, isFalse);
    });

    test('downLimit ≤ -10% 命中', () {
      expect(settleDownLimit(prevClose: 100, actualClose: 90).hit, isTrue);
      expect(settleDownLimit(prevClose: 100, actualClose: 90.01).hit, isFalse);
    });

    test('flat 嚴格等於命中', () {
      final r = settleFlat(prevClose: 100, actualClose: 100);
      expect(r.hit, isTrue);
      expect(r.hitPercent, closeTo(0, 1e-9));
    });

    test('flat 差 1 cent 未命中', () {
      final r = settleFlat(prevClose: 100, actualClose: 100.01);
      expect(r.hit, isFalse);
    });
  });
}
