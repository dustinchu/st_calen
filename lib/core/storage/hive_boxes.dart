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

/// meta box 內待同步佇列 key（Step 9）。
///
/// - writes：`List<String>`，每筆是 calendar 的 composite key `<symbol>:<YYYY-MM>`。
///   flush 時依此 key 從 local box 撈最新 doc，再 push 到 Firestore。
/// - deletes：`List<String>`，每筆是 [CalendarDoc.id]（uuid）。本地 doc 已被刪除，
///   只需 calendarId 即可呼叫 remote DS 的 delete。
const String kPendingCalendarWritesKey = 'pending_calendar_writes';
const String kPendingCalendarDeletesKey = 'pending_calendar_deletes';
