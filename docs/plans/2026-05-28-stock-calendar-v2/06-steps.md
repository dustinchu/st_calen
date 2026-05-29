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
  - **完成紀錄**：commit `7ed5a24` feat + `2ff8e0d` test + `fc21ec6` docs（2026-05-28）。`fvm flutter analyze` 0 issue、`fvm flutter test` 114 passed（87 既有 + 27 新增：calendar 19 + stock 4 + settings 4）。三個開工決策最終選擇：(1) **stock list 不做 Firestore 同步**——自選股清單純本地 Hive，重裝會消失但體積小、重建成本低；未來若要同步，再加 `watched_stocks_firestore_ds` + 對應 queue 邏輯，對齊 CalendarRepository 模式。(2) **flush 觸發只開 public method**——`flushPendingWrites()` 由呼叫端（bootstrap / 未來 connectivity 事件）決定何時呼叫，本 step 不引入 `connectivity_plus` 依賴。(3) **不開 Riverpod provider**——Repository 純 class + constructor inject，test 直接 new；Step 13+ ViewModel 時再開。決策：(a) **待同步佇列 schema 分流**——write queue 存 composite key `<symbol>:<YYYY-MM>`（flush 時從 local 撈最新 doc 再 push），delete queue 存 `CalendarDoc.id`（uuid，本地 doc 已刪除沒法回查，calendarId 已足夠呼叫 `remote.delete`）。兩個常數加在 `core/storage/hive_boxes.dart`。佇列以 `List<String>` 存於 meta box，加入時用 Set 去重避免短時間連寫灌爆。(b) **CalendarRepository.get 走 listByStock + filter**——remote DS 沒有 `getByYearMonth` 介面（key 是 uuid 不是 composite），改用 `listByStock(uid, symbol)` 拉整 symbol 名下所有 month 後 filter `year/month`；Phase 1 一個 stock 一年 ~12 doc 可接受，未來若 hot path 才考慮在 DS 加 `where('year', ==).where('month', ==)` 查詢。(c) **CalendarRepository.watch 處理 DS bug-or-feature**——local DS 的 `watchByStock` 在任何 month delete 都 emit null（deleted event 沒 value 可判斷 key），repo 不能直接信任這個 null。改為「收到任意 event → re-read target (symbol, year, month)」，避免「同 symbol 別 month 刪除」誤觸發 null emit。(d) **watch 用手動 StreamController 不用 async\***——`async* + await for(broadcast stream)` 在 listener cancel 時內部 subscription 漏拆會 hang（calendar test 首次跑出現 2 個 timeout，改寫後通過）；改用 `StreamController(onListen/onCancel)` 顯式管理 inner subscription。stock / settings 的 watch 仍用 `async*`（底層是 Hive box.watch real stream，teardown 關 box 時會自然 close，不會 hang）。(e) **CalendarRepository.get remote miss 回 `Success(null)`**——「沒預測過這個 month」是合法狀態而非錯誤，避免 ViewModel 把預設空畫面誤判成「載入失敗」。(f) **SettingsRepository 在 NotFoundError 回 `Success(AppSettings())`**——預設值落地在 Repository，保持 DS 層「不寫入預設值」契約（對齊 Step 7 決議）。(g) **未登入時 put / delete 跳過 remote 也不入佇列**——理由：沒 uid 沒辦法決定要寫到哪個 user 名下，下次有 uid 也不會自動補；匿名登入幾乎必成功，此 trade-off 合理。**踩雷**：(i) `async* + broadcast stream + await for` 在 cancel 時 hang（如上），改寫後通過；(ii) `Result.when` 的 callback 不支援 async，改用 Dart 3 sealed class pattern matching `switch (r) { case Success(value: ...): ... }`；(iii) 第一次 mock register fallback 漏了 `CalendarDoc`，補 `registerFallbackValue(_doc())` 後通過。Test 覆蓋：calendar 19 cases（get 5：local hit / local miss+remote hit / local miss+remote 也 miss / 未登入跳過 remote / remote NetworkError 傳遞；put 5：成功 + 不入佇列 / remote 失敗入佇列 / 重複入佇列去重 / 未登入跳過 / local 失敗短路；delete 2：成功 + remote 失敗入佇列 / local 沒 doc 不入佇列；flushPendingWrites 5：write 全成功清空 / 失敗保留 / 本地已刪除 drop / delete 成功清空 / 未登入跳過；watch 2：初始 emit + delta re-read / delta 後 NotFound → null）+ stock 4 cases（add/list/remove / 空 box / watch 補初始 + delta / watch 初始空 box）+ settings 4 cases（NotFound → 預設 / update + get / watch 預設 + update / watch 初始有值）。

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

- [x] **Step 12：Onboarding & Splash**
  - 3 頁 onboarding（`features/onboarding/`）
  - 首次完成寫入 meta box
  - 路由：onboarding 未完成 → 顯示；已完成 → 直跳 calendar
  - **驗收**：模擬清空資料後首啟看到 onboarding
  - **完成紀錄**：
    - commits：`feat(step12)` + `test(step12)` + `docs(step12)`（hash 見 git log）
    - 120 unit tests passed（114 既有 + 6 新增：repo 3 / viewmodel 3）；`fvm flutter analyze` 0 issue
    - 三個開工決策最終選擇：
      1. **薄層 Repository**：`OnboardingRepository` 直接 wrap `Box<dynamic>` 的 get/put，不做 DS / Model 分層（純 bool 不值得三層）。
      2. **Onboarding 圖**：用 Material Icon (`calendar_today` / `insights` / `fact_check`) + 純色背景塊，不建 `assets/images/onboarding/`，真正素材留 Step 26。
      3. **Home redirect target**：維持現有 `/` placeholder，未另開 `/calendar`，Step 13 接入主畫面時自然替換。
    - 額外決策：ViewModel 採 sync `Notifier<bool>`，未用 AsyncNotifier。理由：meta box 已在 bootstrap 階段 open，repository 讀寫均可 sync，AsyncNotifier 會為 await 而 await（與 CLAUDE.md「Simplicity First」抵觸）。router redirect 需 sync 判斷，這個選擇也直接吻合。
    - bootstrap.dart 改動：新增 `await Hive.openBox<dynamic>(kMetaBox)`，讓 router redirect 可 sync 讀 onboarding flag。
    - hive_boxes.dart 新增 `kOnboardingCompletedKey = 'onboarding_completed'`；未動 hive_init.dart（純 bool 不需 adapter）。
    - 手動驗收（清空 app data → 啟動）留待真正裝置 / 模擬器執行；本 step CI 驗收僅靠單元測試與 analyze。
    - rules / auth 實機驗收續延後至 Step 13。

