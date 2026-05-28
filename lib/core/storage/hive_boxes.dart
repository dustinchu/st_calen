/// Hive box 名稱常數。對齊 03-data-model.md 的 box 設計。
///
/// 實際的 `Hive.openBox<T>(...)` 由各 data source 自行呼叫，
/// 這裡只集中常數避免 typo。
const String kCalendarsBox = 'calendars';
const String kStocksBox = 'stocks';
const String kQuotesBox = 'quotes';
const String kSettingsBox = 'settings';
const String kMetaBox = 'meta';

/// settings box 內存 AppSettings 的 key。
const String kSettingsKey = 'app';
