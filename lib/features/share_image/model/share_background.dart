import 'package:flutter/material.dart';

/// 單日卡片可選背景：純 Flutter 漸層 preset（零 asset、零版權、零 bundle 膨脹）。
/// [none] = 不套背景，改用主題底色。
enum ShareBackground {
  none('無背景'),
  sunrise('日出'),
  ocean('海洋'),
  forest('森林'),
  dusk('暮色');

  const ShareBackground(this.label);

  final String label;

  /// 漸層；[none] 回 null（caller 改用主題底色）。
  LinearGradient? get gradient {
    switch (this) {
      case ShareBackground.none:
        return null;
      case ShareBackground.sunrise:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9A56), Color(0xFFFF6A88)],
        );
      case ShareBackground.ocean:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
        );
      case ShareBackground.forest:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
        );
      case ShareBackground.dusk:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF654EA3), Color(0xFFEAAFC8)],
        );
    }
  }

  /// 是否深彩底（決定前景文字用白字）。none 以外皆為深彩漸層。
  bool get isDark => this != ShareBackground.none;
}