- [ ] **Step 13：Calendar Screen（主畫面）骨架**（code done，實機驗收續延後）
  - `features/calendar/view/calendar_screen.dart`
  - 整合 `table_calendar` 套件
  - `CalendarViewModel` 從 Repository 訂閱當前股票/月份的資料
  - 暫不接 prediction editor，只顯示空月曆 + 假資料
  - **驗收**：可切換月份、selectedDay 變化、無顯著 jank
  - **完成紀錄**：commit `d5595ce` feat + `cf20457` test + `<docs>`（2026-05-28）。`fvm flutter analyze` 0 issue、`fvm flutter test` 126 passed（120 既有 + 6 新增 ViewModel test）。**Step 5 / 6 / 8 / 13 實機驗收續延後**（user 選擇本 step 不跑模擬器，留待後續 step 一併在裝置上驗證 onboarding → calendar → settings → auth bind 完整主流程）。三個開工決策最終選擇：(1) **state 放獨立 provider**——新建 `CurrentSymbol`（Notifier&lt;String?&gt;，初始 null）+ `FocusedMonth`（Notifier&lt;DateTime&gt;，初始當月月初 UTC）兩個 keepAlive notifier；CalendarViewModel `ref.watch` 兩者後呼叫 `repo.watch(...)`，Step 14 chips 切換時直接 `set(symbol)`。(2) **empty state**——`symbol == null` 時 CalendarViewModel 直接 emit `Stream.value(null)` 不訂閱 repo，CalendarScreen 顯示「請新增股票」placeholder；不 hardcode 假股票避免 Step 14 忘了清。(3) **markerBuilder**——在 `CalendarMonthView` 的 `CalendarBuilders` 預留 `markerBuilder` 參數，body 直接 `return null` + comment 指向 Step 15，icon mapping 留到 Step 15 一次做完。決策：(a) **calendar box 在 bootstrap 開啟**——對齊 meta box 模式（已被 onboarding repository sync 讀取的前例），讓 `calendarLocalDataSourceProvider` 可 `Hive.box<dynamic>(kCalendarsBox)` sync 取得，不需要 FutureProvider 包一層；trade-off 是冷啟動多一次 IO，但 calendar 資料屬 critical path，預先 open 合理。(b) **`calendarRepositoryProvider` 在 Step 13 開**——對齊 Step 9 完成紀錄「不開 provider，留到 ViewModel 階段一次接通」決議；wiring 與 ViewModel 同檔，未來 Step 14+ 共用同個 provider。(c) **predictionsByDay 是 pure function 不是 provider**——CalendarDoc → `Map<int, Prediction>` 是純衍生資料，每次 build 重算 O(n)，n &lt;= 31 不值得包 provider；widget 直接呼叫即可。(d) **CalendarMonthView `onPageChanged` 同步更新 widget local `_focusedDay` + `focusedMonthProvider`**——前者讓 table_calendar UI 馬上反映、後者讓 ViewModel 換月訂閱；單一事件雙寫但目的不同（local UI state vs cross-widget shared state），對齊 ViewModel pattern 原則。(e) **`selectedDay` 純 widget 內部 state**——不放 provider，因為 Step 15 prediction editor 是 modal sheet 由 widget 自身管理，不需跨 widget 共享。Test 覆蓋：6 cases（symbol null 不訂閱 + emit null / 有 symbol → emit repo data / 切月 → 重新訂閱新 month / 切 symbol → 重新訂閱新 symbol / symbol 切回 null → emit null / predictionsByDay 純函式 day-of-month 映射）。**踩雷**：(i) `CalendarBuilders.markerBuilder` 簽名是 `(BuildContext, DateTime, List&lt;T&gt;)` 而非 `(BuildContext, DateTime, List&lt;dynamic&gt;)`，TableCalendar 用泛型參數鎖定 event type，這裡用 `TableCalendar&lt;Prediction&gt;` + `eventLoader` 回 `[prediction]` 串好 markerBuilder 拿到的 events type。(ii) PredictionType enum 沒有 `targetUp/targetDown`，實際是 `upLimit / downLimit / customPrice / customPercent / bullish / bearish`，test 用 bullish / bearish 對齊現有 schema。

- [ ] **Step 14：Stock Management（股票管理）（code done，實機驗收續延後）**
  - `features/stock/` 全部
  - 新增 / 搜尋（打後端 API） / 刪除 / 排序
  - 主畫面頂部接入股票切換 chips
  - **驗收**：新增「2330.TW」顯示「台積電」名稱；切換股票月曆刷新 [實機驗收續延後]
  - **完成紀錄**：commit `89db89d` feat + `822bc0b` test + `858fc06` docs（2026-05-28）。`fvm flutter analyze` 0 issue、`fvm flutter test` 136 passed（126 既有 + 10 新增）。**Step 5 / 6 / 8 / 13 / 14 實機驗收續延後**——user 選擇本 step 不跑模擬器、留待後續 step 一併在裝置上驗證完整流程。四個開工決策最終選擇：(1) **Step 11 路徑**——本 step 全走 mock client，`MockStockApiClient` 寫死 7 支熱門股 hard-code 表（2330 / 2317 / 0050 / 2454 / AAPL / NVDA / TSLA），symbol / name substring 模糊比對；Step 11 之後 `StockApiClient` 改成 abstract 由 Dio 實作版替換。(2) **首支自動選中**——`StockSearchSheet.addAndSelect` 顯式 side effect：只在 `currentSymbolProvider == null` 時 set 成新加入 symbol，無隱性 race。(3) **API 失敗 fallback**——`_ErrorWithManualAdd` 元件在 error state 顯示「直接以「{query}」加入」按鈕，走 `addManually` 寫 `Stock(symbol, market=tw, name=symbol)` 進 Hive（quote 之後 settle 補）；mock 情境不會走到但 UI 路徑保留。(4) **Chip UI**——`FilterChip` 直接用 M3 selected 樣式，長按用 `GestureDetector` 包外層觸發刪除確認 dialog。決策：(a) **stocks box 在 bootstrap 開啟**——對齊 calendar / meta box 模式，`StockLocalDataSource` 用 `Hive.box<dynamic>(kStocksBox)` sync 取得。(b) **`stockApiClientProvider` 是獨立 keepAlive provider**——Step 11 換實作只改這一行 override；測試用 `overrideWithValue(_SpyApi())` 注入。(c) **排序依加入順序，不另開 `sortOrder` 欄位**——Hive box keys 是 insertion order，`box.values` 直接就是加入順序；未來若要拖拉排序再加。(d) **長按刪除時若刪到當前選中 symbol → 同步 `currentSymbolProvider.set(null)`**——chips bar 自己負責這個 side effect，避免 CalendarViewModel 訂閱孤兒 symbol。Test 覆蓋：10 cases（list：直接訂閱 repo stream 驗證 add / add / remove emission 順序 + viewmodel provider 初始空清單；search：空 query 不打 API / debounce 3 連發只打 1 次 / API 失敗→ AsyncValue.error / addAndSelect 首支自動選 currentSymbol / addAndSelect 在已有 currentSymbol 時不覆寫 / addManually 空字串 false / addManually 有效字串持久化並選中）。**踩雷**：(i) `@riverpod` 預設 autoDispose；測試只 `container.read(notifier)` 不訂閱 state → 立刻 dispose，會把 debounce Timer 一起 cancel 導致 api.calls 永遠 0。Fix：setUp 加 `container.listen(stockSearchViewModelProvider, (_, __) {})` 保持訂閱。(ii) `repo.watch()` async\* 透過 StreamProvider 走 valueOrNull 在 50ms delay 後仍可能 stale（async\*+Hive Box.watch+riverpod 三層 async hop），改為直接 `repo.watch().listen` 蒐集 emissions list 更穩；viewmodel 層只驗初始 emission（薄薄一層 wrap 不重複驗 stream 機制）。(iii) `Hive.registerAdapter` 在 setUpAll 必須 guard `isAdapterRegistered(typeId)`，否則跨檔測試 typeId conflict。

