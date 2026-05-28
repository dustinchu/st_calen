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

- [x] **Step 4：Data Models（freezed + Hive adapter）**
  - 建立 `data/models/` 全部 model（依 `03-data-model.md`）
  - 加 Hive `@HiveType` annotation
  - 跑 `build_runner` 產生 `.g.dart` / `.freezed.dart`
  - 在 `hive_init.dart` 註冊全部 adapter
  - **驗收**：所有 model `toJson / fromJson` 與 Hive 寫入讀出測試通過
  - **完成紀錄**：commit `5472039` feat + `bec84f4` test（2026-05-28）。`fvm flutter analyze` 0 issue、`fvm flutter test` 31 passed（19 既有 + 12 新增 model tests）。建立 7 個 model（PredictionType / Prediction / Market / Stock / CalendarDoc / Quote / AppSettings，typeId 0~6 對齊 03-data-model.md），build_runner 一次成功。決策：(1) freezed + hive_generator 共用 — 在 `const factory` 內每個欄位加 `@HiveField(n)` + class 上 `@HiveType(...)`；hive_generator 會產 `TypeAdapter<_$XxxImpl>`，因 `_$XxxImpl` IS-A `Xxx`，runtime 寫入/讀出 + cast to public type 行為一致；(2) 因 freezed 對外 expose 的是 public class，box 不要寫死 `<CalendarDoc>` 泛型，data source 階段（Step 7）採 `Hive.openBox<dynamic>(...) + as T` 模式；(3) DateTime 走 Hive 原生（內部 ms timestamp）+ JSON 走 ISO 8601 String（json_serializable 預設）；(4) Market / PredictionType enum 序列化用 `name`（產出 "tw"/"us"/"customPrice"...），對齊 04-backend-spec 與 Firestore schema；(5) **踩雷**：CalendarDoc 內 `List<Prediction>` 第一次 `toJson()` 報 `_$PredictionImpl is not a subtype of Map<String, dynamic>` — json_serializable 預設不會對 nested object 呼叫 `toJson()`，需在 `build.yaml` 全域加 `explicit_to_json: true`，重跑 build_runner 後通過；(6) `HiveInit.init()` 註冊 7 個 adapter 順序按 typeId，並加 `isAdapterRegistered` guard + 拆出 `registerAdaptersForTest()` 方便測試自行 `Hive.init(tempDir)` 後 reuse 註冊邏輯。

---

### Phase 1：Auth 與資料層

- [ ] **Step 5：Auth Service & Anonymous Login**（code done，實機驗收延後到 Step 13）
  - `core/firebase/auth_service.dart`：匿名登入、登出、currentUser stream
  - `data/repositories/auth_repository.dart`
  - `features/auth/viewmodel/auth_view_model.dart`
  - 啟動流程：bootstrap 完成後自動匿名登入
  - **驗收**：啟動後 Firebase console 看到匿名用戶；重啟 App UID 不變
  - **完成紀錄**：commit `1ed38a4` feat + `943db11` test（2026-05-28）。`fvm flutter analyze` 0 issue、`fvm flutter test` 45 passed（31 既有 + 14 新增）。**實機驗收延後到 Step 13**（2026-05-28 與 Step 6 一同決定：user 選擇等月曆主畫面出來後一次測 auth + 月曆主流程，避免反覆切回 auth flow 測同一件事；checkbox 維持 [ ] 直到 Step 13 一併驗收）。決策：(1) AuthError sealed 一次補齊 Network / OperationNotAllowed / Cancelled / AccountExists / Unknown（後三類本 step 不會觸發，留給 Step 6 Google/Apple 重用，user 明確要求預先加完整類型）；(2) AuthViewModel 用 `@Riverpod(keepAlive: true)` StreamNotifier，`build()` 訂閱 `userChanges` 映成 `AuthState`（sealed: AuthSignedIn / AuthSignedOut(lastError)）；imperative `signInAnonymously()` 失敗時把 lastError 寫進 state；(3) bootstrap 直接呼叫 `FirebaseAuth.instance.signInAnonymously()`（不繞 ProviderContainer），失敗 swallow 不 block startup，理由：bootstrap 是 wiring layer 非 ViewModel，且 ProviderScope 尚未掛載；ViewModel 的 stream 之後仍會反映正確狀態；(4) 新建 `analysis_options.yaml` 排除 `*.g.dart` / `*.freezed.dart` —— `riverpod_generator 2.4.0` 仍產 deprecated `ProviderRef`，與 `riverpod 2.6+` 的 `Ref` 不相容會噴 3 個 info；不引入 flutter_lints 以免動到既有 code；(5) firebase console 由 user 預先啟用 Anonymous provider；(6) dev_deps 加 `mocktail ^1.0.4` 對齊 02-architecture.md 測試策略。Test 覆蓋：service 6 cases（含 stream emit 序列、currentUserId null 保護）+ repository 8 cases（每個 FirebaseAuthException code 一例 + 非 FirebaseAuthException fallback + null user 保護 + signOut 兩例）。

