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
}
