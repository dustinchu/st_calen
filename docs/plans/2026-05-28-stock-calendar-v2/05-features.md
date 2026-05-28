# 05 — 各功能詳細說明

---

## F1. Auth（登入 / 帳號）

### UX
- App 第一次啟動 → 直接匿名登入，無任何登入畫面阻擋
- 在「設定」頁面顯示「綁定帳號以跨裝置同步」
- 第一次完成出圖分享後，顯示一次性 dialog 提示綁定

### 技術
- `firebase_auth.signInAnonymously()`
- 綁定：`linkWithCredential` —— UID 不變，所有 Firestore 資料無痛延續
- Android：匿名 + Google
- iOS：匿名 + Apple（必須）+ Google

### 邊界
- 已綁定帳號用戶不再顯示綁定提示
- 登出：清空本地 Hive、回到匿名（提示用戶資料會留在雲端，下次登入可拉回）

---

## F2. Calendar 主畫面

### UX
- 頂部：選擇股票（chips 或下拉，預設顯示上次選擇）
- 中間：月曆（`table_calendar` 套件）
- 每日格子顯示：
  - 預測類型 icon（↑ 漲停 / ↓ 跌停 / 自訂價 / % / 多 / 空）
  - 命中與否染色（綠 ✓ / 紅 ✗ / 灰 未結算）
- 點擊日期 → 彈出 `PredictionEditorSheet`
- 底部：固定 AdMob banner
- 右下角 FAB：「產生分享圖」

### 技術
- ViewModel watch 當前股票 + 月份的 `CalendarDoc` (Hive)
- 切換月份 → 同步呼叫 `/quotes/{symbol}/range` 預取整月實際價
- 滾動順暢度：用 `RepaintBoundary` 包月曆 cell

---

## F3. Prediction Editor（預測編輯）

### UX
- 彈出 ModalBottomSheet
- 預測類型分頁切換：漲停 / 跌停 / 自訂價 / 自訂% / 看多 / 看空
- 自訂價：數字鍵盤
- 自訂%：±50 拖曳條 + 數字輸入
- 備註：選填文字
- 已結算的日期顯示「實際收盤：1195（命中 +0.42%）」

### 技術
- ViewModel 接收 `(symbol, date)`，從 Hive 拿既有 `Prediction`
- 儲存時：寫 Hive → 同步 Firestore → 更新整個 `CalendarDoc.updatedAt`

### 邊界
- 美股無漲跌停 → 「漲停 / 跌停」按鈕改為「強漲 / 強跌」（純標籤，無實際 ±10% 限制）
- 假日 / 週末 → 仍可填預測（純娛樂，不限制）

---

## F4. Stock Management（股票管理）

### UX
- 「設定 → 我的股票」清單
- 新增：彈出搜尋頁，輸入代號或名稱 → 打 `/api/v1/stocks/search`
- 拖曳排序
- 滑動刪除

### 技術
- `stocks` Hive box + Firestore `watched_stocks` 雙寫
- 搜尋結果快取 30 秒（避免快速輸入瘋狂打 API）

---

## F5. Stock Quote & Settlement（股價與結算）

### 結算邏輯
- 每次打開月曆 / 月份切換 / 下拉刷新時觸發
- 對該月所有「日期已過 + 未結算」的 prediction：
  1. 從 Hive `quotes` box 找
  2. 找不到 → 打 `/quotes/{symbol}/range?from=...&to=...`
  3. 仍失敗 → 標記 `needsManualInput`，UI 顯示「點我手動補」
- 取得 `actualClose` 後計算 `hitPercent`：
  - 漲停：`actualClose / 昨收 - 1` ≥ 對應市場漲停閾值 → 命中
  - 自訂價：`|actual - predicted| / actual` < 1% → 命中
  - 自訂%：實際漲跌幅與預測差距 < 0.5pp → 命中
  - 看多 / 看空：actual 漲為命中（多）/ actual 跌為命中（空）

### 手動輸入
- 點擊「手動補」→ 輸入收盤價 → 寫 Hive `quotes` box（source 標記 `manual`）→ 觸發結算

---

## F6. Share Image（出圖分享）

### 三個版型

