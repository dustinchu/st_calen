// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_search_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stockSearchViewModelHash() =>
    r'05278ec21f490f1e1ce3f513330d9db1b645f0f3';

/// 搜尋 sheet 用 ViewModel。
///
/// - [setQuery] 進入後做 [debounceDuration] debounce，期間若再被呼叫則前一個排程取消，
///   避免每次按鍵都打 API。
/// - 搜尋結果以 `AsyncValue<List<Stock>>` 對外暴露（loading / data / error）。
/// - [addAndSelect] 把 stock 寫入 repository；若當前 [currentSymbolProvider] 為 null
///   （= 用戶第一次加股票），順帶 set 成這支 → 首支自動選中（顯式 side effect）。
///
/// Copied from [StockSearchViewModel].
@ProviderFor(StockSearchViewModel)
final stockSearchViewModelProvider = AutoDisposeNotifierProvider<
    StockSearchViewModel, AsyncValue<List<Stock>>>.internal(
  StockSearchViewModel.new,
  name: r'stockSearchViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stockSearchViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StockSearchViewModel = AutoDisposeNotifier<AsyncValue<List<Stock>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
