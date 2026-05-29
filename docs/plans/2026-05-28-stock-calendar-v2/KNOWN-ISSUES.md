# Known Issues / 待補（v2 refactor）

實機驗收延後期間累積的待注意事項。動手修前先確認與當前 step 的關聯，**無關項目單獨 commit**。

---

## 🔴 KI-1：`kSettingsBox` 啟動時未 `openBox`（真機會 crash）

- **發現**：Step 21（2026-05-29）
- **狀態**：✅ 已修（Step 25 開工 fix commit，2026-05-29；hash 見 `06-steps.md` Step 25 完成紀錄）— bootstrap 在 stocks box 後補 `await Hive.openBox<dynamic>(kSettingsBox)`，對齊既有 meta/calendar/stocks 開法。
- **症狀**：`kSettingsBox`（Hive `'settings'` box）在 `lib/app/bootstrap.dart` 啟動序列中從未被開啟——bootstrap 只 `openBox` meta / calendar / stocks 三個。但 `settingsLocalDataSourceProvider`（`lib/features/settings/viewmodel/settings_view_model.dart:15`）以**同步** `Hive.box<dynamic>(kSettingsBox)` 取 box。真機啟動 `MyApp` build 讀 `settingsViewModelProvider` 時會 throw `HiveError: Box not found`。
- **為何單元測試抓不到**：各測試自行 `Hive.openBox` 臨時 box；所有 step 的實機驗收皆延後（`06-steps.md` Step 5~21 全 `[ ]`）。
- **修法**：`bootstrap.dart` 在 `_ensureSignedIn()` 後加
  ```dart
  await Hive.openBox<dynamic>(kSettingsBox);
  ```
  對齊既有 meta/calendar/stocks 開法。
- **時機**：任何實機驗收 / Step 25（Settings 頁完成）**之前**必須先補。單獨 commit（例：`fix: open kSettingsBox in bootstrap`）。

---

## 🟡 KI-2：通知首次啟動不自動排程（預設 ON 需 toggle 一次）

- **發現**：Step 21（2026-05-29）
- **狀態**：✅ 已修（Step 25 開工 fix commit，2026-05-29，與 KI-1 同一 commit；hash 見 `06-steps.md` Step 25 完成紀錄）— bootstrap 在 `notificationService.init()` 後讀持久 `AppSettings.notificationsEnabled`（缺值預設 `true`），為 `true` 即 `applyEnabled(true)` 重排。`applyEnabled` 內 `cancelAll` + 同 id `zonedSchedule` 覆蓋，idempotent。
- **症狀**：`notificationsEnabled` 預設 `true`，但每日提醒只在使用者於設定頁 **toggle 開關**時（`SettingsController.setNotificationsEnabled` → `applyEnabled`）才排程。從未 toggle 的預設使用者收不到 14:30 提醒。
- **依賴**：完整修法需在啟動時讀持久設定來排程，受 **KI-1** 阻擋（bootstrap 讀 settings 會 crash）。
- **修法（KI-1 修好後）**：bootstrap 讀 `AppSettings.notificationsEnabled`，若 `true` 呼叫 `notificationService.applyEnabled(true)` 重排（`zonedSchedule` 同 id 覆蓋，idempotent）。
- **時機**：與 KI-1 一起處理，或併入 Step 25。

---

## 🟡 KI-3：每日提醒不跳國定假日

- **發現**：Step 21（2026-05-29）
- **狀態**：Phase 1 簡化（決策4）
- **症狀**：排程為週一~週五 14:30 週重複；台股國定假日仍會誤報提醒。
- **修法**：需交易日曆（trading calendar）；純 local schedule 無法跳假日。留 Phase 2 或交易日曆功能引入後處理。
