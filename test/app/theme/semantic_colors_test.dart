import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/app/theme/semantic_colors.dart';

void main() {
  group('SemanticColors.directionColor (軸一：市場方向)', () {
    const sem = SemanticColors.dark;

    test('up → 紅 #FF3B30', () {
      expect(sem.directionColor(MarketDirection.up), const Color(0xFFFF3B30));
    });
    test('down → 綠 #34C759', () {
      expect(sem.directionColor(MarketDirection.down), const Color(0xFF34C759));
    });
    test('flat → 灰 #757575', () {
      expect(sem.directionColor(MarketDirection.flat), const Color(0xFF757575));
    });
    test('neutral → 藍 #4D8EFF', () {
      expect(
          sem.directionColor(MarketDirection.neutral), const Color(0xFF4D8EFF));
    });
  });

  group('SemanticColors 軸二：命中狀態色', () {
    const sem = SemanticColors.dark;

    test('hit 命中 → 金 #FFB300', () {
      expect(sem.hit, const Color(0xFFFFB300));
    });
    test('miss 未命中 → 灰 #8C909F（不用紅）', () {
      expect(sem.miss, const Color(0xFF8C909F));
    });
    test('unsettled 未結算 → 淡灰 #8C909F', () {
      expect(sem.unsettled, const Color(0xFF8C909F));
    });
  });

  group('ThemeExtension 契約', () {
    test('lerp(t=0) 回自身值、lerp(other) 不 throw', () {
      const a = SemanticColors.dark;
      final same = a.lerp(a, 0);
      expect(same.up, a.up);
    });
    test('copyWith 覆寫單欄', () {
      const a = SemanticColors.dark;
      final b = a.copyWith(hit: const Color(0xFF000000));
      expect(b.hit, const Color(0xFF000000));
      expect(b.up, a.up);
    });
  });
}
