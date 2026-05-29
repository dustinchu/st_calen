import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../data/models/calendar_doc.dart';
import '../../../../data/models/prediction.dart';
import '../../../prediction/view/prediction_editor_sheet.dart';
import '../../../prediction/view/prediction_visual.dart';
import '../../viewmodel/calendar_view_model.dart';
import '../../viewmodel/settlement_view_model.dart';

/// table_calendar 的薄包裝。focusedDay / selectedDay 是 widget 自己管的；
/// 月份切換時推回 [focusedMonthProvider] 觸發 ViewModel 重新訂閱。
///
/// markerBuilder 預留 hook 但目前回 null（icon mapping 留 Step 15）。
class CalendarMonthView extends ConsumerStatefulWidget {
  const CalendarMonthView({required this.doc, super.key});

  final CalendarDoc? doc;

  @override
  ConsumerState<CalendarMonthView> createState() => _CalendarMonthViewState();
}

class _CalendarMonthViewState extends ConsumerState<CalendarMonthView> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final m = ref.read(focusedMonthProvider);
    _focusedDay = DateTime(m.year, m.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final byDay = predictionsByDay(widget.doc);
    // 訂閱 settlement view model 觸發自動結算（autoSettleEnabled ON 時）
    ref.watch(settlementViewModelProvider);
    return TableCalendar<Prediction>(
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (d) =>
          _selectedDay != null && isSameDay(_selectedDay, d),
      locale: 'zh_TW',
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableCalendarFormats: const {CalendarFormat.month: '月'},
      eventLoader: (day) {
        final p = byDay[day.day];
        return p == null ? const [] : [p];
      },
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
        final symbol = ref.read(currentSymbolProvider);
        if (symbol != null) {
          PredictionEditorSheet.show(
            context,
            symbol: symbol,
            date: selected,
          );
        }
      },
      onPageChanged: (focused) {
        setState(() => _focusedDay = focused);
        ref.read(focusedMonthProvider.notifier).set(focused);
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) =>
            _cellBackground(context, day, byDay[day.day], false),
        todayBuilder: (context, day, focusedDay) =>
            _cellBackground(context, day, byDay[day.day], true),
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return null;
          final v = PredictionVisual.of(events.first.type);
          return Positioned(
            bottom: 4,
            right: 4,
            child: Icon(v.icon, size: 14, color: v.color),
          );
        },
      ),
    );
  }

  /// 依結算狀態回傳 cell 底色 widget。
  /// 命中：淡綠；偏離：淡紅；未結算（過去日已 settled=false 也算）：淡灰；
  /// 無預測 / 未來日：透明（不染色，回 fallback container）。
  Widget _cellBackground(
      BuildContext context, DateTime day, Prediction? p, bool isToday) {
    Color? bg;
    if (p != null) {
      switch (settleStatusOf(p)) {
        case SettleStatus.hit:
          bg = const Color(0xFFC8E6C9); // 淡綠
          break;
        case SettleStatus.miss:
          bg = const Color(0xFFFFCDD2); // 淡紅
          break;
        case SettleStatus.unsettled:
          // 過去日未結算 → 灰；未來日不染色
          final todayLocal = DateTime.now();
          final dToday =
              DateTime(todayLocal.year, todayLocal.month, todayLocal.day);
          if (DateTime(day.year, day.month, day.day).isBefore(dToday)) {
            bg = const Color(0xFFEEEEEE);
          }
          break;
      }
    }
    final borderColor = isToday
        ? Theme.of(context).colorScheme.primary
        : Colors.transparent;
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text('${day.day}'),
    );
  }
}
