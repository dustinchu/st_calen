import 'package:flutter/material.dart';

import '../../../../app/theme/calendar_themes.dart';
import '../../../../data/models/prediction.dart';
import '../../../../data/models/prediction_type.dart';
import '../../../calendar/viewmodel/settlement_view_model.dart';
import '../../../prediction/view/prediction_visual.dart';
import '../../model/share_aspect_ratio.dart';
import '../../model/share_background.dart';
import 'share_watermark.dart';

/// 純 widget：單日預測卡。大日期 + type icon/label + 收盤/命中 chip
/// + 漸層或主題底色背景 + 浮水印。
///
/// 尺寸固定為 [ShareAspectRatio] 的 logical size，由外層 FittedBox 縮放。
class SingleDayTemplate extends StatelessWidget {
  const SingleDayTemplate({
    required this.prediction,
    required this.ratio,
    required this.theme,
    required this.symbol,
    required this.background,
    super.key,
  });

  final Prediction prediction;
  final ShareAspectRatio ratio;
  final CalendarTheme theme;
  final String symbol;
  final ShareBackground background;

  static const _weekdays = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    final gradient = background.gradient;
    final dark = background.isDark;
    final fg = dark ? Colors.white : const Color(0xFF1A1A1A);
    final subFg = dark ? Colors.white70 : const Color(0xFF666666);
    final visual = PredictionVisual.of(prediction.type);
    final date = prediction.date.toLocal();

    return SizedBox(
      width: ratio.width,
      height: ratio.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? theme.monthBackground : null,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(72, 80, 72, 56),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: dark ? Colors.white : theme.seed,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${date.year}/${_two(date.month)}',
                    style: TextStyle(fontSize: 30, color: subFg),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${date.month} 月 ${date.day} 日 · 週${_weekdays[date.weekday - 1]}',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w500,
                  color: subFg,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 200,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  color: fg,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Icon(visual.icon, size: 56, color: visual.color),
                  const SizedBox(width: 16),
                  Text(
                    visual.label,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _chips(dark, fg),
              ),
              const Spacer(),
              ShareWatermark(
                color: dark
                    ? Colors.white70
                    : theme.seed.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _chips(bool dark, Color fg) {
    final chips = <Widget>[];

    final predicted = _predictedLabel();
    if (predicted != null) {
      chips.add(_NeutralChip(text: predicted, dark: dark, fg: fg));
    }

    if (prediction.settled && prediction.actualClose != null) {
      chips.add(_NeutralChip(
        text: '收盤 ${prediction.actualClose!.toStringAsFixed(2)}',
        dark: dark,
        fg: fg,
      ));
    }

    chips.add(_StatusChip(status: settleStatusOf(prediction)));
    return chips;
  }

  /// 預測值描述（自訂價 / 自訂漲跌幅才有具體數字；其餘 type 由大 label 表達）。
  String? _predictedLabel() {
    switch (prediction.type) {
      case PredictionType.customPrice:
        final price = prediction.price;
        return price == null ? null : '預測價 ${price.toStringAsFixed(2)}';
      case PredictionType.customPercent:
        final pct = prediction.percent;
        if (pct == null) return null;
        final sign = pct >= 0 ? '+' : '';
        return '預測 $sign${pct.toStringAsFixed(1)}%';
      case PredictionType.upLimit:
      case PredictionType.downLimit:
      case PredictionType.bullish:
      case PredictionType.bearish:
      case PredictionType.flat:
        return null;
    }
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}

class _NeutralChip extends StatelessWidget {
  const _NeutralChip({required this.text, required this.dark, required this.fg});

  final String text;
  final bool dark;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: 0.2)
            : const Color(0xFF000000).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final SettleStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      SettleStatus.hit => ('命中', const Color(0xFF2E7D32)),
      SettleStatus.miss => ('未命中', const Color(0xFFC62828)),
      SettleStatus.unsettled => ('待結算', const Color(0xFF757575)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
