# 01 — 技術選型定案

## 環境

| 項目 | 版本 |
|------|------|
| Flutter | 3.41.2（透過 FVM 管理） |
| Dart | 3.x（null-safety） |
| Android minSdk | 23（Android 6.0） |
| Android targetSdk | **35（Android 15）** — Google Play 2025/8 起強制要求 |
| Android compileSdk | 35 |
| iOS deployment target | **14.0** |
| Xcode | 最新穩定版 |
| Gradle / AGP | 對齊 Flutter 3.41 預設 |

## 套件清單（pubspec.yaml）

### 狀態管理 / 架構
```yaml
hooks_riverpod: ^2.5.1
flutter_hooks: ^0.20.5
riverpod_annotation: ^2.3.5
```

### 路由
```yaml
go_router: ^14.0.0
```

### 模型 / 序列化
```yaml
freezed_annotation: ^2.4.1
json_annotation: ^4.9.0
```

### 本地儲存
```yaml
hive: ^2.2.3
hive_flutter: ^1.1.0
shared_preferences: ^2.2.0  # 簡單偏好設定（首次啟動旗標等）
```

### 網路
```yaml
dio: ^5.4.0
```

### Firebase
```yaml
firebase_core: ^3.x
firebase_auth: ^5.x
cloud_firestore: ^5.x
firebase_messaging: ^15.x
firebase_storage: ^12.x  # Phase 2 可能用，Phase 1 可不裝
firebase_analytics: ^11.x
firebase_crashlytics: ^4.x
```

### 登入
```yaml
google_sign_in: ^6.2.0
sign_in_with_apple: ^6.1.0  # iOS only
```

### 廣告
```yaml
google_mobile_ads: ^5.x
```

### 圖表
```yaml
fl_chart: ^0.68.0
```

### 圖片 / 分享
```yaml
share_plus: ^9.0.0
image_gallery_saver_plus: ^3.0.0  # 取代已停用的 image_gallery_saver
permission_handler: ^11.x
```

### 通知
```yaml
flutter_local_notifications: ^17.x
timezone: ^0.9.x
```

### 工具
```yaml
intl: ^0.19.0
uuid: ^4.4.0
device_info_plus: ^10.x  # 取代 device_info
package_info_plus: ^8.x
url_launcher: ^6.3.0
```

### dev_dependencies
```yaml
build_runner: ^2.4.0
freezed: ^2.5.0
json_serializable: ^6.8.0
riverpod_generator: ^2.4.0
hive_generator: ^2.0.1
flutter_launcher_icons: ^0.13.0
flutter_native_splash: ^2.4.0
flutter_lints: ^4.0.0
```

## 移除的舊套件（不再使用）

- ❌ `provider` → 改用 `hooks_riverpod`
- ❌ `firebase_admob` → 改用 `google_mobile_ads`
- ❌ `imgur` → 不再上傳第三方
- ❌ `keyboard_visibility` → 改用 Flutter 內建 `MediaQuery.viewInsets`
- ❌ `device_info` → 改用 `device_info_plus`
- ❌ `circular_check_box`、`circular_menu`、`simple_gesture_detector`、`auto_size_text` → 視 UI 需求再加
- ❌ 自製 fork 版 `calendar_src/` → 改用 `table_calendar: ^3.x` 官方版（功能已足夠）
- ❌ `purchases_flutter` → Phase 2 才裝（RevenueCat 新版）

## 命名與 Lint 規範

- 使用 `flutter_lints` 預設規則
- 檔案：snake_case
- Class：PascalCase
- 變數 / 函式：camelCase
- 常數：lowerCamelCase（如 `kPrimaryColor`）
- Riverpod provider：以 `Provider` / `Notifier` 後綴

## 程式碼產生

每次新增 / 修改 freezed model、Riverpod annotation、Hive adapter 後執行：

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

## CI 注意事項

- iOS 上架必須開啟 Sign in with Apple capability
- Android 簽名沿用既有 keystore（避免 Play Store 衝突）
- AdMob app ID 寫在 `AndroidManifest.xml` / `Info.plist`（用 `--dart-define` 或 `.env` 分環境）
