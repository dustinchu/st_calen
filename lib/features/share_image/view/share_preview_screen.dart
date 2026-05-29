import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/calendar_themes.dart';
import '../../../data/models/calendar_doc.dart';
import '../../../data/models/prediction.dart';
import '../../calendar/viewmodel/calendar_view_model.dart';
import '../../settings/viewmodel/settings_view_model.dart';
import '../model/share_aspect_ratio.dart';
import '../model/share_background.dart';
import '../model/share_template.dart';
import '../service/image_export_service.dart';
import 'templates/full_calendar_template.dart';
import 'templates/report_card_template.dart';
import 'templates/single_day_template.dart';

class SharePreviewScreen extends ConsumerStatefulWidget {
  const SharePreviewScreen({required this.symbol, super.key});

  final String symbol;

  @override
  ConsumerState<SharePreviewScreen> createState() => _SharePreviewScreenState();
}

class _SharePreviewScreenState extends ConsumerState<SharePreviewScreen> {
  final _boundaryKey = GlobalKey();
  final _exporter = const ImageExportService();
  ShareTemplate _template = ShareTemplate.fullCalendar;
  ShareAspectRatio _ratio = ShareAspectRatio.story916;
  ShareBackground _bg = ShareBackground.none;

  /// singleDay 選中日；null → build 時 fallback 到「今日 or 第一筆」。
  DateTime? _selectedDay;

  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final docAsync = ref.watch(calendarViewModelProvider);
    final month = ref.watch(focusedMonthProvider);
    final appThemeId =
        ref.watch(settingsViewModelProvider).valueOrNull?.themeId ?? 'default';
    final doc = docAsync.valueOrNull;
    final docThemeId = doc?.themeId ?? 'default';
    final theme = CalendarThemes.byId(
        docThemeId == 'default' ? appThemeId : docThemeId);

    final predictions = _sortedPredictions(doc);
    final selected = _effectiveSelected(predictions);

