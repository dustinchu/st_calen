import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stock_calendar/core/storage/hive_init.dart';
import 'package:stock_calendar/core/utils/result.dart';
import 'package:stock_calendar/data/models/market.dart';
import 'package:stock_calendar/data/models/stock.dart';
import 'package:stock_calendar/data/repositories/stock_repository.dart';
import 'package:stock_calendar/data/sources/local/stock_local_ds.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('stock_repo_test');
    Hive.init(tempDir.path);
    HiveInit.registerAdaptersForTest();
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  late Box<dynamic> box;
  late StockLocalDataSource ds;
  late StockRepository repo;

  Stock stock(String s) =>
      Stock(symbol: s, market: Market.tw, name: s);

  setUp(() async {
    box = await Hive.openBox<dynamic>(
        'stocks_repo_test_${DateTime.now().microsecondsSinceEpoch}');
    ds = StockLocalDataSource(box);
    repo = StockRepository(local: ds);
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  test('add / list / remove 完整路徑', () async {
    await repo.add(stock('2330.TW'));
    await repo.add(stock('2317.TW'));
    final list1 = await repo.list();
    expect((list1 as Success<List<Stock>, AppError>).value, hasLength(2));

    await repo.remove('2330.TW');
    final list2 = await repo.list();
    expect((list2 as Success<List<Stock>, AppError>).value, hasLength(1));
    expect(list2.value.first.symbol, '2317.TW');
  });

  test('list 空 box → Success([])', () async {
    final r = await repo.list();
    expect((r as Success<List<Stock>, AppError>).value, isEmpty);
  });

  test('watch 補初始 emit 後再接 local 變動', () async {
    await repo.add(stock('2330.TW'));

    final events = <List<Stock>>[];
    final sub = repo.watch().listen(events.add);

    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(events, hasLength(1));
    expect(events.first.map((s) => s.symbol), ['2330.TW']);

    await repo.add(stock('2317.TW'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(events, hasLength(2));
    expect(events.last.map((s) => s.symbol), containsAll(['2330.TW', '2317.TW']));

    await sub.cancel();
  });

  test('watch 初始時 box 為空 → 先 emit []', () async {
    final events = <List<Stock>>[];
    final sub = repo.watch().listen(events.add);

    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(events, hasLength(1));
    expect(events.first, isEmpty);

    await sub.cancel();
  });
}
