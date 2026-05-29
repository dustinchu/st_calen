# 08 — UI/UX 改版（Visual Revamp）

> 建立：2026-05-29
> 前置：Step 1–25 已完成（功能與資料層齊全），Step 26–28 為上架。
> **本改版插在 Step 26（上架資源）之前**——先把視覺定稿，截圖才有得拍、icon/splash 才有依據。
> 步驟編號用 **`Step U1 ~ Un`**（U = UI），與 06-steps 的 1–28 不撞號。
> 文件慣例（commit / 完成紀錄 / 決策 / 踩雷 / DoD）完全沿用 [06-steps.md](./06-steps.md)。

---

## 0. 為什麼有這份文件（背景）

設計階段用 **Stitch** 產了一組高保真畫面（`stitch_stock_market_calendar_v2/`，11 張 `_1~_11` + `DESIGN.md`）。盤點後的關鍵結論：

1. **現有程式碼（Step 1–25）已經乾淨、功能完整、且符合產品定位。** AI 報明牌 / Premium / PRO / 帳面損益 / 即時報價 這些字眼**只存在於 Stitch 圖裡，程式碼一個都沒有**。Onboarding 已是「你來預測」、自選股不顯示報價、`flat` 平盤已存在、編輯頁已有結算結果＋手動補價、三種分享版型＋fl_chart 都做好了。
2. 因此**本次是「視覺改造（restyle / re-theme）」，不是改功能、不是改文案邏輯**。
3. Stitch 的**美術方向（深色 OLED + 玻璃擬態 + 高對比 + 可截圖分享感）很好，要採納**；但它**自己加的「法說會 / 除息 / Fed 事件流」「AI 預測」「Premium」不在 v2 範圍，一律不做**（見 §6 範圍排除）。

### 與 user 已拍板的 4 個產品定位決策（不可違背）

| 決策 | 結論 |
|---|---|
| AI 定位 | **全移除** AI/大數據字眼，文案聚焦「你來預測、你的準度」 |
| Phase 1 付費 | **全移除** Premium/PRO/升級 |
| 範圍 | **拉回純預測準度**——不做帳面損益、不做即時報價、不顯示持股 |
| 漲跌顏色 | **台股紅漲綠跌 ＋ 命中狀態另用色（金色）**（見 §2） |

> ⚠️ 程式碼目前本就沒有違規字眼，所以這 4 個決策對本改版主要是**「改視覺時不要把 Stitch 的違規元素帶進來」**的防線，不是大規模刪字工程。

---

## 1. 設計總綱

- **美學基調**：深色 OLED 為預設、玻璃擬態（backdrop blur）資料卡、高對比市場訊號、可截圖分享的社群感。出處：`stitch_stock_market_calendar_v2/DESIGN.md`（color tokens / typography / spacing / elevation 已整理好，**直接當實作依據**）。
- **字體**：主介面 **Noto Sans TC**（繁中可讀性）、數字/代號 **Inter**（tabular）。避免 light weight，UI 要「厚實、響亮」。
- **形狀**：卡片/按鈕/sheet 16px 圓角（rounded-lg）、chips pill 形、日曆 cell 8px 圓角。
- **深度**：tonal layer + 1px 邊或 10% 白疊加，少用陰影；modal sheet 用 backdrop blur 保留月曆背景；meme 主題改用 2px 實邊 + 硬陰影（neo-brutalist）。

### Design token 對照（DESIGN.md → 實作）

| 類別 | 取值來源 | 落地位置 |
|---|---|---|
| 色票 | DESIGN.md `colors:`（surface/primary/secondary/tertiary…） | `lib/app/theme/` 新增 token 檔 + `ColorScheme` |
| 字級 | DESIGN.md `typography:`（display-bold 32 / headline / body / data-heavy…） | `TextTheme` + 自訂 `TextStyle` |
| 圓角 | DESIGN.md `rounded:` | token 常數 |
| 間距 | DESIGN.md `spacing:`（4px base, margin 16） | token 常數 |

---

## 2. 色彩語意系統（★ 最關鍵，所有畫面共用）

採「**三軸分離**」，讓「市場方向」與「命中狀態」永不撞色。**這是整套能不能被讀懂的核心，任何畫面都不得違反。**