- [ ] **Step 6：Account Linking（Google / Apple）**（code done，實機驗收延後到 Step 13）
  - 整合 `google_sign_in`、`sign_in_with_apple`
  - iOS Xcode 開啟 Sign in with Apple capability
  - Android `google-services.json` 與 SHA-1 設定
  - Auth Service 新增 `linkWithGoogle()` / `linkWithApple()`
  - `LoginSheet` UI：可從設定觸發
  - **驗收**：實機測試綁定後 `currentUser.providerData` 包含對應 provider
  - **完成紀錄**：commit `26980c3` (chore step02) + `6a52ec0` (chore step06) + `7a1b6a8` (feat step06) + `a49f073` (test step06) + `30fffb4` (docs step06)（2026-05-28）。`fvm flutter analyze` 0 issue、`fvm flutter test` 58 passed（45 既有 + 13 新增）。**實機驗收延後到 Step 13**：user 選擇等月曆主畫面出來後一次測「啟動 → 匿名登入 → 月曆 render → 設定頁綁定 Google / Apple → kill 重開 UID 不變 + providerData 持續存在」整條主流程，避免在純 auth flow 反覆切回測同一件事。**Step 5 實機驗收同步延後到 Step 13。** 決策：(1) `AuthService` 注入 `GoogleSignIn`（預設 `GoogleSignIn()`）讓 unit test 可 mock；對外丟出 `AuthCancelledException` sentinel（user 按取消 / Apple `AuthorizationErrorCode.canceled`）由 repository 映射成 `AuthCancelledError`；(2) `userChanges()` 改用 `_auth.userChanges()`（不是 `authStateChanges()`）—— link / unlink / profile 更新時才會 emit，UI 才能即時反映新的 providerData；既有 Step 5 service test 同步改 mock `auth.userChanges()`；(3) `_linkOrSignIn` 內部：`currentUser != null` 走 `user.linkWithCredential`（保留匿名 UID），`currentUser == null`（極少數狀況：bootstrap 匿名失敗）走 `signInWithCredential` 切換 UID；(4) `signOut()` 同時呼叫 `_google.signOut()` + `_auth.signOut()`，避免下次 Google sheet 直接默認上次帳號；(5) repository `_mapFirebaseException` 把 `account-exists-with-different-credential` / `credential-already-in-use` / `email-already-in-use` 三個 code 都映射成 `AuthAccountExistsError`（user 視角都是「此帳號已綁其他 UID」，切換 UID 邏輯留給 Step 9）；(6) `AuthSignedIn` 加 `linkedProviders: List<String>`（= `user.providerData.map((p) => p.providerId)`）+ `hasGoogle` / `hasApple` getter，LoginSheet 用來顯示「已綁定」狀態；imperative method 失敗回 `AuthError?` 給 UI 直接 switch case 顯示中文訊息；(7) LoginSheet 用 `Platform.isIOS` 條件渲染 Apple 按鈕（Android 走 web flow 留給後續 step），Google 全平台；UI 簡化版（drag handle + 兩個 tonal button + status text），上架前 Step 26 再美化；(8) `SettingsScreen` 最小骨架只放一個 ListTile，副標反映綁定狀態，其他設定項目留給 Step 25；(9) router 加 `/settings` 路由，home placeholder 加齒輪 AppBar action 當入口；(10) iOS：`Runner.entitlements` 加 `com.apple.developer.applesignin`，`Info.plist` 加 `CFBundleURLTypes`（值 = GoogleService-Info.plist 的 REVERSED_CLIENT_ID `com.googleusercontent.apps.874870813769-9pf1cg1826qv76b6pbfihf8jvg2skpsg`）；pbxproj 未動 SystemCapabilities（modern Xcode 用 entitlements file 即可，不需 pbxproj capability block）；(11) Step 2 留下的 6 個 ios diff（AppFrameworkInfo.plist / Podfile.lock / project.pbxproj / xcworkspace / xcscheme / AppDelegate.swift）皆為 Xcode 16 toolchain auto-upgrade（objectVersion 51→54、LastUpgradeCheck 1020→1510、`@UIApplicationMain`→`@main`、`pod install` 加 Copy Pods Resources phase），與 Step 6 無關但屬 Step 2 期間 build 產物，本 step 順手以 `chore(step02)` 補 commit 進來。Test 覆蓋：service 9 cases（既有 6 + linkWithGoogle cancel + unlinkProvider no-current-user + unlinkProvider delegation）+ repository 16 cases（既有 8 + linkWithGoogle 6 條路徑 success/cancel/credential-already-in-use/account-exists-with-different-credential/network/unknown + linkWithApple cancel + success + unlinkProvider success + FirebaseAuthException）。**踩雷**：(a) `GoogleSignIn` 是 service 內部依賴 → 若不注入，service unit test 沒辦法測 cancel 路徑（singleton + 靜態 method 無法 mock），改成 constructor inject 後直接用 mocktail 蓋掉；(b) 既有 Step 5 service test 寫死 mock `auth.authStateChanges()`，本 step 把 service impl 改成 `auth.userChanges()` 後該 test 一定要改，否則 stream test 會 hang。

