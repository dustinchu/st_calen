# 02 — 架構與目錄結構

## 整體架構：MVVM + Feature-based + Repository Pattern

```
┌──────────────────────────────────────────────┐
│              View（Widget）                   │  ← flutter_hooks 處理 local UI state
└────────────────┬─────────────────────────────┘
                 │ watch / read
                 ▼
┌──────────────────────────────────────────────┐
│      ViewModel（Riverpod Notifier）           │  ← 業務邏輯、UI state
└────────────────┬─────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────┐
│            Repository                         │  ← 資料來源協調、降級策略
└──────┬──────────────────┬─────────────┬──────┘
       │                  │             │
       ▼                  ▼             ▼
┌─────────────┐  ┌──────────────┐  ┌──────────────────┐
│  Local      │  │  Firestore   │  │  Stock API       │
│  (Hive)     │  │  (Firebase)  │  │  (wisplu)        │
└─────────────┘  └──────────────┘  └──────────────────┘
```

### 資料流原則

1. **本地優先**：所有讀取先打 Hive，立即回 UI
2. **背景同步**：有網路時 Repository 同步 Firestore，更新 Hive，UI 自動 rebuild
3. **降級策略**：股價 API 失敗 → 回傳 `null`，ViewModel 處理「請手動輸入」UX
4. **單向資料流**：View → ViewModel → Repository → Data Source（不反向呼叫）

### Local Data Source 契約（Step 7 決議）

所有 `*_local_ds.dart` 遵守以下薄層規則，Repository 在此基礎上組合：

- **建構**：constructor 注入 `Box<dynamic>`（沿用 Step 4 `<dynamic> + as T` 模式，因 freezed 對外 expose public class，但 hive_generator 產 `_$XxxImpl` adapter）。各 DS 另提供 `static Future<Box<dynamic>> openBox()` factory 給 app 啟動端使用。
- **回傳型別**：mutation / query method 一律 `Future<Result<T, AppError>>`。Hive 例外包成 `UnknownError(e.toString())`；找不到 key 回 `NotFoundError`。**不**在 DS 層落地預設值（如 SettingsLocalDs 第一次讀 → `NotFoundError`，由 Repository 決定預設值來源）。
- **Watch stream**：回 raw `box.watch().map(...)`，型別 `Stream<T?>`（null = 已刪除）。**不**包 `Result`、**不**自動 emit 初始值。呼叫端（Repository）負責用 `get()` 補初始值後再接 watch stream，合成一條 hot stream 給 ViewModel。
- **過濾策略**：跨 entity 過濾（如 `watchByStock`）在 DS 層用 key prefix 過濾；排序、聚合留給 Repository / ViewModel。

## 目錄結構

