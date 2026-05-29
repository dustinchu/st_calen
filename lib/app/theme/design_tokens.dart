/// Design tokens — 直接落地自 `stitch_stock_market_calendar_v2/DESIGN.md`。
///
/// 這層只放「常數 + 純映射」，不含 ThemeData 組裝（在 [app_theme.dart]）。
/// U1 只建立深色基底所需的 token；三軸語意色（漲跌/命中）留 U2 的 `SemanticColors`。
library;

import 'package:flutter/widgets.dart';

/// DESIGN.md `colors:` 全套 M3 tonal token（深色 OLED 基底）。
///
/// surface 階層完整搬入，供 app_theme 覆寫 `ColorScheme` 用——
/// `ColorScheme.fromSeed` 自動衍生的深色不夠「OLED 黑」，故採 DESIGN.md 具體值。
abstract final class AppColors {
  // Surface 階層
  static const Color surface = Color(0xFF051424);
  static const Color surfaceDim = Color(0xFF051424);
  static const Color surfaceBright = Color(0xFF2C3A4C);
  static const Color surfaceContainerLowest = Color(0xFF010F1F);
  static const Color surfaceContainerLow = Color(0xFF0D1C2D);
  static const Color surfaceContainer = Color(0xFF122131);
  static const Color surfaceContainerHigh = Color(0xFF1C2B3C);
  static const Color surfaceContainerHighest = Color(0xFF273647);
  static const Color surfaceVariant = Color(0xFF273647);
  static const Color onSurface = Color(0xFFD4E4FA);
  static const Color onSurfaceVariant = Color(0xFFC2C6D6);
  static const Color inverseSurface = Color(0xFFD4E4FA);
  static const Color inverseOnSurface = Color(0xFF233143);
  static const Color outline = Color(0xFF8C909F);
  static const Color outlineVariant = Color(0xFF424754);
  static const Color surfaceTint = Color(0xFFADC6FF);

  // Primary
  static const Color primary = Color(0xFFADC6FF);
  static const Color onPrimary = Color(0xFF002E6A);
  static const Color primaryContainer = Color(0xFF4D8EFF);
  static const Color onPrimaryContainer = Color(0xFF00285D);
  static const Color inversePrimary = Color(0xFF005AC2);

  // Secondary
  static const Color secondary = Color(0xFFFFB4AA);
  static const Color onSecondary = Color(0xFF690003);
  static const Color secondaryContainer = Color(0xFFC5020B);
  static const Color onSecondaryContainer = Color(0xFFFFD2CC);

  // Tertiary
  static const Color tertiary = Color(0xFF53E16F);
  static const Color onTertiary = Color(0xFF003911);
  static const Color tertiaryContainer = Color(0xFF00A741);
  static const Color onTertiaryContainer = Color(0xFF00320E);

  // Error
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // Background
  static const Color background = Color(0xFF051424);
  static const Color onBackground = Color(0xFFD4E4FA);
}

/// DESIGN.md `rounded:`（rem → logical px，1rem = 16）。
abstract final class AppRadii {
  static const double sm = 4; // 0.25rem
  static const double base = 8; // 0.5rem (DEFAULT)
  static const double md = 12; // 0.75rem
  static const double lg = 16; // 1rem — 主卡片/按鈕/sheet
  static const double xl = 24; // 1.5rem — chips pill 起跳
  static const double full = 9999;
}

/// DESIGN.md `spacing:`（4px base grid）。
abstract final class AppSpacing {
  static const double unit = 4;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double gutter = 12;
  static const double marginMobile = 16;
}

/// 字體 family（pubspec 宣告的名稱）。
abstract final class AppFontFamily {
  /// 主介面繁中字體。
  static const String notoSans = 'NotoSansTC';

  /// 數字 / 股票代號字體（tabular，DESIGN.md data-heavy）。
  static const String inter = 'Inter';
}

/// DESIGN.md `typography:` 的字級 token。
enum AppTextToken {
  displayBold,
  headlineLg,
  headlineMd,
  bodyLg,
  bodySm,
  labelCaps,
  dataHeavy,
  headlineLgMobile,
}

/// 純函式：token → [TextStyle]。
///
/// lineHeight(px) → Flutter `height` = lineHeight / fontSize；
/// letterSpacing(em) → logical px = em × fontSize。
/// 抽成純函式以便單測（DoD：能抽就抽並測）。
TextStyle appTextStyle(AppTextToken token) {
  switch (token) {
    case AppTextToken.displayBold:
      return const TextStyle(
        fontFamily: AppFontFamily.notoSans,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        letterSpacing: -0.02 * 32,
      );
    case AppTextToken.headlineLg:
      return const TextStyle(
        fontFamily: AppFontFamily.notoSans,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
      );
    case AppTextToken.headlineMd:
      return const TextStyle(
        fontFamily: AppFontFamily.notoSans,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
      );
    case AppTextToken.bodyLg:
      return const TextStyle(
        fontFamily: AppFontFamily.notoSans,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      );
    case AppTextToken.bodySm:
      return const TextStyle(
        fontFamily: AppFontFamily.notoSans,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
      );
    case AppTextToken.labelCaps:
      return const TextStyle(
        fontFamily: AppFontFamily.inter,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 16 / 12,
        letterSpacing: 0.05 * 12,
      );
    case AppTextToken.dataHeavy:
      return const TextStyle(
        fontFamily: AppFontFamily.inter,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 22 / 18,
      );
    case AppTextToken.headlineLgMobile:
      return const TextStyle(
        fontFamily: AppFontFamily.notoSans,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 28 / 22,
      );
  }
}