    return Scaffold(
      appBar: AppBar(title: const Text('分享')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: SegmentedButton<ShareTemplate>(
                segments: [
                  for (final t in ShareTemplate.values)
                    ButtonSegment(value: t, label: Text(t.displayName)),
                ],
                selected: {_template},
                onSelectionChanged: (s) => setState(() => _template = s.first),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: SegmentedButton<ShareAspectRatio>(
                segments: [
                  for (final r in ShareAspectRatio.values)
                    ButtonSegment(value: r, label: Text(r.label)),
                ],
                selected: {_ratio},
                onSelectionChanged: (s) => setState(() => _ratio = s.first),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: RepaintBoundary(
                      key: _boundaryKey,
                      child: _preview(doc, theme, month, selected),
                    ),
                  ),
                ),
              ),
            ),
            if (_template == ShareTemplate.singleDay) ...[
              _DaySelector(
                predictions: predictions,
                selected: selected,
                onPick: (p) => setState(() => _selectedDay = p.date),
              ),
              _BackgroundSelector(
                value: _bg,
                onPick: (b) => setState(() => _bg = b),
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          (_busy || !_canShare(selected)) ? null : _saveToGallery,
                      icon: const Icon(Icons.save_alt),
                      label: const Text('儲存到相簿'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          (_busy || !_canShare(selected)) ? null : _share,
                      icon: const Icon(Icons.share),
                      label: const Text('分享'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _preview(
    CalendarDoc? doc,
    CalendarTheme theme,
    DateTime month,
    Prediction? selected,
  ) {
    switch (_template) {
      case ShareTemplate.fullCalendar:
        return FullCalendarTemplate(
          doc: doc,
          theme: theme,
          ratio: _ratio,
          symbol: widget.symbol,
          year: month.year,
          month: month.month,
        );
      case ShareTemplate.singleDay:
        if (selected == null) {
          return _EmptyCard(ratio: _ratio, theme: theme, message: '本月尚無預測');
        }
        return SingleDayTemplate(
          prediction: selected,
          ratio: _ratio,
          theme: theme,
          symbol: widget.symbol,
          background: _bg,
        );
      case ShareTemplate.reportCard:
        return ReportCardTemplate(
          docs: [if (doc != null) doc],
          ratio: _ratio,
          theme: theme,
          symbol: widget.symbol,
          periodLabel: '${month.year} 年 ${_two(month.month)} 月',
        );
    }
  }

  /// 當前 focusedMonth doc 的 predictions，依日期排序。
  List<Prediction> _sortedPredictions(CalendarDoc? doc) {
    final list = [...(doc?.predictions ?? const <Prediction>[])];
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// singleDay 有效選中：_selectedDay 命中 → 用之；否則今日(若有) → 否則第一筆。
  Prediction? _effectiveSelected(List<Prediction> predictions) {
    if (predictions.isEmpty) return null;
    final sel = _selectedDay;
    if (sel != null) {
      for (final p in predictions) {
        if (_sameDay(p.date, sel)) return p;
      }
    }
    final today = DateTime.now();
    for (final p in predictions) {
      if (_sameDay(p.date, today)) return p;
    }
    return predictions.first;
  }

  bool _canShare(Prediction? selected) =>
      _template != ShareTemplate.singleDay || selected != null;

  Future<Uint8List?> _capture() => _exporter.capture(_boundaryKey);

  Future<void> _saveToGallery() async {
    setState(() => _busy = true);
    try {
      final bytes = await _capture();
      if (bytes == null) {
        _toast('截圖失敗');
        return;
      }
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          _toast('未取得相簿權限');
          return;
        }
      }
      await Gal.putImageBytes(bytes, name: _fileName());
      _toast('已儲存到相簿');
    } catch (e) {
      _toast('儲存失敗：$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final bytes = await _capture();
      if (bytes == null) {
        _toast('截圖失敗');
        return;
      }
      await SharePlus.instance.share(ShareParams(
        files: [
          XFile.fromData(bytes, mimeType: 'image/png', name: '${_fileName()}.png'),
        ],
      ));
    } catch (e) {
      _toast('分享失敗：$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _fileName() {
    final month = ref.read(focusedMonthProvider);
    final base = '${widget.symbol}_${month.year}-${_two(month.month)}';
    switch (_template) {
      case ShareTemplate.fullCalendar:
        return base;
      case ShareTemplate.singleDay:
        return '${base}_day';
      case ShareTemplate.reportCard:
        return '${base}_report';
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  static bool _sameDay(DateTime a, DateTime b) {
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}

/// singleDay：本月已預測日的橫向 chip 選擇器。
class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.predictions,
    required this.selected,
    required this.onPick,
  });

  final List<Prediction> predictions;
  final Prediction? selected;
  final ValueChanged<Prediction> onPick;

  @override
  Widget build(BuildContext context) {
    if (predictions.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: predictions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final p = predictions[i];
          final d = p.date.toLocal();
          final isSel = selected != null &&
              _SharePreviewScreenState._sameDay(p.date, selected!.date);
          return Center(
            child: ChoiceChip(
              label: Text('${d.month}/${d.day}'),
              selected: isSel,
              onSelected: (_) => onPick(p),
            ),
          );
        },
      ),
    );
  }
}

/// singleDay：背景漸層橫向選擇器（含「無背景」）。
class _BackgroundSelector extends StatelessWidget {
  const _BackgroundSelector({required this.value, required this.onPick});

  final ShareBackground value;
  final ValueChanged<ShareBackground> onPick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: ShareBackground.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final bg = ShareBackground.values[i];
          final isSel = bg == value;
          return GestureDetector(
            onTap: () => onPick(bg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: bg.gradient,
                    color: bg.gradient == null ? const Color(0xFFEEEEEE) : null,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSel
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: bg == ShareBackground.none
                      ? const Icon(Icons.block, size: 22, color: Color(0xFF999999))
                      : null,
                ),
                const SizedBox(height: 4),
                Text(bg.label, style: const TextStyle(fontSize: 11)),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// singleDay 本月無預測時的占位卡（維持 ratio 比例，避免 FittedBox 崩）。
class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.ratio,
    required this.theme,
    required this.message,
  });

  final ShareAspectRatio ratio;
  final CalendarTheme theme;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ratio.width,
      height: ratio.height,
      child: Material(
        color: theme.monthBackground,
        child: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 48, color: Color(0xFF999999)),
          ),
        ),
      ),
    );
  }
}