- [ ] **Step 15：Prediction Editor**（code done，實機驗收續延後）
  - `features/prediction/view/prediction_editor_sheet.dart`
  - 全部預測類型 UI
  - 寫入 Hive → 同步 Firestore
  - 月曆 cell 顯示對應 icon
  - **驗收**：填入後關閉再開仍看得到；切換裝置（重新登入）資料同步 [實機驗收續延後]
  - **完成紀錄**：commit `c0f0550` feat + `83a6771` test + `8135e8d` docs（2026-05-28）。`fvm flutter analyze` 0 issue、`fvm flutter test` 147 passed（136 既有 + 11 新增 PredictionEditor ViewModel test）。**Step 5 / 6 / 8 / 13 / 14 / 15 實機驗收續延後**——預計 Step 16 quote settlement 完成後一併在裝置上跑完整 onboarding → calendar → 編輯預測 → settle → 主流程。四個開工決策最終選擇：(1) **Sheet UI 結構**——單一 sheet + 6 個 `ChoiceChip`（非 `SegmentedButton`：6 個值在窄寬螢幕擠不下）切 PredictionType，下方欄位依 type 動態顯示（customPrice → 收盤價 input、customPercent → 漲跌幅 % input + 「相對前一交易日收盤」helper text、upLimit/downLimit/bullish/bearish → 不顯示數字欄位）+ 共用備註欄位。(2) **預設 PredictionType**——`bullish`（最常用、無數字欄位需要立刻填、減少點擊）。(3) **儲存時機**——「儲存」按鈕觸發 `repo.put`（非 autosave；避免 sheet 被滑掉造成意外寫入；按下按鈕後 pop sheet）。(4) **customPercent 百分比基準**——「相對前一交易日收盤」（03-data-model.md 未規範，預設此基準對齊台股漲跌幅慣例；sheet helper text 顯示提示；實際 settle 邏輯 Step 16 處理）。決策：(a) **prediction 上下架走 ViewModel 內 read-modify-put doc**——repo 沒有 `upsertPrediction` / `deletePrediction`（task 文件誤述、grep 確認 Step 9 只建 doc-level put/delete），本 step 規則「不動 repository」→ VM 內 `ref.read(calendarViewModelProvider).valueOrNull` 拿現有 doc → 替換/加入/移除該日 prediction → `repo.put(updatedDoc)`；第一次寫入（doc null）由 VM new `CalendarDoc`（uuid v4 / `authServiceProvider.currentUserId ?? 'local'` / `themeId: 'default'`）。(b) **VM family key 用 (String symbol, int year, int month, int day) 四個 int**——不用 DateTime 避免 timezone / time 部分造成 hashCode 不一致；VM 內 `_sameDay` 統一 `toLocal()` 比對。(c) **build() 用 `ref.read` 不 `ref.watch` calendarViewModelProvider**——使用者編輯到一半 stream emit（例如剛存完）不會把 draft state 沖掉；sheet pop 時 autoDispose 重置。(d) **PredictionDraft 用 String 保留 price/percent 原始輸入**——`double.tryParse` 只在 `canSave` 與 `toPrediction` 才呼叫，避免使用者打 `12.` 暫態被 parse 成 12 又顯示回 `12.0` 造成 cursor 跳動；`canSave` 對 customPrice 要求 `> 0`、customPercent 要求 `> -100`。(e) **markerBuilder 顯示單一 icon**——cell 一日一 prediction（同日重複編輯走 replace 邏輯），無需多 icon 疊加；`Positioned(bottom:4, right:4, Icon size:14)` 不擋 day number。Test 覆蓋：11 cases（PredictionDraft：empty default / customPrice canSave 邊界 / customPercent canSave 邊界 / fromPrediction prefill；VM：build 無 existing 給 empty / build 有 existing 給 prefilled + isExisting / save 從 null doc 創 CalendarDoc / save 替換同日 prediction 保留其他日 / save canSave false 不寫入 / delete 移除該日保留其他日 / delete 在 null doc 直接回 true 不寫入）。**踩雷**：(i) 開工 brief 寫「Step 9 已建好 upsertPrediction / deletePrediction」實際 grep 不存在——CalendarRepository 只有 doc-level `put(CalendarDoc)` / `delete(symbol, year, month)`，停下來問 user 確認後採 ViewModel read-modify-put 策略，避免動到 repo 違反「本 step 不動 repository」規則。(ii) SegmentedButton 在 6 個 type 撐到窄寬會 overflow，改用 `Wrap` of `ChoiceChip`（avatar 放 type icon 視覺一致）UX 較順。(iii) PredictionEditorViewModel 用 `@riverpod class` codegen + 4 個 family 參數（家族不能用 freezed 物件當 key 否則 hashCode 不穩，用 primitive types）。

- [ ] **Step 16：Quote Settlement（自動結算）** _(code done，實機驗收續延後)_
  - Repository 整合：開月份時批次拉 quotes
  - 計算 hitPercent、染色 cell
  - 手動補價 UI（API 失敗時）
  - 「設定 → 自動結算」開關尊重
  - **驗收**：填過去日期的預測 → 自動結算染色正確 — _實機驗收續延後（Step 16 結束預計打包跑完整實機驗收）_
  - **完成紀錄**：commit `39eb5c1` feat + `c039ce1` test（2026-05-29）。`fvm flutter analyze` 0 issue、`fvm flutter test` 163 passed（147 既有 + 16 新增：8 settle helpers + 8 settleStatusOf）。**Step 5 / 6 / 8 / 13 / 14 / 15 / 16 實機驗收續延後**——預計 Step 16 結束打包跑完整實機驗收（onboarding → calendar → 編輯預測 → 自動結算染色 → 手動補價）。六個開工決策最終選擇：(1) **容許誤差** — customPrice 嚴格等於（用 cents `round` 比避免浮點，台股 tick aligned 不會有 0.01 差問題）、customPercent 比對到小數第一位（`|diff| < 0.05pp` 對齊台股 app 顯示慣例）、bullish/bearish 嚴格大於 / 小於（平盤不算命中）、upLimit/downLimit 用 `actualCents × 10 ≥ prevCents × 11` 整數比避免浮點。(2) **upLimit/downLimit 命中** — 簡化版「實際漲跌幅 ≥ +10% / ≤ -10%」（不查當日 limit 表，mock 階段適用；真 API 時可再進化）。(3) **bullish/bearish 命中** — vs 前一交易日 close；quotes 多抓 5 天緩衝（給連假兜回）。(4) **手動補價 UI** — PredictionEditorSheet inline `_SettleSection`（已 settled 顯示實際收盤 + 命中 chip + hitPercent；未 settled 過去日顯示 TextField + 補價按鈕；未來日 / 已 settled 不顯示）。(5) **settle 觸發** — `CalendarMonthView.build` 內 `ref.watch(settlementViewModelProvider)` → riverpod 自動 re-run（doc 或 settings emit 變動就重跑）；ViewModel 內 `_running` flag 防併發 re-entry；autoSettleEnabled OFF → 早期 return。(6) **mock quotes** — 7 支熱門股（2330/2317/0050/2454.TW + AAPL/NVDA/TSLA）寫死 base price，用 `dayHash` deterministic noise ±5% 產生收盤；台股 snap 到 TWSE tick；週末跳過；未來日不出現在 map。**marker 染色** — 用 `defaultBuilder`/`todayBuilder` 包 Container 圓底（淡綠 hit / 淡紅 miss / 淡灰 past-unsettled / 透明 future + no prediction）；icon 維持原 `markerBuilder` 不變。**踩雷**：(i) 開工 brief 提「平盤預測」是新增 `PredictionType.flat` enum，會動到 prediction_type.dart + g.dart 重 codegen + chips bar + editor VM + visual + settle 邏輯，超出「本 step 不動 PredictionEditor 本體」scope → 停下來問 user 確認後拆獨立 step（Step 16.5）給下個 session 做。(ii) `SettingsRepository` / `SettingsLocalDataSource` 之前沒 provider wiring，本 step 順手在 `features/settings/viewmodel/settings_view_model.dart` 補上（`settingsLocalDataSourceProvider` keepAlive + `settingsRepositoryProvider` keepAlive + `settingsViewModelProvider` hot stream + `settingsControllerProvider` 寫入）；順手把 SettingsScreen 加 `_AutoSettleTile` SwitchListTile，否則使用者無法 toggle autoSettle 違反 brief「OFF 時跳過」語意。(iii) `stock_search_view_model_test._SpyApi` 因 `StockApiClient` 加 `quotes()` 新介面而編譯失敗 → 補一個 stub 回空 map。(iv) 沿用 Step 15 的 inline read-modify-put 策略（不抽 repo helper），settlement VM 與 PredictionEditor VM 各自有一份，重複可接受、符合「本 step 不動 repository」。

