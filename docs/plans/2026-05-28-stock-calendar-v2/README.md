# 股市行事曆 v2 — 重構設計總覽

> 建立日期：2026-05-28
> 狀態：設計階段
> 目的：將 6 年前以 Flutter (Dart 2.7 / Provider / Firebase 0.x) 撰寫的 App 全面重構為 Flutter 3.41.2 / Dart 3 / Riverpod + MVVM，並重新規劃功能。

---

## 文件索引（請依序閱讀）

| 編號 | 文件 | 內容 |
|------|------|------|
| 00 | [00-overview.md](./00-overview.md) | 產品願景、目標用戶、核心功能總覽 |
| 01 | [01-tech-stack.md](./01-tech-stack.md) | 技術選型定案、套件清單 |
| 02 | [02-architecture.md](./02-architecture.md) | 目錄結構、MVVM 分層、資料流 |
| 03 | [03-data-model.md](./03-data-model.md) | Firestore schema、Hive box、freezed models |
| 04 | [04-backend-spec.md](./04-backend-spec.md) | `stock.wisplu.com.tw` Python 後端 API 規格 |
| 05 | [05-features.md](./05-features.md) | 各 feature 詳細說明（auth / calendar / prediction / share / report / theme / ads / notify / settings） |
| 06 | [06-steps.md](./06-steps.md) | **★ 實作步驟（Step 1 ~ 28）+ 完成 checkbox + commit/push 規則** |
| 07 | [07-phase2.md](./07-phase2.md) | Phase 2 規劃（主題市集 + RevenueCat 訂閱）|
| 08 | [08-ui-revamp.md](./08-ui-revamp.md) | **★ UI/UX 視覺改版（Step U1 ~ U12）——Stitch 設計落地、三軸色彩、主題/導航重構；插在 06 的 Step 26 之前** |

---

## 給每個實作 session 的工作流程

1. **開工前**：閱讀 `README.md` → `06-steps.md`，確認上一個 step 已 `[x]` 完成且已 commit/push
2. **動工時**：閱讀對應 feature 文件（`05-features.md`）+ 相關規格（`03` / `04`）
3. **完成後**：
   - 把 `06-steps.md` 對應的 step checkbox 從 `[ ]` 改成 `[x]`
   - 在該 step 下方寫上「完成」與簡短說明（commit hash、注意事項）
   - 執行 `git add . && git commit -m "..." && git push`
   - 通知下一個 session 可以開始

詳細 commit message 規範請見 [06-steps.md](./06-steps.md#commit-規範)。

---

## 全局進度追蹤

- [ ] **Phase 0：設計階段**（本文件群完成即視為完成）
- [ ] **Phase 1：重構與重新上架**（免費 + AdMob，詳見 [06-steps.md](./06-steps.md)）
- [ ] **Phase 2：主題市集 + 訂閱變現**（詳見 [07-phase2.md](./07-phase2.md)）

---

## 重要決策摘要（一句話版）

| 主題 | 決策 |
|------|------|
| 範圍 | 升級 + 換架構 + 重新設計功能（2.0 重做） |
| 定位 | 個人預測筆記本 + 出圖分享，**不做社群** |
| 市場 | 台股 + 美股 |
| 股價來源 | 自家 Python 後端 `stock.wisplu.com.tw`（Dokploy），App 失敗時 fallback 手動輸入 |
| 結算 | 混合：自動抓 + 手動補 |
| 登入 | Android：匿名 + Google；iOS：匿名 + Apple + Google |
| 推播 | Phase 1：本地排程提醒 + 存 FCM token 備用 |
| 出圖 | Phase 1：多版型本地產圖 → 存相簿 + 系統 share sheet，**不上雲** |
| 變現 | Phase 1：AdMob；Phase 2：主題市集 + RevenueCat 訂閱 |
| 後端費用 | Firestore 幾乎免費（本地優先），無自家圖片儲存成本 |
