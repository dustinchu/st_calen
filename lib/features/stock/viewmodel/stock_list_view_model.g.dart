// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stockLocalDataSourceHash() =>
    r'd9c33897bc3c5367b3df75c2158c31316dcb6fc1';

/// See also [stockLocalDataSource].
@ProviderFor(stockLocalDataSource)
final stockLocalDataSourceProvider = Provider<StockLocalDataSource>.internal(
  stockLocalDataSource,
  name: r'stockLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stockLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StockLocalDataSourceRef = ProviderRef<StockLocalDataSource>;
String _$stockRepositoryHash() => r'42fa0ebb7838ba15c5d8f3f9d6a7efafa868cff2';

/// See also [stockRepository].
@ProviderFor(stockRepository)
final stockRepositoryProvider = Provider<StockRepository>.internal(
  stockRepository,
  name: r'stockRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stockRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StockRepositoryRef = ProviderRef<StockRepository>;
String _$stockApiClientHash() => r'10278d72a036b65f46ae149e2f9620de873d7848';

/// Step 14 階段固定回 mock。Step 11 之後改成 Dio 實作並接 base URL。
///
/// Copied from [stockApiClient].
@ProviderFor(stockApiClient)
final stockApiClientProvider = Provider<StockApiClient>.internal(
  stockApiClient,
  name: r'stockApiClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stockApiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StockApiClientRef = ProviderRef<StockApiClient>;
String _$stockListViewModelHash() =>
    r'206882f76a92d7f56747b921a28fad31b546be75';

/// 訂閱 watch list；UI 用這個 provider 拿 chips bar 顯示用的清單。
///
/// Copied from [stockListViewModel].
@ProviderFor(stockListViewModel)
final stockListViewModelProvider =
    AutoDisposeStreamProvider<List<Stock>>.internal(
  stockListViewModel,
  name: r'stockListViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stockListViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StockListViewModelRef = AutoDisposeStreamProviderRef<List<Stock>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
