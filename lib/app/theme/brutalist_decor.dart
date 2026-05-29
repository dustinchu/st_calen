import 'package:flutter/material.dart';

/// meme 主題的 neo-brutalist 裝飾參數（DESIGN.md「Meme Mode Elevation」）。
///
/// 畫面（卡片 / cell）讀此 extension 決定是否畫實邊 + 硬陰影。
/// U3 只定義 + 各主題攜帶值；實際套用留 U5（cell）/ U8（分享卡）。
@immutable
class BrutalistDecor extends ThemeExtension<BrutalistDecor> {
  const BrutalistDecor({
    required this.borderWidth,
    required this.shadowOffset,
    required this.hardShadow,
  });

  /// 非 meme 主題：無實邊、無硬陰影（走一般 tonal / 玻璃感）。
  static const BrutalistDecor none = BrutalistDecor(
    borderWidth: 0,
    shadowOffset: Offset.zero,
    hardShadow: false,
  );

  /// meme：2px 實邊 + 4px offset / 0 blur 硬陰影（comic-book / neo-brutalist）。
  static const BrutalistDecor meme = BrutalistDecor(
    borderWidth: 2,
    shadowOffset: Offset(4, 4),
    hardShadow: true,
  );

  /// 實邊寬（0 = 不畫）。
  final double borderWidth;

  /// 硬陰影位移（blur 恆為 0）。
  final Offset shadowOffset;

  /// 是否啟用硬陰影。
  final bool hardShadow;

  @override
  BrutalistDecor copyWith({
    double? borderWidth,
    Offset? shadowOffset,
    bool? hardShadow,
  }) {
    return BrutalistDecor(
      borderWidth: borderWidth ?? this.borderWidth,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      hardShadow: hardShadow ?? this.hardShadow,
    );
  }

  @override
  BrutalistDecor lerp(covariant BrutalistDecor? other, double t) {
    if (other == null) return this;
    return BrutalistDecor(
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
      shadowOffset: Offset.lerp(shadowOffset, other.shadowOffset, t)!,
      hardShadow: t < 0.5 ? hardShadow : other.hardShadow,
    );
  }
}
