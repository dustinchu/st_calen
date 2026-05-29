import 'package:flutter/material.dart';

/// 三軸分離的語意色（§2 色彩語意系統）。
///
/// 軸一「市場方向」與軸二「命中狀態」永不撞色——畫面一律讀此 extension，
/// 不寫死。U2 先提供 [dark] 一套；U3 各主題各自提供。
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.up,
    required this.down,
    required this.flat,
    required this.neutral,
    required this.hit,
    required this.miss,
    required this.unsettled,
  });

  /// 深色 OLED 基底語意色（DESIGN.md / §2）。
  static const SemanticColors dark = SemanticColors(
    // 軸一：市場方向（台股慣例 紅漲綠跌）
    up: Color(0xFFFF3B30),
    down: Color(0xFF34C759),
    flat: Color(0xFF757575),
    neutral: Color(0xFF4D8EFF),
    // 軸二：命中狀態（命中金、miss/unsettled 灰，皆不用紅綠）
    hit: Color(0xFFFFB300),
    miss: Color(0xFF8C909F),
    unsettled: Color(0xFF8C909F),
  );

  /// 軸一：市場方向。
  final Color up;
  final Color down;
  final Color flat;
  final Color neutral;

  /// 軸二：命中狀態。
  final Color hit;
  final Color miss;
  final Color unsettled;

  /// 方向 → 軸一色。畫面用 [marketDirectionOf] 算出方向後查此表。
  Color directionColor(MarketDirection direction) {
    switch (direction) {
      case MarketDirection.up:
        return up;
      case MarketDirection.down:
        return down;
      case MarketDirection.flat:
        return flat;
      case MarketDirection.neutral:
        return neutral;
    }
  }

  @override
  SemanticColors copyWith({
    Color? up,
    Color? down,
    Color? flat,
    Color? neutral,
    Color? hit,
    Color? miss,
    Color? unsettled,
  }) {
    return SemanticColors(
      up: up ?? this.up,
      down: down ?? this.down,
      flat: flat ?? this.flat,
      neutral: neutral ?? this.neutral,
      hit: hit ?? this.hit,
      miss: miss ?? this.miss,
      unsettled: unsettled ?? this.unsettled,
    );
  }

  @override
  SemanticColors lerp(covariant SemanticColors? other, double t) {
    if (other == null) return this;
    return SemanticColors(
      up: Color.lerp(up, other.up, t)!,
      down: Color.lerp(down, other.down, t)!,
      flat: Color.lerp(flat, other.flat, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      hit: Color.lerp(hit, other.hit, t)!,
      miss: Color.lerp(miss, other.miss, t)!,
      unsettled: Color.lerp(unsettled, other.unsettled, t)!,
    );
  }
}

/// 軸一：市場方向（依台股慣例：漲=紅、跌=綠、平=灰、無方向=中性藍）。
enum MarketDirection { up, down, flat, neutral }
