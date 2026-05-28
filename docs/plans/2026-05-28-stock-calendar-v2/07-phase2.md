# 07 — Phase 2 規劃（主題市集 + 訂閱變現）

> Phase 1 上架且穩定運作（建議至少 4 週、有實際留存數據）後再啟動 Phase 2。

## 目標

- 增加進階主題（10+ 套），部分主題鎖在訂閱後
- 接 RevenueCat 處理跨平台訂閱
- 從 100% 廣告變現 → 廣告 + 訂閱混合（訂閱用戶免廣告）

## 商業設計（草案，可調整）

### 訂閱方案
| 方案 | 月費 | 年費 | 功能 |
|------|------|------|------|
| 免費 | 0 | 0 | 5 套基礎主題 + 廣告 |
| Pro | NT$60 | NT$600 | 全主題、無廣告、雲端備份分享圖（30 天）、進階準度報告 |

### 試用
- 7 天免費試用（系統內建）
- 試用結束自動轉訂閱

## 技術改動

### 套件新增
```yaml
purchases_flutter: ^6.x   # RevenueCat 新版
```

### 後端 / 服務
- RevenueCat 後台設定 product / entitlement / offering
- iOS / Android Store 設定對應 IAP product
- Webhook（選做）：訂閱事件寫入 Firestore `users/{uid}/subscription`

### App 端
- `core/subscription/subscription_service.dart`：封裝 RevenueCat SDK
- `subscriptionProvider`：watch 當前狀態（active / trial / expired）
- 主題清單依 entitlement 過濾
- 廣告載入器檢查 entitlement → active 不載入

## 實作步驟（草案 — Phase 2 開工時再展開細節）

- [ ] **P2-1：RevenueCat 帳號 / 產品設定**
- [ ] **P2-2：App / Play Store IAP 產品建立 + 審核**
- [ ] **P2-3：App 端整合 purchases_flutter，封裝 SubscriptionService**
- [ ] **P2-4：訂閱頁面（升級流程 UI）**
- [ ] **P2-5：主題市集 UI（顯示鎖 / 未鎖、預覽）**
- [ ] **P2-6：新增 10 套進階主題**
- [ ] **P2-7：分享圖上傳 Firebase Storage（短連結，7 天 lifecycle，Pro 限定）**
- [ ] **P2-8：訂閱用戶移除廣告**
- [ ] **P2-9：恢復購買流程**
- [ ] **P2-10：訂閱頁文案、合規（取消方式、自動續訂條款）**
- [ ] **P2-11：A/B test 試用長度 / 價格**

## 風險與注意

- **App Store 審查**：訂閱頁必須清楚揭露自動續訂、價格、取消方式（否則拒絕上架）
- **Play Store 政策**：訂閱不可硬性綁定關鍵功能（仍要有免費基本功能）
- **RevenueCat 費用**：營收前 USD 2.5K/月免費，之後抽 1%（遠低於自己接 StoreKit 的開發維護成本）
- **Sandbox / 測試**：訂閱測試流程比一般功能複雜，預留 2 週測試時間

## 成功指標

| 指標 | 目標 |
|------|------|
| 試用轉換率 | > 5% |
| 月留存（M1） | > 20% |
| MRR | Phase 2 上線 3 個月後 > NT$10,000 |
| 主題下載分佈 | 至少 3 套付費主題使用率 > 10% |

---

> 待 Phase 1 數據出來後，本文件會被改寫成詳細的設計文件（類似 Phase 1 的 00-06）。
