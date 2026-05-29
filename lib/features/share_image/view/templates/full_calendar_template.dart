import 'package:flutter/material.dart';

import '../../../../app/theme/calendar_themes.dart';
import '../../../../data/models/calendar_doc.dart';
import '../../../../data/models/prediction.dart';
import '../../../calendar/viewmodel/settlement_view_model.dart';
import '../../../prediction/view/prediction_visual.dart';
import '../../model/share_aspect_ratio.dart';

/// 純 widget：吃 [CalendarDoc] + [CalendarTheme] + [ShareAspectRatio]，
/// 自繪整月行事曆網格（不依賴 table_calendar，方便客製版型）。
///
/// 尺寸固定為 [ShareAspectRatio] 的 logical size，由外層 FittedBox 縮放。
class FullCalendarTemplate extends StatelessWidget {
  const FullCalendarTemplate({
    required this.doc,
    required this.theme,
    required this.ratio,
    required this.symbol,
    required this.year,
    required this.month,
    super.key,
  });

  final CalendarDoc? doc;
  final CalendarTheme theme;
  final ShareAspectRatio ratio;
  final String symbol;
  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    final byDay = <int, Prediction>{
      for (final p in (doc?.predictions ?? const <Prediction>[]))
        p.date.toLocal().day: p,
    };
    final monday0 = DateTime(year, month, 1).weekday - 1; // 0=Mon..6=Sun
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final totalCells = ((monday0 + daysInMonth) / 7).ceil() * 7;

    return SizedBox(
      width: ratio.width,
      height: ratio.height,
      child: Material(
        color: theme.monthBackground,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(48, 56, 48, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(year: year, month: month, symbol: symbol, theme: theme),
              const SizedBox(height: 24),
              _WeekdayRow(theme: theme),
              const SizedBox(height: 8),
              Expanded(
                child: _Grid(
                  totalCells: totalCells,
                  monday0: monday0,
                  daysInMonth: daysInMonth,
                  byDay: byDay,
                  theme: theme,
                ),
              ),
              const SizedBox(height: 16),
              _Watermark(theme: theme),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.year,
    required this.month,
    required this.symbol,
    required this.theme,
  });

  final int year;
  final int month;
  final String symbol;
  final CalendarTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$year 年 ${month.toString().padLeft(2, '0')} 月',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: theme.seed,
            height: 1.0,
          ),
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            '· $symbol',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow({required this.theme});

  final CalendarTheme theme;

  static const _names = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < 7; i++)
          Expanded(
            child: Center(
              child: Text(
                _names[i],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: i >= 5
                      ? theme.seed.withValues(alpha: 0.7)
                      : const Color(0xFF555555),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.totalCells,
    required this.monday0,
    required this.daysInMonth,
    required this.byDay,
    required this.theme,
  });

  final int totalCells;
  final int monday0;
  final int daysInMonth;
  final Map<int, Prediction> byDay;
  final CalendarTheme theme;

  @override
  Widget build(BuildContext context) {
    final rows = totalCells ~/ 7;
    return Column(
      children: [
        for (int r = 0; r < rows; r++)
          Expanded(
            child: Row(
              children: [
                for (int c = 0; c < 7; c++)
                  Expanded(
                    child: _buildCell(r * 7 + c),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCell(int idx) {
    final dayNum = idx - monday0 + 1;
    if (dayNum < 1 || dayNum > daysInMonth) {
      return const SizedBox.shrink();
    }
    final p = byDay[dayNum];
    Color? bg;
    if (p != null) {
      switch (settleStatusOf(p)) {
        case SettleStatus.hit:
          bg = theme.hitCellBg;
          break;
        case SettleStatus.miss:
          bg = theme.missCellBg;
          break;
        case SettleStatus.unsettled:
          bg = theme.unsettledCellBg;
          break;
      }
    }
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '$dayNum',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF222222),
                ),
              ),
            ),
            if (p != null)
              Positioned(
                bottom: 6,
                right: 0,
                left: 0,
                child: Center(
                  child: Icon(
                    PredictionVisual.of(p.type).icon,
                    size: 18,
                    color: PredictionVisual.of(p.type).color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Watermark extends StatelessWidget {
  const _Watermark({required this.theme});

  final CalendarTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(Icons.calendar_month,
            size: 18, color: theme.seed.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Text(
          '股市行事曆',
          style: TextStyle(
            fontSize: 16,
            color: theme.seed.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