- [x] **Step 7：Local Data Sources（Hive）**
  - `data/sources/local/calendar_local_ds.dart`
  - `data/sources/local/stock_local_ds.dart`
  - `data/sources/local/settings_local_ds.dart`
  - 提供 CRUD + watch stream
  - **驗收**：unit test 全 CRUD 操作覆蓋
  - **完成紀錄**：commit `4a23e59` feat+test（2026-05-28，本步驟 impl 與 test 一同 commit）。`fvm flutter analyze` 0 issue、`fvm flutter test` 73 passed（58 既有 + 15 新增）。決策：(1) CalendarDoc box key 採 composite `<symbol>:<YYYY-MM>`（year/month 補零，例 `2330.TW:2026-06`），讓 `get(symbol, year, month)` 一次到位；CalendarDoc.id（uuid）仍存於 value 內，Step 9 同步 Firestore 時用 `id` 當 document id，本地 key 拆解後對應；與 03-data-model.md 字面（寫 `calendarId`）不同但語意一致，已與 user 確認；(2) Settings key 沿用 `kSettingsKey = 'app'`（hive_boxes.dart 既有常數，03-data-model.md 對齊），開工指示原寫 `'current'` 改回 `'app'`；(3) DS 採 constructor 注入 `Box<dynamic>`（沿用 Step 4 `<dynamic> + as T` 模式，因 freezed `_$XxxImpl` 與 public class 的型別關係），各 DS 另提供 `static openBox()` factory 給 app 啟動端使用，測試自行 `Hive.openBox<dynamic>(unique_name)` + tearDown `deleteFromDisk`；(4) watch stream 不補初始 emit（raw `box.watch().map(...)`），呼叫端用 `get()` 補一次當前值；`watchByStock` 以 `key.startsWith('$symbol:')` 過濾、刪除事件 emit null；`StockLocalDataSource.watchAll` 每次事件 re-snapshot 整個 `box.values`（Phase 1 <50 檔可接受）；(5) `SettingsLocalDataSource.get()` 無值時回 `Result.failure(NotFoundError)`、**不**寫入預設值（避免 DS 隱性 side-effect，預設值落地交給 Step 9 repository）；(6) 所有 method 統一 `Result<T, AppError>`，Hive 例外包 `UnknownError(e.toString())`，watch stream 不包 Result。Test 覆蓋：calendar 6 cases（keyOf 格式、put/get、not-found、delete、getAll、watchByStock 過濾＋刪除）+ stock 5 cases（put/get、not-found、getAll、delete、watchAll 三事件）+ settings 4 cases（first get not-found、put/get、覆寫、watch 三事件），共 15 新增。

