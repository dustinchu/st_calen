import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/app_settings.dart';
import '../../data/models/calendar_doc.dart';
import '../../data/models/market.dart';
import '../../data/models/prediction.dart';
import '../../data/models/prediction_type.dart';
import '../../data/models/quote.dart';
import '../../data/models/stock.dart';

/// Hive 初始化集中點。Adapter 註冊順序對齊 03-data-model.md 的 typeId 0~6。
class HiveInit {
  const HiveInit._();

  static Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();
  }

  /// 測試專用：跳過 `Hive.initFlutter()`（由測試自行 `Hive.init(tempDir)`），
  /// 僅註冊 adapter。重複呼叫安全（內部 idempotent guard）。
  static void registerAdaptersForTest() => _registerAdapters();

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(PredictionTypeAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(PredictionAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(MarketAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(StockAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(CalendarDocAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(QuoteAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(AppSettingsAdapter());
  }
}
