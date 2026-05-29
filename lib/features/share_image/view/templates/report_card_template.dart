import 'package:flutter/material.dart';

import '../../../../app/theme/calendar_themes.dart';
import '../../../../data/models/calendar_doc.dart';
import '../../../../data/models/prediction_type.dart';
import '../../../prediction/view/prediction_visual.dart';
import '../../model/share_aspect_ratio.dart';
import 'report_summary.dart';
import 'share_watermark.dart';

/// 純 widget：月度報告卡。命中率大字 + 命中/結算/總數 + 各 PredictionType 分項
/// + 浮水印。聚合走 [ReportSummary.from]。
///
/// 尺寸固定為 [ShareAspectRatio] 的 logical size，由外層 FittedBox 縮放。
class ReportCardTemplate extends StatelessWidget {
  const ReportCardTemplate({
    required this.docs,
    required this.ratio,
    required this.theme,
    required this.symbol,
    required this.periodLabel,
    super.key,
  });

  final List<CalendarDoc> docs;
  final ShareAspectRatio ratio;
  final CalendarTheme theme;
  final String symbol;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    final summary = ReportSummary.from(docs);

    return SizedBox(
      width: ratio.width,
      height: ratio.height,
      child: Material(
        color: theme.monthBackground,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(72, 80, 72, 56),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: theme.seed,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      periodLabel,
                      style: const TextStyle(
                        fontSize: 30,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _HitRateBlock(summary: summary, theme: theme),
              const SizedBox(height: 32),
              Divider(color: theme.seed.withValues(alpha: 0.2), thickness: 2),
              const SizedBox(height: 24),
              const Text(
                '分項統計',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF444444),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _Breakdown(summary: summary)),
              const SizedBox(height: 16),
              ShareWatermark(color: theme.seed.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HitRateBlock extends StatelessWidget {
  const _HitRateBlock({required this.summary, required this.theme});

  final ReportSummary summary;
  final CalendarTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${summary.hitRatePercent}%',
              style: TextStyle(
                fontSize: 160,
                fontWeight: FontWeight.w800,
                height: 1.0,
                color: theme.seed,
              ),
            ),
            const Text(
              '命中率',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatLine(label: '總預測', value: '${summary.total}'),
            const SizedBox(height: 12),
            _StatLine(label: '已結算', value: '${summary.settled}'),
            const SizedBox(height: 12),
            _StatLine(label: '命中', value: '${summary.hit}'),
          ],
        ),
      ],
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 30, color: Color(0xFF888888)),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: Color(0xFF222222),
          ),
        ),
      ],
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.summary});

  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    // 固定 enum 順序，只列有資料（total > 0）的 type。
    final rows = <Widget>[];
    for (final type in PredictionType.values) {
      final stat = summary.byType[type];
      if (stat == null || stat.total == 0) continue;
      final visual = PredictionVisual.of(type);
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(visual.icon, size: 36, color: visual.color),
            const SizedBox(width: 16),
            Text(
              visual.label,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const Spacer(),
            Text(
              '命中 ${stat.hit} / 結算 ${stat.settled} · 共 ${stat.total}',
              style: const TextStyle(fontSize: 30, color: Color(0xFF666666)),
            ),
          ],
        ),
      ));
    }

    if (rows.isEmpty) {
      return const Center(
        child: Text(
          '本期尚無預測',
          style: TextStyle(fontSize: 34, color: Color(0xFF999999)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}
