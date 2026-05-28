import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/models/stock.dart';
import '../viewmodel/stock_search_view_model.dart';

class StockSearchSheet extends ConsumerStatefulWidget {
  const StockSearchSheet({super.key});

  @override
  ConsumerState<StockSearchSheet> createState() => _StockSearchSheetState();
}

class _StockSearchSheetState extends ConsumerState<StockSearchSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(stockSearchViewModelProvider);
    final viewport = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewport),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: '搜尋股票代號或名稱',
                    hintText: '例如：2330、AAPL、台積電',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (q) => ref
                      .read(stockSearchViewModelProvider.notifier)
                      .setQuery(q),
                ),
              ),
              Expanded(
                child: results.when(
                  data: (list) => _ResultList(items: list, onTap: _addAndPop),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _ErrorWithManualAdd(
                    message: '$e',
                    query: _controller.text,
                    onManualAdd: _manualAddAndPop,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addAndPop(Stock stock) async {
    final ok = await ref
        .read(stockSearchViewModelProvider.notifier)
        .addAndSelect(stock);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('加入失敗，請稍後再試')));
    }
  }

  Future<void> _manualAddAndPop(String symbol) async {
    final ok = await ref
        .read(stockSearchViewModelProvider.notifier)
        .addManually(symbol);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('請輸入有效的股票代號')));
    }
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({required this.items, required this.onTap});
  final List<Stock> items;
  final ValueChanged<Stock> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('輸入關鍵字搜尋股票', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final s = items[i];
        return ListTile(
          title: Text(s.symbol),
          subtitle: Text(s.name),
          trailing: Text(s.market.name.toUpperCase(),
              style: const TextStyle(color: Colors.grey)),
          onTap: () => onTap(s),
        );
      },
    );
  }
}

class _ErrorWithManualAdd extends StatelessWidget {
  const _ErrorWithManualAdd({
    required this.message,
    required this.query,
    required this.onManualAdd,
  });
  final String message;
  final String query;
  final ValueChanged<String> onManualAdd;

  @override
  Widget build(BuildContext context) {
    final canManual = query.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text('搜尋失敗：$message', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: canManual ? () => onManualAdd(query) : null,
            child: Text(canManual ? '直接以「$query」加入' : '請輸入 symbol'),
          ),
        ],
      ),
    );
  }
}