- [x] **Step 16.5：平盤預測 type（從 Step 16 拆出）** _(code done，實機驗收續延後)_
  - 擴 `PredictionType.flat` enum（HiveField(6)）+ 重跑 build_runner
  - `PredictionVisual.of` 加 flat case（`Icons.horizontal_rule` / 灰色 / 「平盤」）
  - `PredictionEditorSheet` chips bar 多一顆、editor VM switch case
  - `settlement_view_model._computeSettle` 加 flat（`actualClose == prevClose` 嚴格相等命中）
  - `price_utils.settleFlat` pure helper + unit test
  - `settleStatusOf` flat case
  - 03-data-model.md 補一段 flat type 規格
  - [ ] **驗收**：建立 flat prediction → settled 後嚴格相等命中、否則 miss（**實機驗收續延後**）
  - **完成紀錄**：commit `f1c2af0` feat + `0b3c4a7` test（2026-05-29）。`fvm flutter analyze` 0 issue、`fvm flutter test` 167 passed（163 既有 + 4 新增：2 settleFlat + 2 settleStatusOf flat）。**Step 5 / 6 / 8 / 13 / 14 / 15 / 16 / 16.5 實機驗收續延後**——預計 Step 17 前或 Step 17 結束打包跑完整實機驗收。四個開工決策最終選擇：(1) **flat 命中定義** — `actualClose` 嚴格等於 `prevClose`，用 cents 整數比 `(prev*100).round() == (actual*100).round()` 避免浮點誤差，延續 Step 16 customPrice 嚴格等於慣例。(2) **flat icon** — `Icons.horizontal_rule` 灰色 `Color(0xFF757575)`，語意最清楚。(3) **enum 順序** — append 在最後 `HiveField(6)`，**不破壞既有 6 個值的 Hive 序列化**；chips bar 順序由 `PredictionType.values` 自動帶出，flat 排在 bearish 之後（看多/看空/平盤三連）。(4) **`_judgeHit` 對 flat** — 由於 `Prediction` model 沒存 `prevClose`，用 `hitPercent == 0.0` 判定（settle 寫入時已用 cents 嚴格等於 → `hitPercent` 必為 0.0，邏輯等價）。**踩雷**：(i) `build_runner` 順帶 regen 了 `prediction.g.dart`（json enum map 多 `flat: 'flat'`）+ `settlement_view_model.g.dart`（hash 變動），兩個 .g.dart 與 feat 一起 commit（衍生產物）。(ii) `PredictionEditorSheet._fieldsFor` 與 VM `canSave` 的 fall-through case 直接 append flat 到 bullish/bearish 後面，flat 無數字欄位、`canSave` 一律 true，不必新增 switch 分支。(iii) Hive `HiveField(6)` 一旦寫入裝置就不能改順序，因此確認 append-only 才 commit。