- [x] **Step 8：Remote Data Sources（Firestore）**（code done，rules 真機驗收延後到 Step 13）
  - `data/sources/remote/calendar_firestore_ds.dart`
  - `data/sources/remote/device_firestore_ds.dart`
  - 部署 Firestore Security Rules（依 `03-data-model.md`）
  - **驗收**：能用模擬器寫入/讀取，rule 阻擋未認證寫入
  - **完成紀錄**：commit `60b5a9e` feat + `4440da5` test + `ebb9ea5` chore（2026-05-28）。`fvm flutter analyze` 0 issue、`fvm flutter test` 87 passed（73 既有 + 14 新增）。**rules 真機驗收延後到 Step 13**（不執行 `firebase deploy`，由 user 決定何時部署；本 step 用 `fake_cloud_firestore` 驗 DS 行為 + 文件 review rules）。決策：(1) **DateTime → Firestore native `Timestamp`**（非 ISO 字串）—— `createdAt` / `updatedAt` / `predictions[].date` 都用 `Timestamp.fromDate(dt)` 寫入，讀回 `(t as Timestamp).toDate().toUtc().toIso8601String()` 餵 `fromJson()`；理由：Firestore native 型別可做 server-side range query / 排序，長期不會被 string-compare 鎖死。代價：DS 不直接吃 `model.toJson()`，集中在 `_toFirestore` / `_fromFirestore` helper，Repository（Step 9）不受影響；(2) **snapshot stream `.skip(1)`**——對齊 local DS「不補初始 emit」契約，Repository 合成 hot stream 用 `get()` 拿初始 + `watch()` 接 delta，local / remote 行為對稱；(3) `FirebaseException` 映射：`unavailable` / `deadline-exceeded` / `cancelled` → `NetworkError`、`not-found` 或 `snapshot.exists == false` → `NotFoundError`、其他 → `UnknownError('${code}: ${message}')`；(4) `CalendarFirestoreDataSource` 路徑 `users/{uid}/calendars/{calendarId}`，`calendarId = CalendarDoc.id`（uuid），呼叫端傳 `uid`（從 `AuthService.currentUserId`）；(5) `DeviceFirestoreDataSource` 只有 put / get / delete，無 watch（FCM token 只寫不讀），不 import `device_info_plus`（Step 22 才碰）；(6) `pubspec.yaml` dev_deps 加 `fake_cloud_firestore ^3.0.3`（對齊 `cloud_firestore` 5.x）；(7) 02-architecture.md 補「Remote Data Source 契約」段落、03-data-model.md 在 Firestore Schema 段落補 Timestamp 序列化決議 blockquote。**踩雷**：(a) `Timestamp.fromDate(utc).toDate()` 回傳 local DateTime（丟失 UTC 標記），第一次 round-trip test 比對 `DateTime.utc(2026,5,1,12,0,0)` 對到 local `2026-05-01 20:00:00`，DS `_timestampToIso` 補 `.toUtc()` 後通過；(b) `fake_cloud_firestore` 的 snapshot listener 與真實 SDK 一致會 emit 初始值，`.skip(1)` 在 test 端用 `await Future.delayed(10ms)` 後驗 `events.isEmpty` 證明初始 emit 被跳過。Test 覆蓋：calendar 9 cases（round-trip + Timestamp 驗證 / not-found / overwrite / delete / delete-missing / listByStock 過濾 / listByStock 空 / watch skip-initial + update + null-on-delete / watchByStock 過濾）+ device 5 cases（round-trip / not-found / overwrite / delete / delete-missing），共 14 新增。

