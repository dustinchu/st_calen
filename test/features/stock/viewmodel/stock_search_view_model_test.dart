import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stock_calendar/core/utils/result.dart';
import 'package:stock_calendar/data/models/market.dart';
import 'package:stock_calendar/data/models/stock.dart';
import 'package:stock_calendar/data/repositories/stock_repository.dart';
import 'package:stock_calendar/data/sources/local/stock_local_ds.dart';
import 'package:stock_calendar/features/calendar/viewmodel/calendar_view_model.dart';
import 'package:stock_calendar/features/stock/data/stock_api_client.dart';
import 'package:stock_calendar/features/stock/viewmodel/stock_list_view_model.dart';
import 'package:stock_calendar/features/stock/viewmodel/stock_search_view_model.dart';

class _SpyApi implements StockApiClient {
  int calls = 0;
  Result<List<Stock>, AppError> Function(String) handler =
      (_) => const Result.success([]);

  @override
  Future<Result<List<Stock>, AppError>> search(String query) async {
    calls++;
    return handler(query);
  }
}

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('stock_search_vm_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(StockAdapter().typeId)) {
      Hive.registerAdapter(StockAdapter());
    }
    if (!Hive.isAdapterRegistered(MarketAdapter().typeId)) {
      Hive.registerAdapter(MarketAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  late Box<dynamic> box;
  late StockRepository repo;
  late _SpyApi api;
  late ProviderContainer container;

  setUp(() async {
    box = await Hive.openBox<dynamic>(
        'search_test_${DateTime.now().microsecondsSinceEpoch}');
    repo = StockRepository(local: StockLocalDataSource(box));
    api = _SpyApi();
    container = ProviderContainer(overrides: [
      stockRepositoryProvider.overrideWithValue(repo),
      stockApiClientProvider.overrideWithValue(api),
    ]);
    // 訂閱 provider 防止 auto-dispose 取消 debounce timer。
    container.listen(stockSearchViewModelProvider, (_, __) {});
  });

  tearDown(() async {
    container.dispose();
    await box.deleteFromDisk();
  });

  const tsmc = Stock(symbol: '2330.TW', market: Market.tw, name: '台積電');

  test('empty query → resets to empty data without calling api', () async {
    final vm = container.read(stockSearchViewModelProvider.notifier);
    vm.setQuery('  ');
    expect(api.calls, 0);
    expect(container.read(stockSearchViewModelProvider).valueOrNull, isEmpty);
  });

  test('debounces rapid setQuery calls into single api call', () async {
    api.handler = (q) => Result.success([tsmc]);
    final vm = container.read(stockSearchViewModelProvider.notifier);
    vm.setQuery('2');
    vm.setQuery('23');
    vm.setQuery('233');
    expect(api.calls, 0, reason: 'still within debounce window');
    await Future<void>.delayed(
        StockSearchViewModel.debounceDuration + const Duration(milliseconds: 80));
    expect(api.calls, 1);
    expect(container.read(stockSearchViewModelProvider).valueOrNull,
        equals([tsmc]));
  });

  test('api failure surfaces as AsyncValue.error', () async {
    api.handler = (_) => const Result.failure(NetworkError('boom'));
    final vm = container.read(stockSearchViewModelProvider.notifier);
    vm.setQuery('foo');
    await Future<void>.delayed(
        StockSearchViewModel.debounceDuration + const Duration(milliseconds: 80));
    expect(container.read(stockSearchViewModelProvider).hasError, isTrue);
  });

  test('addAndSelect writes to repo and auto-selects first symbol', () async {
    expect(container.read(currentSymbolProvider), isNull);
    final ok = await container
        .read(stockSearchViewModelProvider.notifier)
        .addAndSelect(tsmc);
    expect(ok, isTrue);
    expect(container.read(currentSymbolProvider), '2330.TW');
    final list = (await repo.list()).fold((v) => v, (_) => <Stock>[]);
    expect(list, contains(tsmc));
  });

  test('addAndSelect does NOT override currentSymbol when one already exists',
      () async {
    container.read(currentSymbolProvider.notifier).set('AAPL');
    await container
        .read(stockSearchViewModelProvider.notifier)
        .addAndSelect(tsmc);
    expect(container.read(currentSymbolProvider), 'AAPL');
  });

  test('addManually with empty symbol returns false', () async {
    final ok = await container
        .read(stockSearchViewModelProvider.notifier)
        .addManually('   ');
    expect(ok, isFalse);
  });

  test('addManually with valid symbol persists and selects', () async {
    final ok = await container
        .read(stockSearchViewModelProvider.notifier)
        .addManually('9999.TW');
    expect(ok, isTrue);
    expect(container.read(currentSymbolProvider), '9999.TW');
  });
}
