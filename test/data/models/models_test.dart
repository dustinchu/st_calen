import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stock_calendar/core/storage/hive_init.dart';
import 'package:stock_calendar/data/models/app_settings.dart';
import 'package:stock_calendar/data/models/calendar_doc.dart';
import 'package:stock_calendar/data/models/market.dart';
import 'package:stock_calendar/data/models/prediction.dart';
import 'package:stock_calendar/data/models/prediction_type.dart';
import 'package:stock_calendar/data/models/quote.dart';
import 'package:stock_calendar/data/models/stock.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('hive_models_test');
    Hive.init(tempDir.path);
    HiveInit.registerAdaptersForTest();
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  Future<T> hiveRoundTrip<T>(String boxName, T value) async {
    final box = await Hive.openBox<dynamic>(boxName);
    await box.put('k', value);
    await box.close();
    final reopened = await Hive.openBox<dynamic>(boxName);
    final read = reopened.get('k') as T;
    await reopened.close();
    return read;
  }

  group('Prediction', () {
    final sample = Prediction(
      date: DateTime.utc(2026, 6, 1),
      type: PredictionType.customPrice,
      price: 600.5,
      note: '法說會前一天',
      settled: true,
      actualClose: 605.0,
      hitPercent: -0.74,
    );

    test('json round-trip', () {
      expect(Prediction.fromJson(sample.toJson()), equals(sample));
    });

    test('hive round-trip', () async {
      expect(await hiveRoundTrip('predictions_box', sample), equals(sample));
    });

    test('json enum value is name', () {
      expect(sample.toJson()['type'], 'customPrice');
    });
  });

  group('Stock', () {
    final sample = Stock(
      symbol: '2330.TW',
      market: Market.tw,
      name: '台積電',
      sector: '半導體',
    );

    test('json round-trip', () {
      expect(Stock.fromJson(sample.toJson()), equals(sample));
      expect(sample.toJson()['market'], 'tw');
    });

    test('hive round-trip', () async {
      expect(await hiveRoundTrip('stocks_box', sample), equals(sample));
    });
  });

  group('CalendarDoc', () {
    final sample = CalendarDoc(
      id: 'cal-1',
      userId: 'uid-1',
      symbol: '2330.TW',
      year: 2026,
      month: 6,
      title: '台積電 6 月預測',
      themeId: 'def',
      predictions: [
        Prediction(
          date: DateTime.utc(2026, 6, 2),
          type: PredictionType.upLimit,
        ),
        Prediction(
          date: DateTime.utc(2026, 6, 3),
          type: PredictionType.bearish,
          note: '除息',
        ),
      ],
      createdAt: DateTime.utc(2026, 5, 28, 10),
      updatedAt: DateTime.utc(2026, 5, 28, 11),
    );

    test('json round-trip', () {
      expect(CalendarDoc.fromJson(sample.toJson()), equals(sample));
    });

    test('hive round-trip (含 List<Prediction>)', () async {
      expect(await hiveRoundTrip('calendars_box', sample), equals(sample));
    });
  });

  group('Quote', () {
    final sample = Quote(
      symbol: '2330.TW',
      date: DateTime.utc(2026, 6, 1),
      close: 605.0,
      open: 600.0,
      high: 608.0,
      low: 598.0,
      changePercent: 0.83,
    );

    test('json round-trip', () {
      expect(Quote.fromJson(sample.toJson()), equals(sample));
    });

    test('hive round-trip', () async {
      expect(await hiveRoundTrip('quotes_box', sample), equals(sample));
    });
  });

  group('AppSettings', () {
    test('defaults', () {
      const settings = AppSettings();
      expect(settings.themeId, 'def');
      expect(settings.notificationsEnabled, true);
      expect(settings.autoSettleEnabled, true);
      expect(settings.lastSelectedSymbol, isNull);
    });

    test('json round-trip', () {
      const sample = AppSettings(
        themeId: 'dark',
        notificationsEnabled: false,
        autoSettleEnabled: true,
        lastSelectedSymbol: 'AAPL',
      );
      expect(AppSettings.fromJson(sample.toJson()), equals(sample));
    });

    test('hive round-trip', () async {
      const sample = AppSettings(themeId: 'dark', lastSelectedSymbol: 'AAPL');
      expect(await hiveRoundTrip('settings_box', sample), equals(sample));
    });
  });
}
