import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../data/models/market.dart';
import '../../../data/models/stock.dart';
import '../../calendar/viewmodel/calendar_view_model.dart';
import 'stock_list_view_model.dart';

part 'stock_search_view_model.g.dart';

/// 搜尋 sheet 用 ViewModel。
///
/// - [setQuery] 進入後做 [debounceDuration] debounce，期間若再被呼叫則前一個排程取消，
///   避免每次按鍵都打 API。
/// - 搜尋結果以 `AsyncValue<List<Stock>>` 對外暴露（loading / data / error）。
/// - [addAndSelect] 把 stock 寫入 repository；若當前 [currentSymbolProvider] 為 null
///   （= 用戶第一次加股票），順帶 set 成這支 → 首支自動選中（顯式 side effect）。
@riverpod
class StockSearchViewModel extends _$StockSearchViewModel {
  Timer? _debounce;
  int _seq = 0;

  static const Duration debounceDuration = Duration(milliseconds: 300);

  @override
  AsyncValue<List<Stock>> build() {
    ref.onDispose(() => _debounce?.cancel());
    return const AsyncValue.data([]);
  }

  void setQuery(String query) {
    _debounce?.cancel();
    final q = query.trim();
    if (q.isEmpty) {
      _seq++; // 取消尚未完成的 inflight
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    _debounce = Timer(debounceDuration, () => _run(q));
  }

  Future<void> _run(String q) async {
    final seq = ++_seq;
    final result = await ref.read(stockApiClientProvider).search(q);
    if (seq != _seq) return; // 已有更新的 query，丟棄這次結果
    state = result.when(
      success: (list) => AsyncValue.data(list),
      failure: (e) => AsyncValue.error(e, StackTrace.current),
    );
  }

  /// 加入 stock 並（若是首支）自動選中。
  /// 回傳 true 代表加入成功；false 代表 repository 失敗。
  Future<bool> addAndSelect(Stock stock) async {
    final repo = ref.read(stockRepositoryProvider);
    final res = await repo.add(stock);
    return res.when(
      success: (_) {
        unawaited(analyticsService.logAddStock(
          symbol: stock.symbol,
          market: stock.market.name,
        ));
        final current = ref.read(currentSymbolProvider);
        if (current == null) {
          ref.read(currentSymbolProvider.notifier).set(stock.symbol);
        }
        return true;
      },
      failure: (_) => false,
    );
  }

  /// Fallback：API 失敗時，用戶手動輸入 symbol 直接加入。
  /// market 預設 [Market.tw]，name 暫填 symbol（之後 settle quote 可補）。
  Future<bool> addManually(String symbol, {Market market = Market.tw}) {
    final trimmed = symbol.trim();
    if (trimmed.isEmpty) return Future.value(false);
    return addAndSelect(
      Stock(symbol: trimmed, market: market, name: trimmed),
    );
  }
}
