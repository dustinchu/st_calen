import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/models/stock.dart';
import '../../calendar/viewmodel/calendar_view_model.dart';
import '../viewmodel/stock_list_view_model.dart';
import 'stock_search_sheet.dart';

/// CalendarScreen AppBar 下方的水平股票切換列。
///
/// - 點 chip → set [currentSymbolProvider]
/// - 長按 chip → 確認後從 repository 刪除（並在刪除當前選中股票時清掉 currentSymbol）
/// - 末端「+」鈕 → 打開搜尋 sheet
class StockChipsBar extends ConsumerWidget {
  const StockChipsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(stockListViewModelProvider);
    final currentSymbol = ref.watch(currentSymbolProvider);

    return SizedBox(
      height: 48,
      child: listAsync.when(
        data: (stocks) => _buildList(context, ref, stocks, currentSymbol),
        loading: () => const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (e, _) => Center(child: Text('讀取自選股失敗：$e')),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<Stock> stocks,
    String? currentSymbol,
  ) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: stocks.length + 1,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        if (index == stocks.length) return _AddButton(onTap: () => _openSearch(context));
        final stock = stocks[index];
        final selected = stock.symbol == currentSymbol;
        return Center(
          child: GestureDetector(
            onLongPress: () => _confirmDelete(context, ref, stock, selected),
            child: FilterChip(
              label: Text(stock.symbol),
              selected: selected,
              onSelected: (_) =>
                  ref.read(currentSymbolProvider.notifier).set(stock.symbol),
            ),
          ),
        );
      },
    );
  }

  void _openSearch(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const StockSearchSheet(),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Stock stock,
    bool selected,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('刪除自選股'),
        content: Text('確定要移除 ${stock.symbol}（${stock.name}）嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(stockRepositoryProvider).remove(stock.symbol);
    if (selected) {
      ref.read(currentSymbolProvider.notifier).set(null);
    }
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ActionChip(
        avatar: const Icon(Icons.add, size: 18),
        label: const Text('新增'),
        onPressed: onTap,
      ),
    );
  }
}
