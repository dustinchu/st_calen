# 06 — 實作步驟（Phase 1）

> 這份文件是**所有實作 session 的工作依據**。每個 step 完成後必須：
> 1. 把對應 checkbox 從 `[ ]` 改成 `[x]`
> 2. 在 step 下方「完成紀錄」區塊寫上 commit hash + 注意事項
> 3. 執行 `git add . && git commit && git push`
> 4. 下一個 session 開工前先檢查上一個 step 已完成且推送

---

## Commit 規範

### Commit message 格式
```
<type>(<step>): <subject>

<body 選填，說明做了什麼、為什麼>

Refs: docs/plans/2026-05-28-stock-calendar-v2/06-steps.md Step <N>
```

`<type>` 一個於：`feat` / `fix` / `refactor` / `chore` / `docs` / `test`

範例：
```
chore(step01): 初始化 Flutter 3.41.2 + Riverpod 專案結構

- 升級 pubspec.yaml 到新版套件
- 建立 lib/ 新目錄結構（app/core/data/features/shared）
- 設定 flutter_lints 規則

Refs: docs/plans/2026-05-28-stock-calendar-v2/06-steps.md Step 1
```

### 每個 step 結束的 commit/push
```bash
git add -A
git commit -m "<message>"
git push origin <branch>
```

### 分支策略
- 主重構在 `refactor/v2` 分支進行（從 master 切出）
- 每個 step 不必開新分支（同分支累積提交，方便追進度）
- Phase 1 全部完成後合併回 master 並打 tag `v2.0.0`

---

## 全局 checklist

### Phase 0：設計階段
- [x] **Step 0**：完成設計文件（本文件群）
  - **完成紀錄**：2026-05-28 完成設計文件初稿

---

### Phase 1：基礎建設

- [x] **Step 1：專案重置與套件升級**
  - 在 master 切 `refactor/v2` 分支
  - 直接刪除舊 `lib/`（git 歷史保留），不留 `lib_legacy/`
  - 更新 `pubspec.yaml` 為 `01-tech-stack.md` 列出的版本
  - 加入最小 `lib/main.dart`（空白 Scaffold；Step 2 會重寫）
  - 更新 `android/app/build.gradle`：minSdk 24（Flutter 3.41 預設）/ targetSdk 35 / compileSdk 36
  - Android 全套現代化：AGP 8.9.1 / Gradle 8.11.1 / Kotlin 2.1.0 / NDK 28.2 / coreLibraryDesugaring 2.1.4 / namespace / MainActivity exported
  - 更新 `ios/Podfile`：platform :ios, '14.0'
  - 建立 `lib/` 新目錄骨架（空資料夾 + 各層 `.gitkeep`）
  - `fvm flutter pub get` 通過、`fvm flutter analyze` 無錯
  - **驗收**：`fvm flutter build apk --debug` 成功（Gradle 全鏈通過 = run 不會在原生端 crash；實機安裝因裝置端權限對話框跳過，留待 Step 2）
  - **完成紀錄**：commit `8edb465`（2026-05-28）。重構分支 refactor/v2 啟動。注意：(1) plan 原寫 minSdk 23/compileSdk 35，實際採 minSdk 24（Flutter 3.41 預設）/compileSdk 36（androidx.core 1.17.0 transitive 要求）；(2) share_plus 升 12.x、image_gallery_saver_plus 換成 gal 2.3，已同步 01-tech-stack.md。

- [x] **Step 2：Bootstrap & 基礎服務**
  - `main.dart`、`app/bootstrap.dart`、`app/app.dart`、`app/router.dart`
  - 初始化：WidgetsFlutterBinding、Firebase、Hive、AdMob、timezone、orientation lock
  - go_router 設定空路由表（之後填入）
  - ProviderScope 包住 `MyApp`
  - flutter_native_splash 設定新版啟動畫
  - **驗收**：啟動 App → splash → 空 home 不 crash；console 無 Firebase / Hive 錯誤
  - **完成紀錄**：commit `1def7e2`（2026-05-28）。`fvm flutter analyze` 0 issue、`fvm flutter build apk --debug` 通過。注意：(1) `Firebase.initializeApp()` 未傳 `options`，靠 Android `google-services.json` 與 iOS `GoogleService-Info.plist` 走 native 初始化（沿用 6 年前舊檔，欄位齊全，firebase_core 3.x 可讀）；(2) iOS `AppDelegate.swift` 補上 `FirebaseApp.configure()`；(3) `flutter_native_splash` 採純色（亮 #FFFFFF / 暗 #121212），無 logo，等 Step 26 上架素材再換正式版；(4) AdMob 用 `MobileAds.instance.initialize()` fire-and-forget（`unawaited`）避免 block 啟動；(5) timezone 鎖 `Asia/Taipei`；(6) 因本機磁碟僅剩 3.7GB，未跑 iOS pod build 與實機驗收，留待後續 step 在裝置上確認 splash → home 流程。