#### 6.1 整月行事曆（Full Calendar）
- 9:16 / 1:1 / 4:5（Threads / IG / FB）三種比例切換
- 取當前月曆畫面 + 標題 + 股票 + 浮水印
- `RepaintBoundary` + `toImage()`

#### 6.2 單日預測卡片（Single Day Card）
- 適合「明天台積電我看漲停 🚀」這種即時發文
- 大字凸顯預測類型 + 日期 + 股票
- 內建幾個梗圖背景（火箭、熊、海綿寶寶等可選）

#### 6.3 月度準度報告（Report Card）
- 月底 / 月初分享用
- 命中率、最神準預測、總漲跌
- 適合「神算 KOL」自嗨用

### 流程
1. 用戶點 FAB → `ShareImagePreviewScreen`
2. 上方預覽切換版型 + 比例
3. 下方按鈕：「儲存到相簿」「分享」
4. 「分享」呼叫 `share_plus` 系統 share sheet
5. 完成後選擇性顯示 AdMob interstitial（控制頻率：每 3 次出圖才顯示一次）

### 技術
- `image_gallery_saver_plus` 寫相簿（先請求 `Permission.photos`）
- 不上傳雲端（Phase 1）

---

## F7. Accuracy Report（準度報告）

### UX
- Tab：本月 / 近 3 月 / 全部
- 卡片：總預測數、命中數、命中率、最佳股票
- 圖表（fl_chart）：每月命中率折線圖
- CTA：「分享我的成績」→ 跳到 `ShareImage` 的 report card 版型

### 技術
- ViewModel 從 Hive 所有 `CalendarDoc` 聚合計算
- 計算結果快取在 `meta` box（key: `report_cache_yyyyMM`）

---

## F8. Theme（行事曆主題）

### Phase 1 內建主題
1. **def**（淺色預設）
2. **dark**（深色）
3. **redgreen**（財經紅綠：漲紅跌綠，台股風格）
4. **minimal**（極簡黑白）
5. **meme**（迷因風：強烈對比 + 表情符號）

### 技術
- `app/theme/calendar_themes.dart` 內 Map 定義所有主題色碼
- `themeId` 存在 `AppSettings` + 每個 `CalendarDoc`（一份月曆可以鎖定主題）
- 切換主題立即 rebuild

---

## F9. Ads（廣告）

### Phase 1
- **Banner**：首頁底部固定
- **Interstitial**：出圖完成後可選顯示，頻率上限「每用戶每天最多 3 次」+「每 3 次出圖才一次」

### 技術
- `google_mobile_ads` 初始化於 `bootstrap.dart`
- Test ad unit ID 在 debug，正式 ID 從 `--dart-define` 注入
- iOS 14.5+ 需要 ATT 權限提示（`app_tracking_transparency`）—— 用戶拒絕仍可顯示非個人化廣告

### 廣告政策注意
- 不在敏感畫面（編輯 / 結算）顯示 interstitial
- 不點擊誘餌，banner 與 UI 之間留至少 8dp 邊距

---

## F10. Notifications（通知）

### Phase 1（本地）
- 每日 14:30（台股收盤前）提醒：「該回填今日預測結果」（如果有未結算）
- 結算完成後本地通知：「今日命中 X 檔！」
- 用 `flutter_local_notifications` + `timezone`

### FCM Token（為 Phase 2 後端推播預留）
- 啟動時取 token
- 寫入 Firestore `/users/{uid}/devices/{deviceId}`
- 監聽 `onTokenRefresh` 自動更新
- Phase 1 **不發送**任何遠端推播

---

## F11. Settings（設定）

### 項目
- 帳號狀態 / 綁定
- 通知開關
- 自動結算開關
- 主題選擇（App 主題 + 預設行事曆主題）
- 我的股票管理（跳轉 F4）
- 關於 / 版本 / 隱私權政策 / 服務條款
- 「重設本地資料」（清 Hive）
- Phase 2 才有：「升級訂閱」入口

---

## F12. Onboarding

### 流程
- 首次啟動 3 頁滑動介紹：
  1. 預測股價
  2. 多風格行事曆
  3. 一鍵出圖分享
- 最後一頁「開始使用」→ 進入主畫面（背景已完成匿名登入）

寫入 `meta` box `onboarding_completed = true`，之後不再顯示。