### 軸一：市場方向（台股慣例）
| 語意 | 顏色 | 套用處 |
|---|---|---|
| 漲 / 看多 | 🔴 紅 `#FF3B30` | `upLimit ↑`、`bullish`、收盤價上漲、`customPercent` 正值 |
| 跌 / 看空 | 🟢 綠 `#34C759` | `downLimit ↓`、`bearish`、收盤價下跌、`customPercent` 負值 |
| 平 | ⚪ 灰 `#757575` | `flat —` |
| 中性（非方向） | 🔵 藍 `#4D8EFF` | `customPrice`（自訂價無方向）、導航、主按鈕 |

### 軸二：命中狀態（結算結果）— **命中用金色，不可用綠**
| 語意 | 顏色 / 視覺 | 套用處 |
|---|---|---|
| 命中 hit | 🟡 金 `#FFB300` + ✓ 徽章 | 日曆 cell 右上角徽章、編輯頁結算 chip、報告卡 |
| 未命中 miss | 灰 `#8C909F` + ✗ 徽章（**不用紅**） | 同上 |
| 未結算 unsettled | 淡灰空心圈 / 30% opacity | 過去日未補價 |
| 未來日 / 無預測 | 不上任何狀態色 | — |

> **為什麼命中用金色**：綠色已被「跌」佔用，命中若用綠會與「跌停命中」語意打架。金色＝「你猜中了」的慶祝感，且與紅/綠完全分離。
> **為什麼 miss 不用紅**：紅已被「漲」佔用。miss 用中性灰 + ✗，避免「漲」與「沒猜中」混淆。

### 落地方式（重要架構決策，U2 處理）
- **日曆 cell 不再用整格底色編碼命中**（現況 `hitCellBg`=綠 / `missCellBg`=紅 會撞軸一）。改為：
  - cell 底色 → 中性 / 主題色（弱）
  - **命中狀態用右上角小徽章**（金✓ / 灰✗ / 空心圈）
  - **預測類型用既有 markerBuilder icon**（依軸一上色）
- 把語意色抽成 `ThemeExtension`（如 `SemanticColors`），每個主題各自提供，畫面一律讀 extension 不寫死。

---

## 3. 主題系統重構（U3）

### 現況
`lib/app/theme/calendar_themes.dart` 有 5 套**淺色**：`default`(藍) / `warm`(橘) / `cool`(藍綠) / `mono`(灰) / `nature`(綠)，每套 = seed + monthBackground + hit/miss/unsettled cellBg，靠 `ColorScheme.fromSeed` 衍生。

### 目標（對齊 Stitch + 我們的決策）
深色為預設，5 套主題重新定義為：

| id | 名稱 | 風格 | 來源參考 |
|---|---|---|---|
| `dark` | 暗夜（**新預設**）| OLED 黑底 + 玻璃卡 + 藍主色 | Stitch `_1/_5`、DESIGN.md |
| `light` | 晴天 | 淺色乾淨現代（保留給偏好淺色者）| — |
| `redgreen` | 紅綠 | 財經紅漲綠跌強對比 | Stitch `_6` |
| `minimal` | 極簡 | 黑白線條、留白、近無彩 | Stitch `_7` |
| `meme` | 迷因 | 高對比 + 2px 實邊 + 硬陰影 + emoji | Stitch `_8` |

### 開工須對齊決策（U3 kickoff）
1. **主題 id 命名**：沿用舊 id（default/warm/cool/mono/nature）改義，還是改成新 id（dark/light/...）？舊 id 已寫入既有 `AppSettings.themeId` / `CalendarDoc.themeId`（裝置上可能有 `'def'`/`'default'`）。建議：**新增 id + `byId` 對舊 id 做 fallback 映射**（`'default'`/`'def'` → `dark` 或 `light`，需 user 定），不破壞 Hive 既有值。
2. **預設主題**：新裝置預設 `dark`？（Stitch 預設深色）
3. **每個主題要提供的 token 集**：seed/surface 階層/`SemanticColors`（軸一軸二全色）/monthBackground/cell 樣式。
4. **meme 主題的 neo-brutalist 樣式**怎麼在 ThemeExtension 表達（邊框寬、陰影 offset）。

