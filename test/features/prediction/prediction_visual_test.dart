import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/app/theme/semantic_colors.dart';
import 'package:stock_calendar/data/models/prediction_type.dart';
import 'package:stock_calendar/features/prediction/view/prediction_visual.dart';

void main() {
  group('marketDirectionOf (軸一映射)', () {
    test('upLimit / bullish → up', () {
      expect(marketDirectionOf(PredictionType.upLimit), MarketDirection.up);
      expect(marketDirectionOf(PredictionType.bullish), MarketDirection.up);
    });
    test('downLimit / bearish → down', () {
      expect(marketDirectionOf(PredictionType.downLimit), MarketDirection.down);
      expect(marketDirectionOf(PredictionType.bearish), MarketDirection.down);
    });
    test('flat → flat', () {
      expect(marketDirectionOf(PredictionType.flat), MarketDirection.flat);
    });
    test('customPrice → neutral（自訂價無方向）', () {
      expect(marketDirectionOf(PredictionType.customPrice),
          MarketDirection.neutral);
    });

    group('customPercent 依正負（0 視為平盤灰）', () {
      test('percent > 0 → up', () {
        expect(marketDirectionOf(PredictionType.customPercent, percent: 3.5),
            MarketDirection.up);
      });
      test('percent < 0 → down', () {
        expect(marketDirectionOf(PredictionType.customPercent, percent: -2.0),
            MarketDirection.down);
      });
      test('percent == 0 → flat（user 拍板：0 視為平盤）', () {
        expect(marketDirectionOf(PredictionType.customPercent, percent: 0),
            MarketDirection.flat);
      });
      test('percent == null → neutral（尚未表態方向）', () {
        expect(marketDirectionOf(PredictionType.customPercent),
            MarketDirection.neutral);
      });
    });
  });

  group('PredictionVisual.of color 對齊 §2 軸一標準色', () {
    test('upLimit / bullish → 紅 #FF3B30', () {
      expect(PredictionVisual.of(PredictionType.upLimit).color,
          const Color(0xFFFF3B30));
      expect(PredictionVisual.of(PredictionType.bullish).color,
          const Color(0xFFFF3B30));
    });
    test('downLimit / bearish → 綠 #34C759', () {
      expect(PredictionVisual.of(PredictionType.downLimit).color,
          const Color(0xFF34C759));
      expect(PredictionVisual.of(PredictionType.bearish).color,
          const Color(0xFF34C759));
    });
    test('flat → 灰 #757575', () {
      expect(PredictionVisual.of(PredictionType.flat).color,
          const Color(0xFF757575));
    });
    test('customPrice / customPercent（靜態無值）→ 中性藍 #4D8EFF', () {
      expect(PredictionVisual.of(PredictionType.customPrice).color,
          const Color(0xFF4D8EFF));
      expect(PredictionVisual.of(PredictionType.customPercent).color,
          const Color(0xFF4D8EFF));
    });
  });
}
