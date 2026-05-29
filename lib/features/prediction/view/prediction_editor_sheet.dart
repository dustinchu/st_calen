import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/models/prediction.dart';
import '../../../data/models/prediction_type.dart';
import '../../calendar/viewmodel/calendar_view_model.dart';
import '../../calendar/viewmodel/settlement_view_model.dart';
import '../viewmodel/prediction_editor_view_model.dart';
import 'prediction_visual.dart';

/// 預測編輯 sheet（modal bottom sheet）。
///
/// UI：上方 SegmentedButton 切 6 種 PredictionType，下方依 type 動態顯示
/// 價格 / 漲跌幅 / 備註欄位。**儲存按鈕觸發寫入**，不做 autosave（避免
/// sheet 被滑掉造成意外寫入）。
///
/// 已存在的 prediction → 預填 + 顯示「刪除」按鈕。
class PredictionEditorSheet extends ConsumerWidget {
  const PredictionEditorSheet({
    required this.symbol,
    required this.year,
    required this.month,
    required this.day,
    super.key,
  });

  final String symbol;
  final int year;
  final int month;
  final int day;

  static Future<void> show(
    BuildContext context, {
    required String symbol,
    required DateTime date,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(_).viewInsets.bottom,
        ),
        child: PredictionEditorSheet(
          symbol: symbol,
          year: date.year,
          month: date.month,
          day: date.day,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider =
        predictionEditorViewModelProvider(symbol, year, month, day);
    final draft = ref.watch(provider);
    final vm = ref.read(provider.notifier);

    // 找出 doc 中該日已存在的 prediction（為了顯示 settle 結果 / 手動補價入口）
    final doc = ref.watch(calendarViewModelProvider).valueOrNull;
    Prediction? existing;
    if (doc != null) {
      for (final p in doc.predictions) {
        final local = p.date.toLocal();
        if (local.year == year && local.month == month && local.day == day) {
          existing = p;
          break;
        }
      }
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$symbol · $year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            // SegmentedButton 在 6 個值會撐到極窄，用 Wrap of ChoiceChip 較穩。
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PredictionType.values.map((t) {
                final v = PredictionVisual.of(t);
                return ChoiceChip(
                  selected: draft.type == t,
                  avatar: Icon(v.icon, size: 18, color: v.color),
                  label: Text(v.label),
                  onSelected: (_) => vm.setType(t),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ..._fieldsFor(draft.type, draft, vm),
            if (existing != null) ...[
              const SizedBox(height: 12),
              _SettleSection(
                symbol: symbol,
                prediction: existing,
              ),
            ],
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: '備註（選填）',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              controller: TextEditingController(text: draft.note)
                ..selection =
                    TextSelection.collapsed(offset: draft.note.length),
              onChanged: vm.setNote,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (draft.isExisting)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('刪除'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        final ok = await vm.delete();
                        if (context.mounted && ok) Navigator.of(context).pop();
                      },
                    ),
                  ),
                if (draft.isExisting) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('儲存'),
                    onPressed: draft.canSave
                        ? () async {
                            final ok = await vm.save();
                            if (context.mounted && ok) {
                              Navigator.of(context).pop();
                            }
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _fieldsFor(
    PredictionType type,
    PredictionDraft draft,
    PredictionEditorViewModel vm,
  ) {
    switch (type) {
      case PredictionType.customPrice:
        return [
          TextField(
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: '預測收盤價',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: draft.priceText)
              ..selection = TextSelection.collapsed(
                  offset: draft.priceText.length),
            onChanged: vm.setPriceText,
          ),
        ];
      case PredictionType.customPercent:
        return [
          TextField(
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: true),
            decoration: const InputDecoration(
              labelText: '漲跌幅 %',
              helperText: '相對前一交易日收盤',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: draft.percentText)
              ..selection = TextSelection.collapsed(
                  offset: draft.percentText.length),
            onChanged: vm.setPercentText,
          ),
        ];
      case PredictionType.upLimit:
      case PredictionType.downLimit:
      case PredictionType.bullish:
      case PredictionType.bearish:
        return const [];
    }
  }
}

/// 已存在 prediction 的結算結果區塊。
/// settled = true → 顯示實際收盤 + 命中狀態 chip。
/// settled = false 且為過去日 → 顯示「手動補實際收盤」欄位 + 補價按鈕。
class _SettleSection extends ConsumerStatefulWidget {
  const _SettleSection({required this.symbol, required this.prediction});

  final String symbol;
  final Prediction prediction;

  @override
  ConsumerState<_SettleSection> createState() => _SettleSectionState();
}

class _SettleSectionState extends ConsumerState<_SettleSection> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.prediction;
    if (p.settled) {
      final status = settleStatusOf(p);
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '實際收盤：${p.actualClose?.toStringAsFixed(2) ?? '—'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(status == SettleStatus.hit ? '命中' : '未命中'),
                  backgroundColor: status == SettleStatus.hit
                      ? const Color(0xFFC8E6C9)
                      : const Color(0xFFFFCDD2),
                ),
                const SizedBox(width: 8),
                if (p.hitPercent != null)
                  Text('${p.hitPercent!.toStringAsFixed(2)}%'),
              ],
            ),
          ],
        ),
      );
    }
    // 未結算：過去日才顯示手動補價
    final dateLocal = p.date.toLocal();
    final today = DateTime.now();
    final pastDay = DateTime(dateLocal.year, dateLocal.month, dateLocal.day)
        .isBefore(DateTime(today.year, today.month, today.day));
    if (!pastDay) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '尚未結算（API 無資料 / 失敗）',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '手動補實際收盤',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () async {
                final v = double.tryParse(_ctrl.text.trim());
                if (v == null || v <= 0) return;
                final ok = await ref
                    .read(settlementViewModelProvider.notifier)
                    .manualSettle(date: p.date, actualClose: v);
                if (context.mounted && ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已補價')),
                  );
                }
              },
              child: const Text('補價'),
            ),
          ],
        ),
      ],
    );
  }
}