### 注意
- `CalendarThemes.byId` 既有 unknown→fallback 邏輯要保留並擴充舊 id 映射（見 Step 17 踩雷：`'def'` vs `'default'` 已靠 fallback 吸收）。
- App 層 `ThemeData`（`app_theme.dart`）目前用 `ColorScheme.fromSeed`；深色主題要確認 `Brightness.dark` 並覆寫 surface 階層為 DESIGN.md 的具體值（fromSeed 自動衍生的深色不夠「OLED 黑」）。

---

## 4. 導航架構（U4）

### 現況
**無底部導航**。`router.dart` 4 條獨立 route：`/`(calendar) `/onboarding` `/settings` `/report`；從 calendar AppBar 的 icon `context.push`。AdsBanner 只掛在 CalendarScreen 的 `bottomNavigationBar`。無 FAB（點 cell 直接編輯）。

### 目標（對齊 Stitch）
4 tab 底部導航：**日曆 / 勝率 / 自選 / 設定**（Stitch `_5/_6/_7/_10` 一致）。calendar 右下 **FAB「產生分享圖」**。

### 開工須對齊決策（U4 kickoff）
1. **導航實作**：`go_router` 的 `StatefulShellRoute.indexedStack`（保留各 tab 狀態）？還是簡單 `Scaffold + NavigationBar` + `IndexedStack`？建議前者（官方、URL 保真、各 tab keep state）。
2. **「自選」獨立成 tab**：現在自選股是主畫面頂部 `StockChipsBar`（Step 25 決策：股票管理＝主畫面 chips，不另設頁）。Stitch 把「自選」做成獨立 tab（含清單 + 搜尋）。**需 user 拍板**：
   - (A) 維持 chips 在月曆頂部，底部 tab「自選」＝完整管理頁（清單/拖曳/刪除/搜尋）；兩者並存。
   - (B) 移除頂部 chips，全部收進「自選」tab。
   - 建議 (A)：月曆頂部 chips 是快速切換，自選 tab 是管理，職責不同。
3. **AdsBanner 位置**：底部 nav 之上、仍只在「日曆」tab 顯示？還是全 tab？（廣告政策：不在敏感畫面。建議只日曆 tab，banner 疊在 NavigationBar 上方。）
4. **FAB**：取代現有 AppBar 的 `ios_share` icon？還是並存？建議 FAB 為主、AppBar 出圖 icon 移除（避免重複）。
5. **AppBar icons 去留**：現有 AppBar 有 準度報告/分享/主題/設定 四顆 icon——準度報告與設定改由底部 tab 進入後，AppBar 只留「主題切換」(palette)，其餘移除。

### 注意
- router redirect（onboarding 未完成）邏輯要保留。
- 既有 `context.push('/report')` / `context.push('/settings')` 的呼叫點（calendar_screen、accuracy_report CTA）改走 shell branch。

---

## 5. Stitch 圖 ↔ 現有檔案 對照表

| Stitch | 畫面 | 對應現有檔案 | 採納 / 捨棄 |
|---|---|---|---|
| `_1` | 月曆主畫面（暗）| `features/calendar/view/calendar_screen.dart` + `widgets/calendar_month_view.dart` | 採玻璃感/chips 帶 trend dot；**捨「今日重點」事件流**（§6）；補底部 nav |
| `_5` | 月曆（OLED 緊湊）| 同上 | 採底部 nav 配置；捨「To the Moon!」事件卡 |
| `_6` | 月曆（紅綠 + 命中徽章）| 同上 + `prediction_visual.dart` | **採命中徽章 + 方向箭頭**做法（最接近 §2）；捨 PRO/事件卡 |
| `_7` | 月曆（極簡）| 同上 | 採 minimal 主題視覺；捨 ACTIVE TRADES（§6） |
| `_8` | 月曆（meme）| 同上 | 採 meme neo-brutalist 視覺；**捨「帳面上漲 +24.5%」**（改「本月勝率」） |
| `_2` | 預測編輯 | `features/prediction/view/prediction_editor_sheet.dart` | 採玻璃 sheet + tab；補 `flat` tab 已在；自訂% 滑桿改 ±50；捨內嵌電路板「IG preview」 |
| `_3` | 勝率報告 | `features/accuracy_report/view/accuracy_report_screen.dart` | 採大數字 hero + 玻璃卡 + 折線；既有結構已對齊 |
| `_4` | 分享預覽 | `features/share_image/view/share_preview_screen.dart` + `templates/*` | **最強，幾乎照搬**；版型/比例/單日卡/分享儲存皆已對齊 |
| `_9` | 自選 + 搜尋 | `features/stock/view/stock_chips_bar.dart` + `stock_search_sheet.dart` | 採搜尋分頁（台股/美股/ETF）；**捨即時報價數字**（§6） |
| `_10` | 設定 | `features/settings/view/settings_screen.dart` | 採分區卡片視覺；**捨 Premium 徽章/頭像幻想**；補隱私權已在 |
| `_11` | Onboarding | `features/onboarding/view/onboarding_screen.dart` | 採插圖/排版；**文案維持現有「你來預測」**（勿用 Stitch 的 AI 文案） |