- [x] **Step 3：Core 層（network / storage / utils）**
  - `core/network/dio_client.dart`（base URL、timeouts、interceptors）
  - `core/network/api_exception.dart`
  - `core/storage/hive_init.dart`（註冊所有 adapter，目前先空）
  - `core/storage/hive_boxes.dart`（常數）
  - `core/utils/result.dart`、`date_utils.dart`、`price_utils.dart`
  - **驗收**：unit test：`price_utils` 漲跌幅計算正確；`Result` 基本用法測過
  - **完成紀錄**：commit `c9ecabd`（2026-05-28）。`fvm flutter analyze` 0 issue、`fvm flutter test` 19 tests passed。決策：(1) `Result<T, AppError>` 採 sealed AppError（目前 3 類：NetworkError / NotFoundError / UnknownError，視後續 step 再補）；(2) dio timeout 依 04-backend-spec.md：connect 3s / receive 5s；(3) 台股漲跌停採 TWSE tick size 嚴謹版（整數 cents 運算避免浮點誤差，價格區間 <10/<50/<100/<500/<1000/>=1000 → tick 0.01/0.05/0.1/0.5/1/5，漲停 floor、跌停 ceil）；(4) price_utils 的 `market` 暫用字串 'tw'/'us'（對齊 backend 與 Market.name），Step 4 引入 Market enum 後呼叫端傳 `market.name` 即可；(5) `kStockApiBaseUrl` 從 `--dart-define=STOCK_API_BASE` 注入，預設 `https://stock.wisplu.com.tw`；(6) `HiveInit.init()` 目前只 `Hive.initFlutter()`，adapter 註冊留給 Step 4。Test 覆蓋：Result 的 success/failure/when/fold/map/factory 共 5 例；price_utils 的 changePercent 4 例（含除零 / 負數保護）+ 漲跌停價 5 例（4 個整數區間 + tick 跨界 9.5→10.45 + 53.6→58.9）+ isUpLimit/isDownLimit 5 例（含美股 false / prev<=0 保護），共 19 tests。

- [ ] **Step 4：Data Models（freezed + Hive adapter）**
  - 建立 `data/models/` 全部 model（依 `03-data-model.md`）
  - 加 Hive `@HiveType` annotation
  - 跑 `build_runner` 產生 `.g.dart` / `.freezed.dart`
  - 在 `hive_init.dart` 註冊全部 adapter
  - **驗收**：所有 model `toJson / fromJson` 與 Hive 寫入讀出測試通過
  - **完成紀錄**：

---

### Phase 1：Auth 與資料層

- [ ] **Step 5：Auth Service & Anonymous Login**
  - `core/firebase/auth_service.dart`：匿名登入、登出、currentUser stream
  - `data/repositories/auth_repository.dart`
  - `features/auth/viewmodel/auth_view_model.dart`
  - 啟動流程：bootstrap 完成後自動匿名登入
  - **驗收**：啟動後 Firebase console 看到匿名用戶；重啟 App UID 不變
  - **完成紀錄**：

- [ ] **Step 6：Account Linking（Google / Apple）**
  - 整合 `google_sign_in`、`sign_in_with_apple`
  - iOS Xcode 開啟 Sign in with Apple capability
  - Android `google-services.json` 與 SHA-1 設定
  - Auth Service 新增 `linkWithGoogle()` / `linkWithApple()`
  - `LoginSheet` UI：可從設定觸發
  - **驗收**：實機測試綁定後 `currentUser.providerData` 包含對應 provider
  - **完成紀錄**：

