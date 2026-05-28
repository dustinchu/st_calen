import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stock_calendar/core/storage/hive_init.dart';
import 'package:stock_calendar/core/utils/result.dart';
import 'package:stock_calendar/data/models/market.dart';
import 'package:stock_calendar/data/models/stock.dart';
import 'package:stock_calendar/data/sources/local/stock_local_ds.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('stock_ds_test');
    Hive.init(tempDir.path);
    HiveInit.registerAdaptersForTest();
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  late Box<dynamic> box;
  late StockLocalDataSource ds;

  Stock stock(String symbol, {String name = 'X', Market market = Market.tw}) =>
      Stock(symbol: symbol, market: market, name: name);

  setUp(() async {
    box = await Hive.openBox<dynamic>('stocks_test_${DateTime.now().microsecondsSinceEpoch}');
    ds = StockLocalDataSource(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  test('put 後 get 拿回相同 stock', () async {
    await ds.put(stock('2330.TW', name: '台積電'));
    final got = await ds.get('2330.TW');
    expect(got, isA<Success<Stock, AppError>>());
    expect((got as Success<Stock, AppError>).value.name, '台積電');
  });

  test('get 不存在 symbol 回 NotFoundError', () async {
    final got = await ds.get('9999.TW');
    expect(got, isA<Failure<Stock, AppError>>());
    expect((got as Failure<Stock, AppError>).error, isA<NotFoundError>());
  });

  test('getAll 回 box 內全部 Stock', () async {
    await ds.put(stock('2330.TW'));
    await ds.put(stock('AAPL', market: Market.us));
    final r = await ds.getAll();
    expect((r as Success<List<Stock>, AppError>).value, hasLength(2));
  });

  test('delete 後 get 回 NotFoundError', () async {
    await ds.put(stock('2330.TW'));
    await ds.delete('2330.TW');
    expect((await ds.get('2330.TW')), isA<Failure<Stock, AppError>>());
  });

  test('watchAll 每次 box 變動 emit 當前完整列表', () async {
    final events = <List<Stock>>[];
    final sub = ds.watchAll().listen(events.add);

    await ds.put(stock('2330.TW'));
    await ds.put(stock('AAPL'));
    await ds.delete('2330.TW');

    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();

    expect(events.map((l) => l.length).toList(), [1, 2, 1]);
    expect(events.last.single.symbol, 'AAPL');
  });
}