---

## 6. 範圍排除（明確不做）

- ❌ **股市事件流**（法說會 / 除息 / Fed 利率決策 / 熱門標的 / 警示事件）——Stitch `_1/_6/_8` 的「今日重點/當日關鍵事件」。v2 是「個人預測筆記本」，不是事件行事曆。Phase 2 再議。
- ❌ **AI 預測 / 大數據推估**任何字眼或視覺。
- ❌ **Premium / PRO / 升級**任何字眼或入口。
- ❌ **帳面損益 / 報酬率 / 持股 / 即時報價跑馬燈**。「帳面上漲 +24.5%」一律改為「本月勝率 X%」。
- ❌ 不改資料模型、不改結算邏輯、不改 repository（純視覺層）。如某步驟發現非動 model/schema 不可，**停下來問 user**（沿用既有 step workflow）。

---

## 7. 步驟（Step U1 ~ U12）

> 每步 = 一個 session。開工貼 §開工模板。每步結束：勾 checkbox + 寫完成紀錄（commit hash / analyze / test / 決策 / 踩雷）+ commit/push。
> **純視覺步驟的測試**：多數改動是 widget 樣式，難純函式測；以 `fvm flutter analyze` 0 issue + 既有 test 不破 + **實機/模擬器截圖驗收** 為主。能抽純函式（如色彩映射、主題 fallback）的就抽並測。

### 基礎層

- [x] **Step U1：Design tokens + 全域 ThemeData 改造（深色基底）**
  - 新增 `lib/app/theme/design_tokens.dart`：DESIGN.md 的色票 / 字級 / 圓角 / 間距常數。
  - `pubspec.yaml` 加字體 Noto Sans TC + Inter（或用 `google_fonts`，開工決定）。
  - `app_theme.dart`：`TextTheme` 套 DESIGN.md typography；深色 `ColorScheme` 覆寫 surface 階層為 OLED 值（非 fromSeed 自動衍生）。
  - **觸碰**：`lib/app/theme/design_tokens.dart`(新) `lib/app/theme/app_theme.dart` `lib/app/app.dart` `pubspec.yaml`、可能 `assets/fonts/`
  - **開工對齊**：字體用 bundled assets 還是 `google_fonts` 套件（離線/體積取捨）；深色 surface 階層採 DESIGN.md 哪幾階。
  - **驗收**：App 啟動字體/底色變深色基調；既有畫面不崩；analyze 0。
  - **完成紀錄**：
    - commit：feat `82d5f6f` / test `e73c8b0` / docs（本次）
    - analyze：`fvm flutter analyze` → No issues found（0）
    - test：`fvm flutter test` → 全 229 passed（含新 `test/app/theme/design_tokens_test.dart` 7 cases）
    - **3 決策最終選擇（user 拍板，照做）**：
      1. 字體交付 → **bundled assets**（Noto Sans TC 400/500/700 + Inter 400/500/700 打包進 `assets/fonts/`，pubspec 宣告 family），不走 google_fonts 執行期下載（離線需求）。中文用 `NotoSansTC`、數字/代號 TextStyle 指定 `Inter`。
      2. 深色 surface 階層 → **完整搬 DESIGN.md 整套 M3 tonal 階層**（lowest/low/container/high/highest + dim/bright/variant），`ColorScheme` 逐欄覆寫為具體 OLED 值（`surface #051424`、`lowest #010f1f`…），非 fromSeed 衍生。
      3. 預設主題 → **U1 固定深色基底**（`app.dart` 寫死 `ThemeMode.dark` + `AppTheme.dark()`）；5 套主題 byId（含淺色）接線留 U3 接回。`AppTheme.light()/fromSeed()` 簽名保留不破壞呼叫點。
    - **踩雷**：
      1. **`ColorScheme` 不能用 `copyWith` 偷懶**——要 OLED 真黑必須用完整建構子逐欄帶入 surface 階層；`fromSeed(brightness: dark)` 衍生的深色偏灰、不夠黑，故 `_darkColorScheme()` 全手填。
      2. **typography 單位換算**：DESIGN.md 用 CSS 單位（lineHeight px、letterSpacing em），Flutter `TextStyle.height` = lineHeight/fontSize、`letterSpacing` = em×fontSize（logical px）。抽成 `appTextStyle()` 純函式並單測換算結果（如 display-bold ls=-0.02em×32=-0.64）避免手算錯。
      3. Inter ttf 體積偏小（~68KB/字重）但 `file` 驗為合法 TrueType（含 GDEF/數字字符集），非 Noto 全字庫等級屬正常——數字字體用不到全 Unicode。
    - **相依提醒（給後續 step）**：三軸語意色（漲跌/命中金色）刻意**不在 U1**，留 U2 的 `SemanticColors` ThemeExtension；本 step 純基礎層。
    - **驗收缺口**：模擬器截圖本 session 卡住未取，依 user 指示延後自行確認（深色基底 + 字體已由 analyze/test + token 對照 DESIGN.md 確認落地，非阻斷）。