```
lib/
├── main.dart                       # 入口，初始化 Firebase / Hive / AdMob
├── app/
│   ├── app.dart                    # MaterialApp + ProviderScope
│   ├── router.dart                 # go_router 設定
│   ├── theme/
│   │   ├── app_theme.dart          # MaterialApp 主題（深 / 淺）
│   │   └── calendar_themes.dart    # 行事曆視覺主題定義
│   └── bootstrap.dart              # 啟動初始化流程
│
├── core/
│   ├── network/
│   │   ├── dio_client.dart         # dio instance + interceptors
│   │   └── api_exception.dart
│   ├── storage/
│   │   ├── hive_boxes.dart         # box 名稱常數 + open helper
│   │   └── hive_init.dart          # 註冊 adapter
│   ├── firebase/
│   │   ├── firebase_init.dart
│   │   ├── auth_service.dart       # 匿名 / Google / Apple 登入
│   │   ├── fcm_service.dart        # token 取得 + 本地排程
│   │   └── analytics_service.dart
│   ├── ads/
│   │   └── ads_service.dart        # AdMob 初始化 / 載入
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── price_utils.dart        # 漲跌幅計算、漲跌停判定
│   │   └── result.dart             # Result<T> 封裝（success / failure）
│   └── constants/
│       └── app_constants.dart
│
├── data/
│   ├── models/                     # freezed models
│   │   ├── prediction.dart
│   │   ├── calendar_doc.dart       # 一份月曆預測整體
│   │   ├── stock.dart
│   │   ├── quote.dart
│   │   ├── prediction_type.dart    # enum: upLimit / downLimit / customPrice / customPercent / bullish / bearish
│   │   └── theme_id.dart
│   ├── repositories/
│   │   ├── calendar_repository.dart
│   │   ├── stock_repository.dart
│   │   ├── quote_repository.dart   # 含降級邏輯
│   │   ├── auth_repository.dart
│   │   └── settings_repository.dart
│   └── sources/
│       ├── local/
│       │   ├── calendar_local_ds.dart
│       │   ├── stock_local_ds.dart
│       │   └── settings_local_ds.dart
│       ├── remote/
│       │   ├── calendar_firestore_ds.dart
│       │   └── device_firestore_ds.dart  # FCM token
│       └── stock_api/
│           ├── stock_api_client.dart     # dio 包裝
│           └── stock_api_dtos.dart
│
├── features/
│   ├── auth/
│   │   ├── view/
│   │   │   └── login_sheet.dart
│   │   └── viewmodel/
│   │       └── auth_view_model.dart
│   ├── calendar/                          # 主畫面（取代舊 home）
│   │   ├── view/
│   │   │   ├── calendar_screen.dart
│   │   │   ├── stock_picker.dart
│   │   │   └── title_bar.dart
│   │   ├── viewmodel/
│   │   │   └── calendar_view_model.dart
│   │   └── widgets/
│   │       ├── prediction_cell.dart
│   │       └── day_legend.dart
│   ├── prediction/
│   │   ├── view/
│   │   │   └── prediction_editor_sheet.dart
│   │   └── viewmodel/
│   │       └── prediction_view_model.dart
│   ├── stock/                              # 股票管理
│   │   ├── view/
│   │   │   └── stock_manager_screen.dart
│   │   └── viewmodel/
│   │       └── stock_view_model.dart
│   ├── theme_picker/
│   │   ├── view/
│   │   │   └── theme_picker_screen.dart
│   │   └── viewmodel/
│   │       └── theme_picker_view_model.dart
│   ├── share_image/
│   │   ├── view/
│   │   │   ├── share_preview_screen.dart
│   │   │   └── templates/
│   │   │       ├── full_calendar_template.dart
│   │   │       ├── single_day_template.dart
│   │   │       └── report_card_template.dart
│   │   └── viewmodel/
│   │       └── share_image_view_model.dart
│   ├── accuracy_report/
│   │   ├── view/
│   │   │   └── report_screen.dart
│   │   └── viewmodel/
│   │       └── report_view_model.dart
│   ├── settings/
│   │   ├── view/
│   │   │   └── settings_screen.dart
│   │   └── viewmodel/
│   │       └── settings_view_model.dart
│   └── onboarding/
│       └── view/
│           └── onboarding_screen.dart
│
└── shared/
    ├── widgets/
    │   ├── primary_button.dart
    │   ├── loading_overlay.dart
    │   ├── error_view.dart
    │   └── empty_state.dart
    └── ui/
        └── spacing.dart
```

## 命名規則

| 類型 | 命名 | 範例 |
|------|------|------|
| View（畫面） | `*Screen` / `*Sheet` | `CalendarScreen`, `PredictionEditorSheet` |
| ViewModel | `*ViewModel` | `CalendarViewModel` |
| Repository | `*Repository` | `CalendarRepository` |
| Data source | `*LocalDs` / `*RemoteDs` | `CalendarLocalDs` |
| Provider 變數 | `*Provider` | `calendarViewModelProvider` |
| Hive box | snake_case | `'calendars'`, `'stocks'`, `'settings'` |

## Riverpod 風格

- **優先使用 `@riverpod` 註解產生 provider**（搭配 riverpod_generator）
- ViewModel 用 `@riverpod class XxxViewModel extends _$XxxViewModel`
- 純資料 provider 用 `@riverpod Future<T> xxx(Ref ref) async {...}`
- `AsyncValue<T>` 處理 loading / error / data 三態

## 錯誤處理

- 使用 `Result<T, AppError>`（在 `core/utils/result.dart`）
- 網路層丟 `ApiException`，Repository 轉成 `Result.failure(AppError.network)`
- ViewModel 把 `Result` 轉成 `AsyncValue`
- View 用 `.when(data, loading, error)` 渲染

## 測試策略

| 層 | 測試類型 | 工具 |
|----|---------|------|
| Repository | unit test（mock data source） | `mocktail` |
| ViewModel | unit test（mock repository） | `mocktail` + `ProviderContainer` |
| Widget | widget test（golden 可選） | `flutter_test` |
| 整合 | smoke test（主流程） | `integration_test` |

最低目標：repository + viewmodel 70% 覆蓋率。