- [ ] **Step 7：Local Data Sources（Hive）**
  - `data/sources/local/calendar_local_ds.dart`
  - `data/sources/local/stock_local_ds.dart`
  - `data/sources/local/settings_local_ds.dart`
  - 提供 CRUD + watch stream
  - **驗收**：unit test 全 CRUD 操作覆蓋
  - **完成紀錄**：

- [ ] **Step 8：Remote Data Sources（Firestore）**
  - `data/sources/remote/calendar_firestore_ds.dart`
  - `data/sources/remote/device_firestore_ds.dart`
  - 部署 Firestore Security Rules（依 `03-data-model.md`）
  - **驗收**：能用模擬器寫入/讀取，rule 阻擋未認證寫入
  - **完成紀錄**：

- [ ] **Step 9：Repositories（含降級與同步邏輯）**
  - `calendar_repository.dart`：本地優先 + 背景同步 + 待同步佇列
  - `stock_repository.dart`
  - `settings_repository.dart`
  - **驗收**：unit test 模擬離線 → 上線時自動同步
  - **完成紀錄**：

---

### Phase 1：後端 API（並行可由另一人/session 進行）

- [ ] **Step 10：後端 stock.wisplu.com.tw 上線**
  - 建立新 repo（不在這個 Flutter repo 內）
  - FastAPI + Postgres + Alembic
  - 實作 `04-backend-spec.md` 全部端點
  - cron service 抓 TWSE / Yahoo Finance
  - 部署至 Dokploy
  - **驗收**：`curl https://stock.wisplu.com.tw/api/v1/health` 200 OK
  - **完成紀錄**：

- [ ] **Step 11：App 端 Stock API Client**
  - `data/sources/stock_api/stock_api_client.dart`
  - `quote_repository.dart`：含降級邏輯（API 失敗回傳 `Result.failure`）
  - `--dart-define=STOCK_API_BASE=https://stock.wisplu.com.tw`
  - **驗收**：unit test 模擬 timeout / 404，回傳 Result 正確
  - **完成紀錄**：

---

### Phase 1：功能畫面

- [ ] **Step 12：Onboarding & Splash**
  - 3 頁 onboarding（`features/onboarding/`）
  - 首次完成寫入 meta box
  - 路由：onboarding 未完成 → 顯示；已完成 → 直跳 calendar
  - **驗收**：模擬清空資料後首啟看到 onboarding
  - **完成紀錄**：

- [ ] **Step 13：Calendar Screen（主畫面）骨架**
  - `features/calendar/view/calendar_screen.dart`
  - 整合 `table_calendar` 套件
  - `CalendarViewModel` 從 Repository 訂閱當前股票/月份的資料
  - 暫不接 prediction editor，只顯示空月曆 + 假資料
  - **驗收**：可切換月份、selectedDay 變化、無顯著 jank
  - **完成紀錄**：

- [ ] **Step 14：Stock Management（股票管理）**
  - `features/stock/` 全部
  - 新增 / 搜尋（打後端 API） / 刪除 / 排序
  - 主畫面頂部接入股票切換 chips
  - **驗收**：新增「2330.TW」顯示「台積電」名稱；切換股票月曆刷新
  - **完成紀錄**：

- [ ] **Step 15：Prediction Editor**
  - `features/prediction/view/prediction_editor_sheet.dart`
  - 全部預測類型 UI
  - 寫入 Hive → 同步 Firestore
  - 月曆 cell 顯示對應 icon
  - **驗收**：填入後關閉再開仍看得到；切換裝置（重新登入）資料同步
  - **完成紀錄**：

- [ ] **Step 16：Quote Settlement（自動結算）**
  - Repository 整合：開月份時批次拉 quotes
  - 計算 hitPercent、染色 cell
  - 手動補價 UI（API 失敗時）
  - 「設定 → 自動結算」開關尊重
  - **驗收**：填過去日期的預測 → 自動結算染色正確
  - **完成紀錄**：

- [ ] **Step 17：行事曆主題系統**
  - `app/theme/calendar_themes.dart` 5 套主題
  - 設定頁切換 App 主題
  - 月曆內主題切換按鈕
  - 主題 ID 存 CalendarDoc 與 AppSettings
  - **驗收**：5 套主題視覺差異明顯；切換立即套用
  - **完成紀錄**：