- [x] **Step U2：色彩語意系統（三軸分離）+ 預測視覺改造**
  - 新增 `SemanticColors` ThemeExtension（軸一方向色 + 軸二命中色）。
  - `prediction_visual.dart`：依 §2 軸一重定 icon 顏色（確認 upLimit 紅 / downLimit 綠 / bullish 紅 / bearish 綠 / flat 灰 / customPrice 藍 / customPercent 依正負）。
  - `calendar_month_view.dart`：**cell 改為「中性底 + 右上角命中徽章（金✓/灰✗/空圈）」**，不再用整格綠/紅底。
  - **觸碰**：`lib/app/theme/`（extension）`lib/features/prediction/view/prediction_visual.dart` `lib/features/calendar/view/widgets/calendar_month_view.dart`
  - **開工對齊**：命中徽章確切樣式（尺寸/位置/形狀）；customPercent 0 值算紅綠灰哪個。
  - **注意**：分享版型 `full_calendar_template.dart` 也用 `hitCellBg/missCellBg`——U2 改語意後，U8 要同步；本步先不動 template（避免 scope 外），但在完成紀錄記下相依。
  - **驗收**：可抽 `predictionDirectionColor()` / 命中徽章決策純函式做單測；截圖確認紅綠不撞命中色。
  - **完成紀錄**：
    - commit：feat `56d688c` / test `fc4f43a` / docs（本次）
    - analyze：`fvm flutter analyze` → No issues found（0）
    - test：`fvm flutter test` → 全 254 passed（229 既有 + 25 新：semantic_colors 9 / prediction_visual 12 / hit_badge 4）
    - **3 決策最終選擇（user 拍板，照做）**：
      1. customPercent 0 值 → **平盤灰**（`marketDirectionOf(customPercent, percent:0)` 回 `MarketDirection.flat`；>0 紅、<0 綠、null（未表態）→ 中性藍）。與台股慣例一致。
      2. cell 形狀/底 → **維持圓形 + 透明底**（保留既有 `BoxShape.circle`，命中狀態移到右上角徽章；today 仍用 primary 描邊環）。8px 圓角方格留 U5 calendar 主畫面改造，避免與 U5 重工。
      3. icon 色範圍 → **更新 `PredictionVisual.color` 為軸一標準色**（不只動 calendar）。upLimit/bullish→#FF3B30 紅、downLimit/bearish→#34C759 綠、flat→#757575 灰、customPrice/customPercent(靜態無值)→#4D8EFF 中性藍。share templates / editor tab 的 icon 色一併對齊軸一（僅色號微調，不動結構）；calendar marker 另走 `marketDirectionOf+directionColor` 取得 customPercent 依正負方向色。
    - **架構落地**：
      - `SemanticColors extends ThemeExtension`（軸一 up/down/flat/neutral + 軸二 hit/miss/unsettled），`SemanticColors.dark` 一套，掛進 `ThemeData.extensions`；畫面讀 extension 不寫死。
      - 純函式：`marketDirectionOf(type,{percent})`（軸一）+ `hitBadgeOf(status,{isPast})`（軸二 hit/miss/unsettled/none）+ `SemanticColors.directionColor(MarketDirection)`，皆 TDD（RED→GREEN）。
      - `HitBadgeMarker`：16dp 圓形，金底白✓ / 灰底白✗ / 淡灰空心圈 / none 不繪；cell `Stack` 右上角疊放（`clipBehavior: Clip.none`）。當日未結算視為「非過去日」→ 不上徽章（§2 未來日不上色）。
    - **踩雷**：
      1. **軸一/軸二色必須物理分離**：命中用金 #FFB300、miss/unsettled 用灰 #8C909F，刻意避開紅綠——綠已給「跌」、紅已給「漲」，命中若用綠會與「跌停命中」語意打架（§2 核心）。
      2. **`SemanticColors` 不可放在 theme 層卻反向 import feature**：`MarketDirection` enum 定義在 theme/`semantic_colors.dart`，`marketDirectionOf` 放 feature/`prediction_visual.dart`（feature→theme 正向）；`hitBadgeOf` 因依賴 `SettleStatus`（calendar viewmodel）放在 calendar/`hit_badge.dart`，避免 theme→feature 逆向依賴。
      3. **`PredictionVisual.color` 是共用色源**：被 calendar / editor tab / 3 個 share template 同讀，改它會連動三處；本步刻意統一成軸一色（一致性優先），結算/出圖邏輯與 template 結構未動，既有測試全綠。
    - **U8 template 相依提醒**：`full_calendar_template.dart` / `single_day_template.dart` / `report_card_template.dart` 的**命中 cell 底色**仍走舊 `CalendarTheme.hitCellBg/missCellBg/unsettledCellBg`（本步未動，避免 scope 外）。U8 須改讀 `SemanticColors`（命中金、miss/unsettled 灰）與本步同步；template 的 type icon 色因共用 `PredictionVisual.color` 已自動對齊軸一。
    - **驗收缺口**：模擬器截圖本 session 依 user 指示延後自行確認（analyze 0 / test 254 綠 + 純函式單測鎖住三軸色號，紅綠與命中金不撞色已由 token 值確認，非阻斷）。