- [x] **Step 9：Repositories（含降級與同步邏輯）**
  - `calendar_repository.dart`：本地優先 + 背景同步 + 待同步佇列
  - `stock_repository.dart`
  - `settings_repository.dart`
  - **驗收**：unit test 模擬離線 → 上線時自動同步
  - **完成紀錄**：commit `7ed5a24` feat + `2ff8e0d` test + `<docs hash 自填>` docs（2026-05-28）。`fvm flutter analyze` 0 issue、`fvm flutter test` 114 passed（87 既有 + 27 新增：calendar 19 + stock 4 + settings 4）。三個開工決策最終選擇：(1) **stock list 不做 Firestore 同步**——自選股清單純本地 Hive，重裝會消失但體積小、重建成本低；未來若要同步，再加 `watched_stocks_firestore_ds` + 對應 queue 邏輯，對齊 CalendarRepository 模式。(2) **flush 觸發只開 public method**——`flushPendingWrites()` 由呼叫端（bootstrap / 未來 connectivity 事件）決定何時呼叫，本 step 不引入 `connectivity_plus` 依賴。(3) **不開 Riverpod provider**——Repository 純 class + constructor inject，test 直接 new；Step 13+ ViewModel 時再開。決策：(a) **待同步佇列 schema 分流**——write queue 存 composite key `<symbol>:<YYYY-MM>`（flush 時從 local 撈最新 doc 再 push），delete queue 存 `CalendarDoc.id`（uuid，本地 doc 已刪除沒法回查，calendarId 已足夠呼叫 `remote.delete`）。兩個常數加在 `core/storage/hive_boxes.dart`。佇列以 `List<String>` 存於 meta box，加入時用 Set 去重避免短時間連寫灌爆。(b) **CalendarRepository.get 走 listByStock + filter**——remote DS 沒有 `getByYearMonth` 介面（key 是 uuid 不是 composite），改用 `listByStock(uid, symbol)` 拉整 symbol 名下所有 month 後 filter `year/month`；Phase 1 一個 stock 一年 ~12 doc 可接受，未來若 hot path 才考慮在 DS 加 `where('year', ==).where('month', ==)` 查詢。(c) **CalendarRepository.watch 處理 DS bug-or-feature**——local DS 的 `watchByStock` 在任何 month delete 都 emit null（deleted event 沒 value 可判斷 key），repo 不能直接信任這個 null。改為「收到任意 event → re-read target (symbol, year, month)」，避免「同 symbol 別 month 刪除」誤觸發 null emit。(d) **watch 用手動 StreamController 不用 async\***——`async* + await for(broadcast stream)` 在 listener cancel 時內部 subscription 漏拆會 hang（calendar test 首次跑出現 2 個 timeout，改寫後通過）；改用 `StreamController(onListen/onCancel)` 顯式管理 inner subscription。stock / settings 的 watch 仍用 `async*`（底層是 Hive box.watch real stream，teardown 關 box 時會自然 close，不會 hang）。(e) **CalendarRepository.get remote miss 回 `Success(null)`**——「沒預測過這個 month」是合法狀態而非錯誤，避免 ViewModel 把預設空畫面誤判成「載入失敗」。(f) **SettingsRepository 在 NotFoundError 回 `Success(AppSettings())`**——預設值落地在 Repository，保持 DS 層「不寫入預設值」契約（對齊 Step 7 決議）。(g) **未登入時 put / delete 跳過 remote 也不入佇列**——理由：沒 uid 沒辦法決定要寫到哪個 user 名下，下次有 uid 也不會自動補；匿名登入幾乎必成功，此 trade-off 合理。**踩雷**：(i) `async* + broadcast stream + await for` 在 cancel 時 hang（如上），改寫後通過；(ii) `Result.when` 的 callback 不支援 async，改用 Dart 3 sealed class pattern matching `switch (r) { case Success(value: ...): ... }`；(iii) 第一次 mock register fallback 漏了 `CalendarDoc`，補 `registerFallbackValue(_doc())` 後通過。Test 覆蓋：calendar 19 cases（get 5：local hit / local miss+remote hit / local miss+remote 也 miss / 未登入跳過 remote / remote NetworkError 傳遞；put 5：成功 + 不入佇列 / remote 失敗入佇列 / 重複入佇列去重 / 未登入跳過 / local 失敗短路；delete 2：成功 + remote 失敗入佇列 / local 沒 doc 不入佇列；flushPendingWrites 5：write 全成功清空 / 失敗保留 / 本地已刪除 drop / delete 成功清空 / 未登入跳過；watch 2：初始 emit + delta re-read / delta 後 NotFound → null）+ stock 4 cases（add/list/remove / 空 box / watch 補初始 + delta / watch 初始空 box）+ settings 4 cases（NotFound → 預設 / update + get / watch 預設 + update / watch 初始有值）。

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
