import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stock_calendar/data/models/calendar_doc.dart';
import 'package:stock_calendar/data/models/prediction.dart';
import 'package:stock_calendar/data/models/prediction_type.dart';
import 'package:stock_calendar/data/repositories/calendar_repository.dart';
import 'package:stock_calendar/features/calendar/viewmodel/calendar_view_model.dart';

class _MockRepo extends Mock implements CalendarRepository {}

CalendarDoc _doc({
  String symbol = '2330.TW',
  int year = 2026,
  int month = 6,
  List<Prediction> predictions = const [],
}) {
  final t = DateTime.utc(2026, 5, 1);
  return CalendarDoc(
    id: 'c-$symbol-$year-$month',
    userId: 'u1',
    symbol: symbol,
    year: year,
    month: month,
    title: '$symbol $year-$month',
    themeId: 'def',
    predictions: predictions,
    createdAt: t,
    updatedAt: t,
  );
}

void main() {
  late _MockRepo repo;
  late ProviderContainer container;

  ProviderContainer makeContainer() => ProviderContainer(overrides: [
        calendarRepositoryProvider.overrideWithValue(repo),
      ]);

  setUp(() {
    repo = _MockRepo();
    container = makeContainer();
  });

  tearDown(() => container.dispose());

  test('symbol == null → emits null without subscribing to repository',
      () async {
    // 不 stub repo.watch；任何呼叫都會炸（mocktail 預設）。
    final value = await container.read(calendarViewModelProvider.future);
    expect(value, isNull);
    verifyNever(() => repo.watch(
          symbol: any(named: 'symbol'),
          year: any(named: 'year'),
          month: any(named: 'month'),
        ));
  });

  test('with symbol → emits repository data', () async {
    final doc = _doc(symbol: '2330.TW', year: 2026, month: 6);
    when(() => repo.watch(
          symbol: '2330.TW',
          year: 2026,
          month: 6,
        )).thenAnswer((_) => Stream.value(doc));

    container.read(currentSymbolProvider.notifier).set('2330.TW');
    container.read(focusedMonthProvider.notifier).set(DateTime.utc(2026, 6, 1));

    final value = await container.read(calendarViewModelProvider.future);
    expect(value, equals(doc));
  });

  test('switching month → re-subscribes with new month', () async {
    final docJun = _doc(month: 6);
    final docJul = _doc(month: 7);
    when(() => repo.watch(symbol: '2330.TW', year: 2026, month: 6))
        .thenAnswer((_) => Stream.value(docJun));
    when(() => repo.watch(symbol: '2330.TW', year: 2026, month: 7))
        .thenAnswer((_) => Stream.value(docJul));

    container.read(currentSymbolProvider.notifier).set('2330.TW');
    container.read(focusedMonthProvider.notifier).set(DateTime.utc(2026, 6, 1));
    expect(await container.read(calendarViewModelProvider.future), docJun);

    container.read(focusedMonthProvider.notifier).set(DateTime.utc(2026, 7, 1));
    expect(await container.read(calendarViewModelProvider.future), docJul);

    verify(() => repo.watch(symbol: '2330.TW', year: 2026, month: 6)).called(1);
    verify(() => repo.watch(symbol: '2330.TW', year: 2026, month: 7)).called(1);
  });

  test('switching symbol → re-subscribes with new symbol', () async {
    when(() => repo.watch(symbol: '2330.TW', year: 2026, month: 6))
        .thenAnswer((_) => Stream.value(_doc(symbol: '2330.TW')));
    when(() => repo.watch(symbol: '0050.TW', year: 2026, month: 6))
        .thenAnswer((_) => Stream.value(_doc(symbol: '0050.TW')));

    container.read(focusedMonthProvider.notifier).set(DateTime.utc(2026, 6, 1));
    container.read(currentSymbolProvider.notifier).set('2330.TW');
    expect((await container.read(calendarViewModelProvider.future))?.symbol,
        '2330.TW');

    container.read(currentSymbolProvider.notifier).set('0050.TW');
    expect((await container.read(calendarViewModelProvider.future))?.symbol,
        '0050.TW');
  });

  test('switching symbol back to null → emits null', () async {
    when(() => repo.watch(symbol: '2330.TW', year: 2026, month: 6))
        .thenAnswer((_) => Stream.value(_doc()));
    container.read(focusedMonthProvider.notifier).set(DateTime.utc(2026, 6, 1));
    container.read(currentSymbolProvider.notifier).set('2330.TW');
    await container.read(calendarViewModelProvider.future);

    container.read(currentSymbolProvider.notifier).set(null);
    final value = await container.read(calendarViewModelProvider.future);
    expect(value, isNull);
  });

  test('predictionsByDay maps predictions by day-of-month', () {
    final p1 = Prediction(
      date: DateTime.utc(2026, 6, 5),
      type: PredictionType.bullish,
    );
    final p2 = Prediction(
      date: DateTime.utc(2026, 6, 20),
      type: PredictionType.bearish,
    );
    final doc = _doc(predictions: [p1, p2]);
    final map = predictionsByDay(doc);
    expect(map.length, 2);
    expect(map[5]?.type, PredictionType.bullish);
    expect(map[20]?.type, PredictionType.bearish);

    expect(predictionsByDay(null), isEmpty);
  });
}