- [ ] **Step U3：主題系統重構（5 套：dark/light/redgreen/minimal/meme）**
  - 依 §3 重定 `calendar_themes.dart` 五套，每套提供 `SemanticColors` + surface 階層 + monthBackground + cell 樣式。
  - `byId` 加舊 id（`def`/`default`/`warm`/`cool`/`mono`/`nature`）→ 新 id fallback 映射。
  - 設定頁主題選擇器（`settings_screen.dart` 的 `_ThemePickerSheet`）更新名稱/預覽。
  - **觸碰**：`lib/app/theme/calendar_themes.dart` `lib/app/theme/app_theme.dart` `lib/features/settings/view/settings_screen.dart`
  - **開工對齊**：見 §3 四個決策（id 命名 / 預設 / token 集 / meme 樣式表達）。
  - **驗收**：5 套切換立即套用、視覺差異明顯；舊 id 不崩；`byId` fallback 純函式單測。
  - **完成紀錄**：

- [ ] **Step U4：底部導航架構（4 tab shell）+ FAB**
  - `router.dart` 改 `StatefulShellRoute`，4 branch：日曆 / 勝率 / 自選 / 設定。
  - 新增 `lib/features/shell/home_shell.dart`（`NavigationBar` 玻璃感 + IndexedStack）。
  - 自選 tab：新增 `features/stock/view/stock_list_screen.dart`（用既有 `stockListViewModel`）。
  - calendar 加 FAB「產生分享圖」；AppBar 精簡（見 §4.5）。
  - AdsBanner 重新定位（§4.3）。
  - **觸碰**：`lib/app/router.dart` `lib/features/shell/`(新) `lib/features/calendar/view/calendar_screen.dart` `lib/features/stock/view/`(新 screen) `lib/features/accuracy_report/...`/`settings/...`（移除重複入口）`lib/core/ads/ads_banner.dart`（掛載點）
  - **開工對齊**：見 §4 五個決策（shell 實作 / 自選 tab A or B / banner 位置 / FAB 去留 AppBar icon）。
  - **驗收**：4 tab 切換保留各自狀態；onboarding redirect 仍正常；FAB 開出圖；banner 顯示。
  - **完成紀錄**：