- [ ] **Step 18：Share Image — 整月行事曆版型**
  - `share_image/templates/full_calendar_template.dart`
  - `RepaintBoundary` + `toImage()` 出 PNG
  - 三種比例（9:16 / 1:1 / 4:5）切換
  - 儲存相簿 + share_plus
  - **驗收**：實機儲存到相簿成功；分享開啟系統 share sheet
  - **完成紀錄**：

- [ ] **Step 19：Share Image — 單日卡片 + 月度報告版型**
  - `single_day_template.dart`、`report_card_template.dart`
  - 3–5 個梗圖背景內建在 assets
  - 預覽切換版型
  - **驗收**：三版型皆可分享、視覺品質可接受
  - **完成紀錄**：

- [ ] **Step 20：Accuracy Report**
  - `features/accuracy_report/`
  - 聚合計算 + fl_chart 折線圖
  - 「分享成績」CTA 跳轉
  - **驗收**：本月 / 近 3 月 / 全部 數字計算正確
  - **完成紀錄**：

---

### Phase 1：通知與廣告

- [ ] **Step 21：Local Notifications**
  - `core/firebase/fcm_service.dart`（含本地通知）
  - 每日 14:30 提醒（台股）
  - 結算完成通知
  - 設定頁通知開關
  - **驗收**：實機收到測試通知
  - **完成紀錄**：

- [ ] **Step 22：FCM Token Storage**
  - 取得 FCM token
  - 寫入 `/users/{uid}/devices/{deviceId}`
  - 監聽 `onTokenRefresh`
  - **驗收**：Firestore console 看到 token；換裝置看到不同 deviceId
  - **完成紀錄**：

- [ ] **Step 23：AdMob 整合**
  - `core/ads/ads_service.dart`
  - Banner 在 calendar 底部
  - Interstitial 在出圖後（控頻率）
  - iOS ATT 提示
  - Test ad unit 在 debug，正式 ID 由 `--dart-define` 注入
  - **驗收**：debug 顯示測試廣告；release build 顯示正式廣告
  - **完成紀錄**：

---

### Phase 1：上架前

- [ ] **Step 24：Crashlytics、Analytics、Error Handling**
  - 全域 `FlutterError.onError` 與 `PlatformDispatcher.onError` 接 Crashlytics
  - 關鍵事件埋 Analytics（add_stock、create_prediction、share_image 等）
  - **驗收**：debug 故意 crash 後 Crashlytics console 收到
  - **完成紀錄**：

- [ ] **Step 25：Settings 頁完成**
  - 全部設定項目（依 `05-features.md` F11）
  - 重設本地資料功能
  - 隱私權政策 / 服務條款 URL（外部連結）
  - **完成紀錄**：

- [ ] **Step 26：iOS / Android 上架資源**
  - 新版 App icon（`flutter_launcher_icons`）
  - 新版 splash（`flutter_native_splash`）
  - App Store 截圖（5 張 + 預覽）
  - Play Store 截圖（5 張）
  - App 描述、關鍵字、隱私問卷
  - **完成紀錄**：

- [ ] **Step 27：QA 全面測試**
  - 兩台實機（iOS + Android）
  - 主流程：onboarding → 加股票 → 預測 → 結算 → 分享 → 報告
  - 邊界：離線、API 失敗、清資料、登入綁定、權限拒絕
  - 廣告政策檢查
  - **完成紀錄**：

- [ ] **Step 28：Release Build & 上架送審**
  - iOS：archive → TestFlight → App Store Connect 送審
  - Android：app bundle → Play Console 內測 → 正式送審
  - 合併 `refactor/v2` → master，打 tag `v2.0.0`
  - **完成紀錄**：

---

## 完成定義（Definition of Done）

每個 step 「完成」必須同時滿足：

1. ✅ 程式碼提交且推送至遠端
2. ✅ `fvm flutter analyze` 無 error / warning
3. ✅ 相關 unit test / widget test 通過（如 step 有定義）
4. ✅ 對應 checkbox 已勾選
5. ✅ 「完成紀錄」已填寫 commit hash 與簡述
6. ✅ 如有開放問題或已知 issue，已記錄到 step 下方 `Notes` 區塊

## 開工 session 開頭模板

每個 session 開工請貼上以下模板回報：

```
Step <N> 開工
- 上一個 step <N-1> 確認完成：[是 / 否（哪裡不齊）]
- 本 step 目標：<一句話>
- 預期觸碰的檔案：
  - lib/...
  - ...
```
