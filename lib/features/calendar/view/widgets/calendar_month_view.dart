import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../app/theme/calendar_themes.dart';
import '../../../../app/theme/semantic_colors.dart';
import '../../../../data/models/calendar_doc.dart';
import '../../../../data/models/prediction.dart';
import '../../../prediction/view/prediction_editor_sheet.dart';
import '../../../prediction/view/prediction_visual.dart';
import '../../../settings/viewmodel/settings_view_model.dart';
import '../../viewmodel/calendar_view_model.dart';
import '../../viewmodel/settlement_view_model.dart';
import 'hit_badge.dart';

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
    // 主題解析：CalendarDoc.themeId == 'default' → fallback 到 App 主題
    final appThemeId =
        ref.watch(settingsViewModelProvider).valueOrNull?.themeId ?? 'default';
    final docThemeId = widget.doc?.themeId ?? 'default';
    final theme = CalendarThemes.byId(
        docThemeId == 'default' ? appThemeId : docThemeId);
    final sem =
        Theme.of(context).extension<SemanticColors>() ?? SemanticColors.dark;
    return Container(
      color: theme.monthBackground,
      child: TableCalendar<Prediction>(
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
            _cell(context, day, byDay[day.day], false, sem),
        todayBuilder: (context, day, focusedDay) =>
            _cell(context, day, byDay[day.day], true, sem),
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return null;
          final p = events.first;
          // 軸一：icon 依市場方向上色（customPercent 依正負）。
          final color =
              sem.directionColor(marketDirectionOf(p.type, percent: p.percent));
          return Positioned(
            bottom: 4,
            right: 4,
            child: Icon(PredictionVisual.of(p.type).icon, size: 14, color: color),
          );
        },
      ),
    ),
    );
  }

  /// §2 落地：cell 用中性底（透明），命中狀態改右上角徽章——不再用整格綠/紅底
  /// （整格紅綠會與軸一市場方向撞色）。徽章決策走 [hitBadgeOf]。
  Widget _cell(BuildContext context, DateTime day, Prediction? p, bool isToday,
      SemanticColors sem) {
    final borderColor =
        isToday ? Theme.of(context).colorScheme.primary : Colors.transparent;
    final cell = Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text('${day.day}'),
    );
    if (p == null) return cell;
    final badge = hitBadgeOf(settleStatusOf(p), isPast: _isPast(day));
    if (badge == HitBadge.none) return cell;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        cell,
        Positioned(top: 2, right: 2, child: HitBadgeMarker(badge: badge)),
      ],
    );
  }

  /// 該日是否早於今日（當日不算過去日 → 未結算當日不上徽章，§2）。
  bool _isPast(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(day.year, day.month, day.day).isBefore(today);
  }
}