- [ ] **Step 17：行事曆主題系統**（code done，實機驗收續延後）
  - `app/theme/calendar_themes.dart` 5 套主題
  - 設定頁切換 App 主題
  - 月曆內主題切換按鈕
  - 主題 ID 存 CalendarDoc 與 AppSettings
  - **驗收**：5 套主題視覺差異明顯；切換立即套用（實機驗收續延後）
  - **完成紀錄**：commit `c6c02aa` feat + `7bbcecc` test（2026-05-29）。`fvm flutter analyze` 0 issue、`fvm flutter test` 170 passed（167 既有 + 3 新增 byId cases）。**Step 5 / 6 / 8 / 13 / 14 / 15 / 16 / 16.5 / 17 實機驗收續延後**。五個開工決策最終選擇：(1) **5 套配色** — default(#1E88E5 藍) / warm(#FB8C00 暖橘) / cool(#0288D1 海藍) / mono(#424242 簡約灰) / nature(#388E3C 森林綠)；每套定義 seed + monthBackground + hit/miss/unsettled cellBg。(2) **App vs 月曆主題關係** — (B) App 主題是 fallback；月曆 `themeId == 'default'` 時跟隨 App seed，否則覆蓋。(3) **月曆切換按鈕位置** — (A) AppBar 右側 `Icons.palette_outlined` + modal bottom sheet 列 5 套；省版位且不擠 cell。(4) **未知 themeId** — `CalendarThemes.byId` fallback to `defaultTheme`，不報錯，test 覆蓋。(5) **Hive migration** — 不需要；`CalendarDoc.themeId` 在 Step 9 已加為 required，`AppSettings.themeId` default `'def'`（legacy 字串）由 byId 當 unknown fallback 處理，不動 schema。**踩雷**：(i) `AppSettings.themeId` 既有 default 值 `'def'` 與 5 套 id 的 `'default'` 不一致，沒改 `@Default` 避免 freezed/hive regen 風險，改用 byId fallback 統一吸收（'def' 走 unknown → defaultTheme）。(ii) AppBar palette IconButton 放在 `calendar_screen.dart`（不是 `calendar_month_view.dart`，因為 AppBar 屬於 Screen 層），切換時 `ref.read(calendarRepositoryProvider).put(doc.copyWith(themeId, updatedAt))` 直接走既有 update 路徑，不動 repo 邏輯。(iii) 月曆背景用 `Container(color: theme.monthBackground)` 包 `TableCalendar`，沒改 table_calendar 內部 builder；cell bg 透過既有 `defaultBuilder/todayBuilder` 帶 theme 參數注入。

- [ ] **Step 18：Share Image — 整月行事曆版型**（code done，實機驗收續延後）
  - `share_image/templates/full_calendar_template.dart`
  - `RepaintBoundary` + `toImage()` 出 PNG
  - 三種比例（9:16 / 1:1 / 4:5）切換
  - 儲存相簿 + share_plus
  - **驗收**：實機儲存到相簿成功；分享開啟系統 share sheet — _實機驗收續延後（Step 5/6/8/13/14/15/16/16.5/17/18 一併留待後續打包驗收）_
  - **完成紀錄**：commit `6f6cc4e` feat + `85a34e3` test（2026-05-29）。`fvm flutter analyze` 0 issue、`fvm flutter test` 173 passed（170 既有 + 3 新增 ShareAspectRatio size cases）。**Step 5 / 6 / 8 / 13 / 14 / 15 / 16 / 16.5 / 17 / 18 實機驗收續延後**。七個開工決策最終選擇：(1) **存相簿套件** — **直接用 `gal ^2.3.0`**（Step 1 已換掉 image_gallery_saver_plus 改 gal，比 saver_gallery 更新更主流；`Gal.putImageBytes(bytes, name:)` 一行 API），**零新增套件**——`share_plus 12.x` 也支援 `XFile.fromData(bytes)` 直接吃 bytes，不必 path_provider 寫 temp file。(2) **像素規格** — 固定 1080 短邊（story 1080×1920 / square 1080×1080 / portrait 1080×1350），輸出大小可預期、品質一致。(3) **Template 結構** — 獨立 7-col `Row(Expanded)` 網格自繪，不包 TableCalendar；header / footer / 浮水印自由排版。(4) **入口位置** — Calendar AppBar `Icons.ios_share` IconButton（放在 palette 之前），`symbol == null` 時 disabled。(5) **三比例切換 UI** — `SegmentedButton<ShareAspectRatio>` M3 原生。(6) **Header 內容** — 「YYYY 年 MM 月 · 股票代號」簡潔版，命中率資訊留 Step 19 報告卡。(7) **浮水印** — 右下 `Icons.calendar_month` + 「股市行事曆」字樣，theme.seed 70% opacity。決策：(a) **像素為 logical size**——template `SizedBox(width: ratio.width, height: ratio.height)`，preview 用 `FittedBox(BoxFit.contain)` 縮放到螢幕；`RepaintBoundary.toImage(pixelRatio: 1.0)` 直接出 1080 寬圖（不靠 DPR 放大）。(b) **theme 解析重用 CalendarScreen 邏輯**——`docThemeId == 'default'` fallback 到 App settings themeId，再 `CalendarThemes.byId` 解析；保證分享圖與螢幕月曆完全同調色。(c) **cell 染色重用 `settleStatusOf`**——hit/miss/unsettled 三色直接用主題 cell bg；未來日（無 prediction）不染色。(d) **權限流**——`Gal.hasAccess()` → `requestAccess()` → `putImageBytes`，失敗 SnackBar 提示；無 path_provider 依賴。(e) **檔名格式** — `{symbol}_{YYYY-MM}`（如 `2330.TW_2026-05`），相簿 / share sheet 共用。**踩雷**：(i) `withOpacity` 在 Flutter 3.41 已 deprecated（precision loss），改用 `withValues(alpha:)`，3 處替換。(ii) gal 已 wired，不需 saver_gallery / image_gallery_saver；user brainstorm 時選 saver_gallery，但檢查 pubspec 發現 gal 在 Step 1 就裝好了，直接沿用較簡潔。(iii) Template 內 `Expanded(child: Row(Expanded(_buildCell)))` 巢狀 Expanded 在 7×6 grid 上工作正常；`Padding(EdgeInsets.all(4))` 給 circle cell 留 gap。(iv) `SharePlus 12.x` API 是 `SharePlus.instance.share(ShareParams(files: [...]))`，不是舊版 `Share.shareXFiles`。Test 覆蓋：3 cases（story916 1080×1920 ratio 9/16 / square11 1080×1080 / portrait45 1080×1350 ratio 4/5）。

- [ ] **Step 19：Share Image — 單日卡片 + 月度報告版型**（code done，實機驗收續延後）
  - `single_day_template.dart`、`report_card_template.dart`
  - 3–5 個梗圖背景內建在 assets
  - 預覽切換版型
  - **驗收**：三版型皆可分享、視覺品質可接受
  - **完成紀錄**：commit `24f6d31` feat + `c7bd10c` test（2026-05-29）。`fvm flutter analyze` 0 issue、`fvm flutter test` 180 passed（173 既有 + 7 新增：2 ShareTemplate + 5 ReportSummary）。**Step 5 / 6 / 8 / 13 / 14 / 15 / 16 / 16.5 / 17 / 18 / 19 實機驗收續延後**。七個開工決策最終選擇：(1) **梗圖背景策略** — **純 Flutter 漸層 preset**（`ShareBackground` enum：sunrise/ocean/forest/dusk 4 組 `LinearGradient` + none），**零 asset 檔、零版權、零 bundle 膨脹、不改 pubspec**；偏離「新增 assets/share_bg/」的字面寫法，但決策(B)+技術注意已明文授權，user 開工前對齊確認採此。(2) **背景縮圖 UI** — 橫向 `ListView`（52×52 圓角漸層 swatch + 選中 ring + 標籤；none 顯示 `Icons.block`）。(3) **ReportCard 預設週期** — **只做本月、不加切換 ChoiceChip**：直接用已 `watch` 的當月 doc 包成 `[doc]` 餵 `List<CalendarDoc>` 型 template/aggregator；零新 async、零新 provider；近 3 月切換留 Step 20 完整報告頁。(4) **命中率口徑** — **settled-only 分母**（unsettled 排除分母，分子算 hit）；`ReportSummary.hitRate = settled==0 ? 0 : hit/settled`，已標 `TODO(step20)` 待完整報告頁統一。(5) **ratio 限制** — 全部 template 可三選（template 內自行 letterbox / FittedBox 縮放）。(6) **SingleDay 取資料源** — **本月已預測日的橫向 chip 選擇器**（非 DatePicker dialog）：用當月 doc 的 predictions 生 chip，預設今日（若有預測）否則第一筆；選不到空日、不需新 cross-widget provider、不需跨月抓資料；doc 無預測時顯示 `_EmptyCard` 占位並 disable CTA。(7) **aggregator 抽 helper** — **抽 `report_summary.dart` 純函式 `ReportSummary.from(List<CalendarDoc>)`**（+ `TypeStat` 分項）方便單測，Step 20 完整報告可直接 import 重用。浮水印沿用 Step 18「股市行事曆」字樣，抽出 `ShareWatermark` 共用元件供兩個新版型用、**Step 18 `full_calendar_template.dart` 本體不動**（私有 `_Watermark` 保留，僅小幅重複，零風險）。**踩雷**：(i) SingleDay template 簽章相對 brief 精簡——`doc` / `date` 參數移除（`date` 與 `prediction.date` 重複、`doc` 未用），遵 CLAUDE.md「無 speculative code」。(ii) `_DaySelector` 重用 `_SharePreviewScreenState._sameDay` 私有 static（同 library 可存取），避免重複日期比對邏輯。(iii) 兩排 `SegmentedButton`（版型 + 比例）垂直堆疊在 320dp 寬實測不擠，未退回 Wrap of ChoiceChip。(iv) IDE 分析伺服器整段報 `package:flutter` URI 無法解析（套件未解析的 stale 狀態），但 `fvm flutter analyze` 實跑 0 issue——以 CLI 為準。(v) ReportCard 命中率大字採 `theme.seed` 色，深色漸層不影響（report card 走純主題底不套漸層；漸層只用於 single day）。

- [ ] **Step 20：Accuracy Report**（code done，實機驗收續延後）
  - `features/accuracy_report/`
  - 聚合計算 + fl_chart 折線圖
  - 「分享成績」CTA 跳轉
  - **驗收**：本月 / 近 3 月 / 全部 數字計算正確
  - **完成紀錄**：commit `f4e604e` feat + `f4b880e` test（2026-05-29）。`fvm flutter analyze` 0 issue、`fvm flutter test` 191 passed（180 既有 + 11 新增 AccuracyReport 聚合 cases）。**Step 5 / 6 / 8 / 13 / 14 / 15 / 16 / 16.5 / 17 / 18 / 19 / 20 實機驗收續延後**。九個開工決策最終選擇：(1) **命中率口徑統一** — **settled-only**（unsettled 排除分母），且 `AccuracyReport` 全程透過 `ReportSummary.from` 聚合（summary / 每月序列 / 最佳股票皆然），口徑與 Step 19 報告卡**結構性一致**；`report_summary.dart` 的 `TODO(step20)` 已收掉並標「口徑已統一」。(2) **多月/多股聚合資料源** — 採 (A) **直接 `calendarLocalDataSourceProvider.getAll()`** 在 ViewModel 聚合，**不動 repository**（repo 僅 per-(symbol,year,month) 介面）。(3) **聚合 helper 抽純函式** — `AccuracyReport.from(allDocs, tab, now)` 純函式（含 summary + monthlySeries + bestStock + filtered docs），與 riverpod ViewModel 分層、可單測。(4) **Tab 維度跨股票** — 本月 / 近 3 月 / 全部三 Tab **皆跨所有 symbol** 聚合（最佳股票才有意義）。(5) **折線 X 軸與空月** — X = 有預測的年月（升序）；**無預測月跳過**、**有預測但全未結算月顯示 0%**（仍入序列）；跨股票同年月合併成一個點。(6) **最佳股票定義** — 命中率最高且 **settled ≥ 3**（`kBestStockMinSettled`）避免單筆 100% 奪冠；平手取命中數多者；無達門檻者顯示「—」。(7) **CTA 分享資料對齊** — `SharePreviewScreen` 加**可選 override**（`initialTemplate` / `reportDocs` / `reportPeriodLabel` / `reportSymbolLabel`），CTA 帶當前 Tab 的 `report.docs` + tab.label + 預設 `reportCard` 版型 + symbol 顯示「全部」；override 全 null 時維持既有 fullCalendar 行為（Step 18/19 入口零破壞）。(8) **入口位置** — Calendar AppBar `Icons.insights` IconButton（放在 ios_share 之前）→ `context.push('/report')`，**always enabled**（報告頁自理 empty state）。(9) **report cache** — **YAGNI 先不做**（Phase 1 資料量小），每次即時算。**踩雷**：(i) **fl_chart 0.68.0 `SideTitleWidget` 簽章是 `axisSide: meta.axisSide`，非新版的 `meta:`**——context7 拉到的範例是更新版 API，實際翻 `~/.pub-cache/.../fl_chart-0.68.0/lib/.../axis_chart_widgets.dart` 確認後才寫，避免照新版 API 編譯失敗。(ii) `Result` 沒有 `valueOrNull`，用 `.fold(onSuccess, onFailure)` 取值、失敗 fallback 空 list。(iii) 函式型 provider 的 `Ref` 型別 import 對齊 `calendar_view_model.dart`（加 `hooks_riverpod`）。(iv) 聚合不依賴 `prediction.date`（只看 `doc.year/month` 分組 + `settleStatusOf` 結算欄位），測試用固定日期即可；初版誤用 `_AnyDate implements DateTime` 的 noSuchMethod sentinel 過度設計，改回真實 `DateTime` 對齊 Step 19 test 風格。(v) build_runner 連帶重生 `settings_view_model.g.dart`（僅 provider hash 變動，generated 無害 churn），隨 feat commit 一起進。

---

### Phase 1：通知與廣告

- [ ] **Step 21：Local Notifications**（code done，實機驗收續延後）
  - `core/notifications/notification_service.dart` + `notification_schedule.dart`（純函式）
  - 每日 14:30 提醒（台股，週一~週五）
  - 結算完成通知
  - 設定頁通知開關
  - **驗收**：實機收到測試通知
  - **完成紀錄**：commit `6a67e4f` feat + `de2c7bd` test（2026-05-29）。`fvm flutter analyze` 0 issue、`fvm flutter test` 197 passed（191 既有 + 6 新增排程計算 cases）。**Step 5 / 6 / 8 / 13 / 14 / 15 / 16 / 16.5 / 17 / 18 / 19 / 20 / 21 實機驗收續延後**。開工決策最終選擇：(1) **檔名/分層** — 採 (A) **`core/notifications/notification_service.dart`** 專責本地通知（偏離 plan 的 `core/firebase/fcm_service.dart` 字面）；FCM 遠端推播留 Step 22 再加 `fcm_service.dart`，分層清楚。(2) **權限時機** — **App 啟動即請求一次**（bootstrap `requestPermissions()`，Darwin init 三權限設 false 改由 `requestPermissions` 顯式請求）。(3) **時區** — **固定 Asia/Taipei**；bootstrap 既有 `tz.setLocalLocation('Asia/Taipei')` 已滿足，service 用 `tz.local`。(4) **重複頻率** — **週一~週五 14:30**：排 5 筆（id 1001~1005）以 `DateTimeComponents.dayOfWeekAndTime` 週重複；國定假日仍會誤報，留待後續交易日曆。(5) **結算通知去重** — `_settleAll` 改回傳 `bool changed`，**實際寫回（changed==true）後彙總單則**「本月結算更新」，非每筆一則；最小侵入、不改結算判定。(6) **開關 gating** — `applyEnabled(false)→cancelAll()` 並不排程；`true→` 重排每日提醒；結算通知亦受 `notificationsEnabled` gating（OFF 全停）。(7) **可測性** — 排程計算抽 `nextInstanceOfTime` / `nextInstanceOfWeekdayTime` 純函式單測；平台 channel 不測。(8) **原生設定（可動）** — AndroidManifest 加 `POST_NOTIFICATIONS` + `RECEIVE_BOOT_COMPLETED` + 兩個 `flutterlocalnotifications` receiver；AppDelegate 設 `UNUserNotificationCenter.delegate`；iOS Info.plist 本地通知免新增 key。(9) **首次啟動排程** — **嚴守 brief 範圍：只 toggle 排程**，bootstrap 不讀持久設定排程（user 對齊確認）。**踩雷**：(i) **flutter_local_notifications 17.2.4 的 `zonedSchedule` 仍要求 `uiLocalNotificationDateInterpretation`**（v18+ 才移除）；context7 拉到的是新版範例，IDE diagnostics 抓出後補 `UILocalNotificationDateInterpretation.absoluteTime`——以實裝版本為準。(ii) `initialize` / `zonedSchedule` 17.x 為**位置參數**（非 v19 全 named），照實裝版簽章寫。(iii) **每日提醒非分秒精準** → 用 `inexactAllowWhileIdle` 而非 `exactAllowWhileIdle`，免 `SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM` 權限與 Play 政策審查。(iv) **發現 latent bug（不在本 step 範圍、未動）**：`kSettingsBox` 全程無 `openBox` 呼叫點（bootstrap 只開 meta/calendar/stocks），`settingsLocalDataSourceProvider` 同步 `Hive.box(kSettingsBox)` 於真機啟動會 throw；因各 step 實機驗收皆延後屬 latent，遵 CLAUDE.md「不碰無關碼」僅記錄。(v) `notificationService` 採 App 全域單例（bootstrap 與 ViewModel 共用），settlement/settings ViewModel 直呼；現有單測只測純函式（`settleStatusOf` / 排程計算）不建構 ViewModel，故零破壞。

- [ ] **Step 22：FCM Token Storage**（code done，實機驗收續延後）
  - 取得 FCM token
  - 寫入 `/users/{uid}/devices/{deviceId}`
  - 監聽 `onTokenRefresh`
  - **驗收**：Firestore console 看到 token；換裝置看到不同 deviceId
  - **完成紀錄**：commit `fc4e48f` feat + `26fbd7e` test（2026-05-29）。`fvm flutter analyze` 0 issue、`fvm flutter test` 205 passed（197 既有 + 8 新增 fcm_service 純函式 cases）。**Step 5 / 6 / 8 / 13 / 14 / 15 / 16 / 16.5 / 17 / 18 / 19 / 20 / 21 / 22 實機驗收續延後**（Firestore console 看 token + 換裝置不同 deviceId 與既有延後項一起）。開工決策最終選擇：(1) **檔名/分層** — 採 Step 21 決策1 預留的 **`core/firebase/fcm_service.dart`** 接遠端推播，與本地 `notification_service.dart` 分工（取 token / 權限 / onTokenRefresh / 寫 device doc）。(2) **deviceId 策略** — 採 **device_info_plus 現讀、不持久化**：iOS `identifierForVendor` / Android `androidInfo.id`，每次啟動現讀；**不新增 Hive meta key、不動 schema**（守 KI / CLAUDE.md「新 Hive 欄位停下來問」），換裝置 → 原生 id 不同 → deviceId 不同滿足驗收；原生 id null/空則 gating 跳過寫入。(3) **寫入時機 / gating** — `shouldWriteDevice(uid, token)` 要求兩者皆非空；bootstrap `start()` 訂閱 `userChanges().map((u)=>u?.uid)`，**uid 首次出現/變動**（含離線匿名登入失敗後恢復）取 token 寫入，並以 `_lastUid` 去重避免 userChanges 洗寫；`onTokenRefresh` 以當前 uid 重寫。(4) **doc 欄位** — `fcmToken` / `platform`（ios/android）/ `appVersion`（package_info_plus）/ `updatedAt`（`FieldValue.serverTimestamp()`），對齊既有 `device_firestore_ds_test`，不自行擴張（未加 deviceModel/osVersion）。(5) **沿用既有 DS** — 直接用 Step 20 既有 `DeviceFirestoreDataSource.put`（`users/{uid}/devices/{deviceId}`），**不重造輪子**。(6) **可測性** — 純函式 `buildDeviceDoc` / `shouldWriteDevice` / `pickDeviceId` 抽出單測（8 cases）；`FirebaseMessaging` / `device_info_plus` / Firestore 平台互動不單測（DS 行為 Step 20 已用 `fake_cloud_firestore` 覆蓋）。(7) **iOS APNs** — **本 step 純 code、不動原生設定檔**（Runner entitlements / capabilities / AppDelegate）；APNs 設定與既有實機驗收一起延後。**踩雷**：(i) **firebase_messaging 15.x `getToken()` 在 Apple 平台未備妥 APNs token 時回 `null`**（context7 確認）—— 本 step APNs 未設，iOS 實機 token 會是 null → `shouldWriteDevice` gating 自然跳過 iOS 寫入，無 crash，待 APNs 設定後才會真正寫；Android 不受影響。(ii) `onTokenRefresh` 依官方文件**「app 每次啟動 + token 輪替時都會 fire」**，啟動時與 uid listener 的 register 會各寫一次（同 doc `set`，idempotent，Phase 1 量低可接受），未額外去重 token。(iii) bootstrap `_startFcm()` 另呼叫 `requestPermission()`：iOS 與本地通知端 `requestPermissions()` 都請求通知授權，系統 dialog 僅彈一次（第二次回當前狀態），無重複跳窗。**未碰**：KI-1（`kSettingsBox` 未開）—— 本 step 不讀任何 Hive 設定，維持不碰。

- [ ] **Step 23：AdMob 整合**（code done，實機驗收續延後）
  - `core/ads/ads_service.dart`
  - Banner 在 calendar 底部
  - Interstitial 在出圖後（控頻率）
  - iOS ATT 提示
  - Test ad unit 在 debug，正式 ID 由 `--dart-define` 注入
  - **驗收**：debug 顯示測試廣告；release build 顯示正式廣告
  - **完成紀錄**：commit `7403202` feat + `a08ffce` test（2026-05-29）。`fvm flutter analyze` 0 issue、`fvm flutter test` 214 passed（205 既有 + 9 新增：adUnitId 選擇 4 + interstitial 頻率 5）。**Step 5 / 6 / 8 / 13 / 14 / 15 / 16 / 16.5 / 17 / 18 / 19 / 20 / 21 / 22 / 23 實機驗收（debug 測試廣告 + release 正式廣告）續延後**。開工決策最終選擇：(1) **檔名/分層** — `core/ads/ads_service.dart` 集中載入/顯示/控頻率/ATT；`MobileAds.instance.initialize()` 仍留 bootstrap（既有 `unawaited`，不重複 init）。Banner widget 抽 `core/ads/ads_banner.dart`。(2) **ATT 套件** — **本 step 新增 `app_tracking_transparency ^2.0.7`**；`AdsService.requestTrackingAuthorization()` 僅 iOS 且 `notDetermined` 才跳系統 dialog，bootstrap 在 `MobileAds.init` **前** `await`（取 IDFA），Android no-op。(3) **頻率計數存哪** — **純記憶體**（`_exportCount` / `_shownToday` / `_countDate` 於 `AdsService`，App 關閉即重置）；不動 Hive schema、不碰 KI-1。純邏輯 `shouldShowInterstitial(exportCount, shownToday, countDate, today)` 抽出單測（每 3 次出圖一次 + 每日上限 3 + 跨日重置）。(4) **ad unit ID 注入** — debug 一律 Google 官方 test unit；release 由 `--dart-define` 4 key（`ADMOB_BANNER_ANDROID` / `ADMOB_BANNER_IOS` / `ADMOB_INTERSTITIAL_ANDROID` / `ADMOB_INTERSTITIAL_IOS`，`String.fromEnvironment`）注入，**缺值 fallback test unit**（永不 crash）。純函式 `adUnitId(isDebug, isAndroid, kind, injectedId)` 單測。(5) **原生設定** — **維持現狀、不動原生**：AndroidManifest `APPLICATION_ID` 與 iOS `GADApplicationIdentifier` v1 已是**正式 App ID**（`ca-app-pub-3136608336853382~...`）、`NSUserTrackingUsageDescription` 也已在；D5 原議「設 Google 測試 App ID」前提不成立（user 對齊確認保留正式值）。(6) **可測性** — `adUnitId` / `shouldShowInterstitial` 純函式單測；`BannerAd` / `InterstitialAd` / ATT plugin 平台互動不單測（對齊 fcm_service 邊界）。**踩雷**：(a) **原生 App ID 已存在且為正式值**——D5 假設「native 無 App ID、本 step 設 test App ID」與現實相反；若照原議覆寫會把 v1 正式 App ID 改成測試值（release 還得再換回）。停下來確認後選保留不動：App ID 是 app 級、不決定測試/正式**廣告**，debug→test ad **unit** 的切換已在 Dart `adUnitId()` 處理，正確切割無須動原生。(b) **interstitial 出圖時若未備妥**（首次 / 剛 dismiss 尚未補載）→ `onImageExported` 先 `preloadInterstitial()` 並跳過本次顯示，留待下次出圖；此次 export 已 `_exportCount++`，會錯過該「每 3 次」slot（下次到第 6 次才再嘗試），Phase 1 可接受。(c) **`onImageExported` 接在「存相簿成功」與「分享完成」兩處**：`SharePlus.share` await 到系統 sheet 關閉才返回，故顯示 interstitial 時 sheet 已收，不違反「不在敏感畫面顯示」。

---

### Phase 1：上架前

- [ ] **Step 24：Crashlytics、Analytics、Error Handling**（code done，實機驗收續延後）
  - 全域 `FlutterError.onError` 與 `PlatformDispatcher.onError` 接 Crashlytics
  - 關鍵事件埋 Analytics（add_stock、create_prediction、share_image 等）
  - **驗收**：debug 故意 crash 後 Crashlytics console 收到
  - **完成紀錄**：commit `784ed81` feat + `42b4997` test（2026-05-29）。`fvm flutter analyze` 0 issue、`fvm flutter test` 220 passed（214 既有 + 6 新增：buildAnalyticsParams 純函式）。**Step 5 / 6 / 8 / 13 / 14 / 15 / 16 / 16.5 / 17 / 18 / 19 / 20 / 21 / 22 / 23 / 24 實機驗收（debug 故意 crash → Crashlytics console 收到）續延後**。開工決策最終選擇：(1) **錯誤接線** — `FlutterError.onError = recordFlutterFatalError` + `PlatformDispatcher.instance.onError = recordError(fatal:true)` 雙鉤（Flutter 3.x 官方推薦），**不**用 runZonedGuarded 包 runApp。(2) **分層** — 分兩檔 `core/crash/crash_service.dart` + `core/analytics/analytics_service.dart`，各自 top-level 單例，對齊既有 `adsService` / `fcmService`。(3) **debug 上報口徑** — `setCrashlyticsCollectionEnabled(true)` **不分 build mode**，debug crash 也上報，驗收可直接在 debug 跑。(4) **事件清單**（05-features 無指定，本 step 自訂）— `add_stock`(symbol, market)、`create_prediction`(symbol, direction=PredictionType.name)、`share_image`(template=ShareTemplate.name, method=save/share)。(5) **可測性** — `buildAnalyticsParams`（去 null、組 `Map<String,Object>`）抽純函式單測（6 cases）；Crashlytics/Analytics plugin 互動靠實機驗收（對齊 fcm/ads 邊界）。(6) **動 bootstrap** — 只在 `Firebase.initializeApp()` 後加 `await crashService.init()` 接線，**不讀任何 settings**（避開 KI-1）。**踩雷**：(a) **analyticsService 單例建構即 throw**——top-level `AnalyticsService()` 原在建構子預設參數解析 `FirebaseAnalytics.instance`，Dart top-level final 首次存取（VM 埋點呼叫）才 init → 單測無 Firebase App 時於非 async gap 同步 throw，5 個既有 VM 測試（stock / prediction）連帶紅。改為 **instance 延後解析**（`_analytics` 建構時不解析）。(b) **`unawaited` 不吞錯**——僅延後解析仍不夠：`unawaited` 只壓 lint，未處理的 async error 仍會讓 flutter_test 失敗。於 `_log` 內 `try/catch` swallow，明確定調「埋點失敗（含 Firebase 未 init / plugin 錯誤）不可中斷使用者流程」——這也是正式環境正確行為（logging 失敗不該讓 add_stock 失敗）。(c) **prediction_editor / share_preview 原無 `dart:async` import**——加 `unawaited` 後需補 `import 'dart:async';`（stock_search_view_model 已有）。

- [ ] **Step 25：Settings 頁完成**（code done，實機驗收續延後）
  - 全部設定項目（依 `05-features.md` F11）
  - 重設本地資料功能
  - 隱私權政策 / 服務條款 URL（外部連結）
  - **完成紀錄**：commit `c0fd659` fix（KI-1/KI-2）+ `66cadeb` feat + `47ba124` test（2026-05-29）。`fvm flutter analyze` 0 issue、`fvm flutter test` 222 passed（220 既有 + 2 新增：resetLocalData 純函式）。**KI-1（kSettingsBox 未開→真機 crash）+ KI-2（首次啟動不自動排程）已於開工 fix commit `c0fd659` 修好**（KNOWN-ISSUES.md 已標已修）。**本 step 設定頁讀寫 + 重設資料的實機驗收，連同 Step 5~24 既有延後項一起排。** 開工決策最終選擇：(1) **KI commit 切分** — KI-1（bootstrap 在 stocks box 後補 `await Hive.openBox(kSettingsBox)`）+ KI-2（`notificationService.init()` 後讀持久 `notificationsEnabled`，預設 true → `applyEnabled(true)` idempotent 重排）合成**單一 `fix:` commit**，與 Step 25 功能分開。(2) **不動 AppSettings schema** — 維持單一 `themeId`（= App 主題）；不新增「預設行事曆主題」欄位（既有 App 主題已透過 calendar `themeId=='default'` fallback 成為所有月曆預設，符合 Phase 1 / YAGNI）。(3) **重設範圍** — 清 `calendars` / `stocks` / `settings` 三個 box + 移除 `meta` 的待同步佇列（writes/deletes）；**保留** `onboarding_completed`（不丟回 onboarding）、**不登出**（保留匿名 UID）；`quotes` box 目前無快取實作故不在範圍。清空後 `applyEnabled(true)` 對齊預設。(4) **隱私/條款 URL** — 暫放 `kPrivacyPolicyUrl` / `kTermsOfServiceUrl` placeholder 常數 + `TODO(step26)`，先接好 `url_launcher` 與 UI，上架前再填真網址。(5) **可測性** — `resetLocalData` 抽純函式（注入 4 個 Box，side-effect on box），用真 Hive temp box 單測（清空 3 box + 保留 onboarding / 移除佇列，2 cases）；`url_launcher` / `package_info` / about dialog 等 plugin 互動靠實機驗收。**額外決策**：「我的股票管理（跳轉 F4）」不另設定頁入口——股票管理即主畫面 `StockChipsBar`（由齒輪入口進設定，再設一個導回 `/` 的 tile 屬冗餘），F11 該項由主畫面 chips bar 滿足。**踩雷**：(a) **`amend` 改 hash 導致自我參照失效**——KI fix commit 先把自身 hash 寫進 KNOWN-ISSUES.md 再 `--amend`，amend 重算 hash 使文件參照到已 orphan 的舊 hash。改為文件不寫死自身 hash（「hash 見 06-steps Step 25 完成紀錄」），由本完成紀錄統一記錄。(b) **method 名與 import 的 top-level 函式同名造成遞迴**——`SettingsController.resetLocalData()` 內呼叫 import 的 `resetLocalData(...)`，Dart 解析成呼叫自身（遞迴）→ 具名參數對不上而報錯。method 改名 `resetAllLocalData` 避開 shadowing。(c) **`quotes` box 從未 openBox**——grep 確認全專案無 `Hive.openBox(kQuotesBox)`，quote 快取尚未實作；重設若納入 `Hive.box(kQuotesBox)` 會在真機 throw（box not found）。故重設範圍排除 quotes。

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
