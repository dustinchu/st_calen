// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settlementViewModelHash() =>
    r'23dff269f695a859ba647a4655b478fb0bf15ea7';

/// 自動結算 ViewModel：
/// 訂閱 [calendarViewModelProvider] + autoSettleEnabled，當有「過去日 × 未 settled」
/// prediction 時，向 [StockApiClient.quotes] 拉收盤資料，計算 hit / hitPercent 並
/// read-modify-put 寫回 repo。
///
/// 失敗策略：quotes 失敗 / 某日無資料 → 保留 `settled = false`（不阻塞 UI），
/// 由 PredictionEditorSheet 的手動補價路徑補進。
///
/// 觸發時機：build() 內讀 doc 與 settings；當 doc 更新 → riverpod re-build → 重跑
/// settle 流程；autoSettleEnabled OFF → 立即 return。
///
/// Copied from [SettlementViewModel].
@ProviderFor(SettlementViewModel)
final settlementViewModelProvider =
    AutoDisposeAsyncNotifierProvider<SettlementViewModel, void>.internal(
  SettlementViewModel.new,
  name: r'settlementViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settlementViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SettlementViewModel = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
