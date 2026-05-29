import 'package:flutter/material.dart';

import 'design_tokens.dart';

class AppTheme {
  const AppTheme._();

  static const Color _defaultSeed = Color(0xFF1E88E5);

  /// 深色 OLED 基底（U1 暫定預設）。surface 階層覆寫為 DESIGN.md 具體值，
  /// 非 `ColorScheme.fromSeed` 自動衍生（衍生值不夠「OLED 黑」）。
  static ThemeData dark() => _build(_darkColorScheme());

  /// 既有淺色入口（U3 會接回 5 套主題；U1 先保留簽名不破壞呼叫點）。
  static ThemeData light() => fromSeed(_defaultSeed, Brightness.light);

  /// 由 seed 衍生（U3 主題切換沿用）。深色基底另走 [dark]。
  static ThemeData fromSeed(Color seed, Brightness brightness) => _build(
        ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
      );

  static ColorScheme _darkColorScheme() => const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        inversePrimary: AppColors.inversePrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceDim: AppColors.surfaceDim,
        surfaceBright: AppColors.surfaceBright,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        surfaceTint: AppColors.surfaceTint,
      );

  static ThemeData _build(ColorScheme scheme) => ThemeData(
        useMaterial3: true,
        brightness: scheme.brightness,
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surface,
        fontFamily: AppFontFamily.notoSans,
        textTheme: _textTheme(scheme.onSurface),
      );

  /// 套 DESIGN.md typography（NotoSansTC 主、Inter 走數字）。
  /// 顏色用 [onSurface]，由各 ColorScheme 決定深/淺。
  static TextTheme _textTheme(Color onSurface) {
    TextStyle t(AppTextToken token) =>
        appTextStyle(token).copyWith(color: onSurface);
    return TextTheme(
      displayLarge: t(AppTextToken.displayBold),
      displayMedium: t(AppTextToken.displayBold),
      displaySmall: t(AppTextToken.headlineLg),
      headlineLarge: t(AppTextToken.headlineLg),
      headlineMedium: t(AppTextToken.headlineLgMobile),
      headlineSmall: t(AppTextToken.headlineMd),
      titleLarge: t(AppTextToken.headlineMd),
      titleMedium: t(AppTextToken.bodyLg),
      titleSmall: t(AppTextToken.bodySm),
      bodyLarge: t(AppTextToken.bodyLg),
      bodyMedium: t(AppTextToken.bodySm),
      bodySmall: t(AppTextToken.bodySm),
      labelLarge: t(AppTextToken.labelCaps),
      labelMedium: t(AppTextToken.labelCaps),
      labelSmall: t(AppTextToken.labelCaps),
    ).apply(displayColor: onSurface, bodyColor: onSurface);
  }
}
