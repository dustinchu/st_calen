import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/app/theme/design_tokens.dart';

void main() {
  group('appTextStyle', () {
    test('displayBold maps DESIGN.md display-bold (Noto 32/700, h=1.25, ls=-0.64)',
        () {
      final s = appTextStyle(AppTextToken.displayBold);
      expect(s.fontFamily, AppFontFamily.notoSans);
      expect(s.fontSize, 32);
      expect(s.fontWeight, FontWeight.w700);
      expect(s.height, 40 / 32);
      expect(s.letterSpacing, closeTo(-0.64, 1e-9));
    });

    test('dataHeavy uses Inter (數字字體) 18/700', () {
      final s = appTextStyle(AppTextToken.dataHeavy);
      expect(s.fontFamily, AppFontFamily.inter);
      expect(s.fontSize, 18);
      expect(s.fontWeight, FontWeight.w700);
      expect(s.height, 22 / 18);
    });

    test('labelCaps uses Inter 12/700 with 0.05em letterSpacing', () {
      final s = appTextStyle(AppTextToken.labelCaps);
      expect(s.fontFamily, AppFontFamily.inter);
      expect(s.fontSize, 12);
      expect(s.letterSpacing, closeTo(0.6, 1e-9));
    });

    test('every token resolves to a non-null TextStyle with a font family', () {
      for (final token in AppTextToken.values) {
        final s = appTextStyle(token);
        expect(s.fontFamily, isNotNull, reason: '$token missing fontFamily');
        expect(s.fontSize, isNotNull, reason: '$token missing fontSize');
      }
    });

    test('only the two declared families are used', () {
      final families = AppTextToken.values
          .map((t) => appTextStyle(t).fontFamily)
          .toSet();
      expect(families, {AppFontFamily.notoSans, AppFontFamily.inter});
    });
  });

  group('AppColors (OLED 深色基底)', () {
    test('surface 階層由暗到亮遞增（lowest 最暗）', () {
      expect(AppColors.surfaceContainerLowest, const Color(0xFF010F1F));
      expect(AppColors.surface, const Color(0xFF051424));
      expect(AppColors.surfaceContainerHighest, const Color(0xFF273647));
    });
  });

  group('AppRadii', () {
    test('lg = 16 (主卡片/sheet)；full = pill', () {
      expect(AppRadii.lg, 16);
      expect(AppRadii.full, 9999);
    });
  });
}