### 畫面視覺改造

- [ ] **Step U5：Calendar 主畫面視覺改造**
  - chips 帶 trend dot（§DESIGN.md component）；玻璃感卡；cell 8px 圓角；today/selected 樣式。
  - **觸碰**：`lib/features/calendar/view/calendar_screen.dart` `widgets/calendar_month_view.dart` `lib/features/stock/view/stock_chips_bar.dart`
  - **注意**：chips trend dot 顏色用軸一方向色，但**不顯示報價數字**（§6）；dot 可代表「該股當前選中/最近預測方向」而非即時漲跌——開工對齊 dot 語意。
  - **驗收**：截圖對齊 Stitch `_1/_6` 觀感（去事件流）；滾動順暢（`RepaintBoundary` 已在）。
  - **完成紀錄**：

- [ ] **Step U6：Prediction Editor 視覺改造**
  - 玻璃 sheet（backdrop blur）；type tab 樣式（7 種含 flat）；結算結果區大字；自訂% 改 **±50 拖曳滑桿 + 數字輸入**（現為純 TextField）。
  - **觸碰**：`lib/features/prediction/view/prediction_editor_sheet.dart`
  - **開工對齊**：±50 滑桿與既有 TextField 並存還是取代；blur 在低階機效能。
  - **注意**：勿動 `prediction_editor_view_model`（純視覺）；`flat` tab 已在；結算/補價邏輯不動。
  - **驗收**：填值/結算/補價流程不變；截圖對齊 Stitch `_2`（去電路板 preview）。
  - **完成紀錄**：

- [ ] **Step U7：Accuracy Report 視覺改造**
  - hero 命中率大字（display-bold）；玻璃統計卡；fl_chart 線/漸層套主題色；「分享我的成績」CTA 樣式。
  - **觸碰**：`lib/features/accuracy_report/view/accuracy_report_screen.dart`
  - **驗收**：本月/近3月/全部切換正常；圖表配色隨主題；截圖對齊 Stitch `_3`。
  - **完成紀錄**：

- [ ] **Step U8：Share Templates 視覺改造（含 §2 命中色同步）**
  - 三版型對齊 Stitch `_4`：單日卡大字「明天 台積電 我看漲停 🚀」、報告卡、整月卡；浮水印。
  - **同步 U2 的命中語意**：`full_calendar_template.dart`/`single_day_template.dart`/`report_card_template.dart` 改用 `SemanticColors`（命中金、miss 灰），取代舊 hit/miss cellBg。
  - **觸碰**：`lib/features/share_image/view/templates/*.dart` `share_preview_screen.dart`（控制項樣式）
  - **注意**：出圖像素規格（1080 短邊）與 `RepaintBoundary.toImage` 不動；只動視覺。梗圖背景沿用既有漸層 preset（Step 19）或新增——開工對齊。
  - **驗收**：三版型 + 三比例出圖視覺品質；命中色一致；既有 ShareAspectRatio test 不破。
  - **完成紀錄**：

- [ ] **Step U9：自選 tab + 搜尋視覺改造**
  - 自選清單卡片化、拖曳排序 / 滑動刪除（現為長按刪除——開工決定是否升級）；搜尋頁加 **台股/美股/ETF 分頁**（現為單一搜尋）。
  - **觸碰**：`lib/features/stock/view/stock_list_screen.dart`(U4 新) `stock_search_sheet.dart` `stock_chips_bar.dart`
  - **注意**：**不顯示即時報價**（§6）；ETF 分頁若需後端支援，開工確認 API（`stock_api_client`）能力，不足則先做 台股/美股 兩頁 + TODO。
  - **驗收**：搜尋/新增/刪除流程不變；截圖對齊 Stitch `_9`（去報價數字）。
  - **完成紀錄**：

