import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/models/prediction_type.dart';
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
