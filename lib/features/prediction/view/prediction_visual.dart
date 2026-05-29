import 'package:flutter/material.dart';

import '../../../app/theme/semantic_colors.dart';
import '../../../data/models/prediction_type.dart';

/// PredictionType → 軸一市場方向（§2）。
///
/// 純函式（無 context）。[customPercent] 依正負決定方向，0 視為平盤（user 拍板）；
/// 無值（編輯前）視為中性。畫面用 [SemanticColors.directionColor] 把方向換成主題色。
MarketDirection marketDirectionOf(PredictionType type, {double? percent}) {
  switch (type) {
    case PredictionType.upLimit:
    case PredictionType.bullish:
      return MarketDirection.up;
    case PredictionType.downLimit:
    case PredictionType.bearish:
      return MarketDirection.down;
    case PredictionType.flat:
      return MarketDirection.flat;
    case PredictionType.customPrice:
      return MarketDirection.neutral;
    case PredictionType.customPercent:
      if (percent == null) return MarketDirection.neutral;
      if (percent > 0) return MarketDirection.up;
      if (percent < 0) return MarketDirection.down;
      return MarketDirection.flat;
  }
}

/// PredictionType → icon / color / 中文標籤 的純對應表。
/// `switch` 寫死 7 個 enum 值，新增 type 時編譯期會報。
///
/// [color] 為軸一靜態色（§2）；customPercent 無值時取中性藍，
/// 月曆 marker 另走 [marketDirectionOf] + [SemanticColors.directionColor]
/// 取得依正負的方向色。
class PredictionVisual {
  final IconData icon;
  final Color color;
  final String label;

  const PredictionVisual({
    required this.icon,
    required this.color,
    required this.label,
  });

  static PredictionVisual of(PredictionType type) {
    final color = SemanticColors.dark.directionColor(marketDirectionOf(type));
    switch (type) {
      case PredictionType.upLimit:
        return PredictionVisual(
          icon: Icons.arrow_upward,
          color: color,
          label: '漲停',
        );
      case PredictionType.downLimit:
        return PredictionVisual(
          icon: Icons.arrow_downward,
          color: color,
          label: '跌停',
        );
      case PredictionType.customPrice:
        return PredictionVisual(
          icon: Icons.price_change,
          color: color,
          label: '自訂價',
        );
      case PredictionType.customPercent:
        return PredictionVisual(
          icon: Icons.percent,
          color: color,
          label: '自訂漲跌幅',
        );
      case PredictionType.bullish:
        return PredictionVisual(
          icon: Icons.trending_up,
          color: color,
          label: '看多',
        );
      case PredictionType.bearish:
        return PredictionVisual(
          icon: Icons.trending_down,
          color: color,
          label: '看空',
        );
      case PredictionType.flat:
        return PredictionVisual(
          icon: Icons.horizontal_rule,
          color: color,
          label: '平盤',
        );
    }
  }
}
