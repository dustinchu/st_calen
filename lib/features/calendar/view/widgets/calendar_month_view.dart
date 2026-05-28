import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../data/models/calendar_doc.dart';
import '../../../../data/models/prediction.dart';
import '../../viewmodel/calendar_view_model.dart';

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
      },
      onPageChanged: (focused) {
        setState(() => _focusedDay = focused);
        ref.read(focusedMonthProvider.notifier).set(focused);
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          // Step 15 接 PredictionType → icon mapping。
          return null;
        },
      ),
    );
  }
}