- [ ] **Step U10：Settings + Onboarding 視覺改造**
  - 設定分區卡片（帳戶/偏好/工具/關於）；**無 Premium、無頭像幻想**（匿名用戶顯示中性狀態）；主題切換預覽。
  - Onboarding 3 頁插圖/排版升級；**文案維持現有「你來預測」三頁不動**。
  - **觸碰**：`lib/features/settings/view/settings_screen.dart` `lib/features/onboarding/view/onboarding_screen.dart` `widgets/onboarding_page.dart`
  - **注意**：onboarding 圖目前是 Material Icon + 純色塊（Step 12 決策，真素材留 Step 26）——U10 可做向量插圖或保留 icon 升級樣式，開工對齊（避免與 Step 26 素材重工）。
  - **驗收**：設定所有列功能不變；onboarding 三頁滑動正常；截圖對齊 `_10/_11`。
  - **完成紀錄**：

- [ ] **Step U11：綁定提示 + 空狀態 + 細節打磨**
  - 首次出圖後一次性「綁定帳號」提示 dialog（F1，現未做）；`login_sheet` 視覺。
  - 空狀態：無股票 / 空月曆 / 報告無資料（多已有文案，套新視覺）。
  - 一致性掃描：按壓回饋（scale 0.98）、safe area、banner 8dp 邊距。
  - **觸碰**：`lib/features/auth/view/login_sheet.dart` `lib/features/share_image/...`（出圖後 hook 提示）各 empty state widget
  - **開工對齊**：綁定提示觸發點與「只提示一次」旗標存哪（meta box key）；已綁定用戶不提示。
  - **驗收**：首次出圖看到提示一次、再出圖不再出現；空狀態視覺一致。
  - **完成紀錄**：

- [ ] **Step U12：全主題實機視覺驗收 + 微調**
  - 兩台實機（iOS + Android）跑 5 套主題 × 主要畫面，截圖核對 DESIGN.md/Stitch。
  - 修跨主題對比度/可讀性/meme neo-brutalist 細節/暗色 banner 融合。
  - 產出**上架截圖候選**（接 Step 26）。
  - **驗收**：5 主題無破版/低對比；主流程截圖達 Stitch 觀感。
  - **完成紀錄**：

---

## 8. Commit 規範

沿用 [06-steps.md](./06-steps.md#commit-規範)。`<step>` 用 `stepU1`…`stepU12`：

```
feat(stepU2): 三軸色彩語意系統 + 預測 icon 方向色 + cell 命中徽章

Refs: docs/plans/2026-05-28-stock-calendar-v2/08-ui-revamp.md Step U2
```

分支：續用 `refactor/v2`。本改版全部完成後再接 Step 26–28 上架。

## 9. 完成定義（DoD）

沿用 06-steps DoD（提交推送 / analyze 0 / 既有+新測通過 / 勾 checkbox / 寫完成紀錄 / 記 Notes）。**額外**：純視覺步驟需附**截圖**（存 `docs/plans/2026-05-28-stock-calendar-v2/ui-shots/` 或完成紀錄描述）作為驗收證據。

## 10. 開工 session 模板

```
Step U<N> 開工
- 上一個 Step U<N-1> 確認完成：[是 / 否（哪裡不齊）]
- 本 step 目標：<一句話>
- 開工須對齊決策（本文件該步「開工對齊」清單）：逐項提案 + 等 user 拍板
- 預期觸碰的檔案：
  - lib/...
```

## 11. 全局 checklist（UI 改版）

- [x] Step U1：Design tokens + ThemeData
- [x] Step U2：三軸色彩語意 + 預測視覺
- [ ] Step U3：5 套主題重構
- [ ] Step U4：底部導航 shell + FAB
- [ ] Step U5：Calendar 主畫面
- [ ] Step U6：Prediction Editor
- [ ] Step U7：Accuracy Report
- [ ] Step U8：Share Templates（+命中色同步）
- [ ] Step U9：自選 tab + 搜尋
- [ ] Step U10：Settings + Onboarding
- [ ] Step U11：綁定提示 + 空狀態 + 打磨
- [ ] Step U12：全主題實機驗收 + 微調

> 完成全部 Step U 後，回到 [06-steps.md](./06-steps.md) 接 Step 26（上架資源，此時截圖/icon/splash 有定稿視覺可用）。
