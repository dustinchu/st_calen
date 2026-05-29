import 'package:flutter/material.dart';

import '../../../data/models/prediction_type.dart';

/// PredictionType → icon / color / 中文標籤 的純對應表。
/// `switch` 寫死 6 個 enum 值，新增 type 時編譯期會報。
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
    switch (type) {
      case PredictionType.upLimit:
        return const PredictionVisual(
          icon: Icons.arrow_upward,
          color: Color(0xFFD32F2F),
          label: '漲停',
        );
      case PredictionType.downLimit:
        return const PredictionVisual(
          icon: Icons.arrow_downward,
          color: Color(0xFF2E7D32),
          label: '跌停',
        );
      case PredictionType.customPrice:
        return const PredictionVisual(
          icon: Icons.price_change,
          color: Color(0xFF1976D2),
          label: '自訂價',
        );
      case PredictionType.customPercent:
        return const PredictionVisual(
          icon: Icons.percent,
          color: Color(0xFF6A1B9A),
          label: '自訂漲跌幅',
        );
      case PredictionType.bullish:
        return const PredictionVisual(
          icon: Icons.trending_up,
          color: Color(0xFFE53935),
          label: '看多',
        );
      case PredictionType.bearish:
        return const PredictionVisual(
          icon: Icons.trending_down,
          color: Color(0xFF43A047),
          label: '看空',
        );
      case PredictionType.flat:
        return const PredictionVisual(
          icon: Icons.horizontal_rule,
          color: Color(0xFF757575),
          label: '平盤',
        );
    }
  }
}
