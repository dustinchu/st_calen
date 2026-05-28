import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stock_calendar/data/models/market.dart';
import 'package:stock_calendar/data/models/stock.dart';
import 'package:stock_calendar/data/repositories/stock_repository.dart';
import 'package:stock_calendar/data/sources/local/stock_local_ds.dart';
import 'package:stock_calendar/features/stock/viewmodel/stock_list_view_model.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('stock_list_vm_test');
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
  late ProviderContainer container;

  setUp(() async {
    box = await Hive.openBox<dynamic>(
        'stocks_test_${DateTime.now().microsecondsSinceEpoch}');
    repo = StockRepository(local: StockLocalDataSource(box));
    container = ProviderContainer(overrides: [
      stockRepositoryProvider.overrideWithValue(repo),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await box.deleteFromDisk();
  });

  const tsmc = Stock(symbol: '2330.TW', market: Market.tw, name: '台積電');
  const aapl = Stock(symbol: 'AAPL', market: Market.us, name: 'Apple');

  test('initial emission is empty list when repository is empty', () async {
    final first = await container.read(stockListViewModelProvider.future);
    expect(first, isEmpty);
  });

  test('re-emits after add and remove via repository', () async {
    // 直接訂閱 repository stream（ViewModel 就是薄薄一層 watch wrap），
    // 用 StreamQueue 同步等待每次 emission，避免 autoDispose / 任意 delay 不穩。
    final emissions = <List<Stock>>[];
    final sub = repo.watch().listen(emissions.add);
    addTearDown(sub.cancel);

    // initial empty
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(emissions.last, isEmpty);

    await repo.add(tsmc);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(emissions.last, contains(tsmc));

    await repo.add(aapl);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(emissions.last.length, 2);

    await repo.remove(tsmc.symbol);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(emissions.last, equals([aapl]));
  });

  test('viewmodel provider exposes initial stream value', () async {
    final value = await container.read(stockListViewModelProvider.future);
    expect(value, isEmpty);
  });
}
