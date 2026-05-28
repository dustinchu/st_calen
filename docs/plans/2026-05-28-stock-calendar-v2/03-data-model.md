# 03 — 資料模型

## Freezed Models（Dart）

### PredictionType (enum)

```dart
enum PredictionType {
  upLimit,        // 漲停
  downLimit,      // 跌停
  customPrice,    // 自訂價
  customPercent,  // 自訂漲跌幅 %
  bullish,        // 看多（無數字）
  bearish,        // 看空（無數字）
}
```

### Prediction

```dart
@freezed
class Prediction with _$Prediction {
  const factory Prediction({
    required DateTime date,              // 只取日期部分（UTC 00:00）
    required PredictionType type,
    double? price,                       // customPrice 時必填
    double? percent,                     // customPercent 時必填
    String? note,                        // 備註
    @Default(false) bool settled,        // 是否已結算
    double? actualClose,                 // 實際收盤價（API 或手動補）
    double? hitPercent,                  // 命中偏差 %
  }) = _Prediction;

  factory Prediction.fromJson(Map<String, dynamic> json) =>
      _$PredictionFromJson(json);
}
```

### Stock

```dart
@freezed
class Stock with _$Stock {
  const factory Stock({
    required String symbol,    // "2330.TW" / "AAPL"
    required Market market,    // tw / us
    required String name,
    String? sector,
  }) = _Stock;

  factory Stock.fromJson(Map<String, dynamic> json) =>
      _$StockFromJson(json);
}

enum Market { tw, us }
```

### CalendarDoc（一份月曆 = 一支股票 × 一個月的預測集合）

```dart
@freezed
class CalendarDoc with _$CalendarDoc {
  const factory CalendarDoc({
    required String id,                 // uuid
    required String userId,
    required String symbol,             // 2330.TW
    required int year,
    required int month,
    required String title,              // "台積電 6 月預測"
    required String themeId,
    @Default([]) List<Prediction> predictions,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CalendarDoc;

  factory CalendarDoc.fromJson(Map<String, dynamic> json) =>
      _$CalendarDocFromJson(json);
}
```

### Quote

```dart
@freezed
class Quote with _$Quote {
  const factory Quote({
    required String symbol,
    required DateTime date,
    required double close,
    double? open,
    double? high,
    double? low,
    double? changePercent,
  }) = _Quote;

  factory Quote.fromJson(Map<String, dynamic> json) =>
      _$QuoteFromJson(json);
}
```

### AppSettings

```dart
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default('def') String themeId,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool autoSettleEnabled,
    String? lastSelectedSymbol,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
```

---

## Hive Box 設計

| Box 名稱 | Key | Value type | 用途 |
|---------|-----|-----------|------|
| `calendars` | `"$symbol:$yyyy-MM"` | `CalendarDoc` | 月曆預測資料 |
| `stocks` | `symbol` (String) | `Stock` | 用戶追蹤股票清單 |
| `quotes` | `"$symbol#$yyyy-MM-dd"` | `Quote` | 股價快取（API 結果） |
| `settings` | `'app'` | `AppSettings` | 應用設定 |
| `meta` | 字串 keys | dynamic | 雜項（首次啟動、版本、上次同步時間） |

> **CalendarDoc local key 設計（Step 7 決議）**：本地 Hive box 採 composite key `"$symbol:$yyyy-MM"`（例 `"2330.TW:2026-06"`），讓 `get(symbol, year, month)` 直接 `box.get(key)`、`watchByStock` 用 `key.startsWith("$symbol:")` 過濾，O(1) 命中主要查詢路徑。
>
> `CalendarDoc.id`（uuid）保留在 value 欄位內，作為 **Firestore document id**（路徑 `/users/{uid}/calendars/{calendarId}`）。Step 9 Repository 同步時：本地 → 遠端用 `doc.id`，遠端 → 本地用 composite key。兩個命名空間獨立、互不衝突。

### Hive TypeId 配置（避免衝突）

```
0: PredictionType
1: Prediction
2: Market
3: Stock
4: CalendarDoc
5: Quote
6: AppSettings
```

---

## Firestore Schema

### `/users/{uid}`

```json
{
  "createdAt": Timestamp,
  "lastSeenAt": Timestamp,
  "platform": "ios" | "android",
  "appVersion": "2.0.0",
  "isAnonymous": true,
  "linkedProviders": ["google.com", "apple.com"]
}
```

### `/users/{uid}/calendars/{calendarId}`

```json
{
  "symbol": "2330.TW",
  "year": 2026,
  "month": 6,
  "title": "台積電 6 月預測",
  "themeId": "dark",
  "predictions": [
    {
      "date": "2026-06-01",
      "type": "upLimit",
      "price": null,
      "percent": null,
      "note": "法說會前一天",
      "settled": false,
      "actualClose": null,
      "hitPercent": null
    }
  ],
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

> ⚠️ predictions 用 array 而非 sub-collection，因為一個月最多 31 筆，整批讀寫成本低。

### `/users/{uid}/devices/{deviceId}`

```json
{
  "fcmToken": "xxx",
  "platform": "ios" | "android",
  "appVersion": "2.0.0",
  "updatedAt": Timestamp
}
```

`deviceId` 用 `device_info_plus` 取得（iOS: identifierForVendor / Android: androidId）。

### `/users/{uid}/watched_stocks/{symbol}`

```json
{
  "symbol": "2330.TW",
  "market": "tw",
  "name": "台積電",
  "addedAt": Timestamp
}
```

---

## Firestore Security Rules（草案）

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;

      match /{collection}/{docId} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
    }
  }
}
```

---

## 同步策略

### 寫入流程
1. 用戶編輯預測 → ViewModel 立即寫 Hive
2. UI 即時更新（從 Hive watch）
3. 若有網路 → Repository 異步寫 Firestore；失敗則放入待同步佇列（`meta` box）
4. App 啟動 / 網路恢復時清算待同步佇列

### 讀取流程
1. ViewModel 先讀 Hive
2. 若 Hive 無資料 且 已登入 → 從 Firestore 拉取 → 寫入 Hive
3. 之後永遠以 Hive 為唯一真實來源（single source of truth）

### 衝突處理
- 採 last-write-wins（用 `updatedAt` 判斷）
- 同一個月份的 CalendarDoc 不會多裝置同時改的機率極低，先不做 CRDT
