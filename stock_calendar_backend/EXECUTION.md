# Step 10 後端 — 逐 session 執行指引

一個 Task 開一個全新 session（避免上下文過長）。完整計畫見
`../docs/plans/2026-05-29-step10-backend-implementation.md`。

用法：每個新 session 先貼【固定開頭】，再接上對照表中該 session 那一句。

---

## 【固定開頭】每個新 session 都先貼這段

```
工作依據：docs/plans/2026-05-29-step10-backend-implementation.md（Step 10 後端計畫）

規則：
- 後端在 monorepo 子資料夾 stock_calendar_backend/，計畫內所有路徑都相對於它。
- 開工先 git status 確認乾淨、HEAD 是上一個 task 的 commit（接續做）。
- 嚴格 TDD：先寫 failing test → 看它失敗 → 最小實作 → 綠 → commit。純函式（parser／change_percent／tick／來源 fallback／cron 挑 symbol）優先抽出單測；httpx 用 respx mock；DB 測試用 testcontainers-postgres（無 docker 再退 SQLite）。
- commit format：feat(step10): / test(step10):。要不要 push 我會問你。
- Python 後端工具獨立於 Flutter（別用 fvm flutter test 驗後端）。
- 不確定就停下來問——尤其外部資料源實測後形狀與計畫假設不符時。

⚠️ 重要：這個 session 只做我指定的那一個 Task。做完 commit 後停下回報，不要自動往下一個 Task 做。
```

---

## 【各 session 專屬】接在固定開頭後面，一次貼一句

| Session | 貼這句 | 備註 |
|---|---|---|
| 1 | `本次只做 Task 1：建 repo 骨架 + 依賴 + health 端點。` | 第一個 session，會建出 stock_calendar_backend/ 結構 |
| 2 | `本次只做 Task 2：Postgres 連線 + SQLAlchemy session。` | |
| 3 | `本次只做 Task 3：stocks / quotes / watched_symbols 三張表 models。` | |
| 4 | `本次只做 Task 4：Alembic 初始化 + 第一個 migration。` | |
| 5 | `本次只做 Task 5：台股 TWSE adapter。先 curl 實測 STOCK_DAY_ALL 真實回應存成 fixture，再 TDD 寫 parser。` | ⚠️ 先 curl |
| 6 | `本次只做 Task 6：美股 Yahoo adapter + Stooq 備援。先 curl 實測兩個來源存成 fixture，再 TDD。` | ⚠️ 先 curl |
| 7 | `本次只做 Task 7：來源 fallback 策略（純函式，不重試）。` | |
| 8 | `本次只做 Task 7.5：股票主檔來源 parser（TWSE 基本資料 / TPEx / NASDAQ Trader）。先 curl 實測存 fixture，再 TDD。` | ⚠️ 先 curl |
| 9 | `本次只做 Task 8：quote repository / service（upsert / get / range / touch_watched）。` | |
| 10 | `本次只做 Task 9：stock search / detail service。` | |
| 11 | `本次只做 Task 10：四個 v1 API 端點 + Pydantic schema + Cache-Control。` | |
| 12 | `本次只做 Task 11：APScheduler cron（報價 + 主檔同步 + 清理）+ seed_stocks。` | |
| 13 | `本次只做 Task 12：Dockerfile + docker-compose（改寫自 hainihongo）+ Dokploy 部署 + 驗收 + 回填 06-steps Step 10 完成紀錄。` | 需 Dokploy／GitHub 權限，你要在場 |
| 14（選做） | `本次只做 Task 13：Traefik rate limit（API key 留 TODO）。` | optional |

---

## 第一個 session 的完整文字（Task 1，可直接整段貼）

```
工作依據：docs/plans/2026-05-29-step10-backend-implementation.md（Step 10 後端實作計畫）。
開工前先讀這份計畫的 header + Resolved Decisions + 前置 + Task 1 段落，再讀 docs/plans/2026-05-28-stock-calendar-v2/04-backend-spec.md 的健康檢查端點規格。

【脈絡】
- 我在做 stock.wisplu.com.tw 後端（FastAPI + Postgres），決策已拍板：官方全清單資料源、monorepo、沿用 hainihongo 的 Dokploy compose、不做 API key。
- Monorepo：後端住這個 Flutter repo 的子資料夾 stock_calendar_backend/（目前是空的）。計畫內所有路徑都相對於 stock_calendar_backend/，例如 app/main.py = stock_calendar_backend/app/main.py。
- 後端工具鏈獨立於 Flutter（Python；別用 fvm flutter 那套驗後端）。

【規則】
- 開工先 git status 確認乾淨（pre-existing 未追蹤：DESIGN.md、android/build/、stitch_stock_market_calendar_v2/、stock_calendar_backend/），HEAD 應為最新計畫 commit。
- 嚴格 TDD：先寫 failing test → 跑它確認失敗 → 最小實作 → 跑到綠 → commit。
- commit format：feat(step10): / test(step10):。commit 後要不要 push 先問我。
- 不確定就停下來問。

【本次只做 Task 1：建 repo 骨架 + 依賴 + health 端點】
在 stock_calendar_backend/ 內：
1. 建骨架：pyproject.toml（或 requirements.txt，pin 版本）、.gitignore、README.md、app/__init__.py、app/main.py、app/config.py（讀 POSTGRES_URL / SERVICE_NAME / ENV）。
   依賴：fastapi、uvicorn[standard]、gunicorn、sqlalchemy>=2.0、psycopg[binary]>=3、alembic、httpx、apscheduler、pydantic-settings；dev：pytest、respx。
2. TDD health 端點：
   - 先寫 tests/test_health.py（用 FastAPI TestClient）：GET /api/v1/health → 200，json 含 status=="ok" 且有 "now"。
   - 跑 `pytest tests/test_health.py -v` 確認 FAIL（路由還沒有）。
   - 最小實作 app/main.py 的 /api/v1/health（回 {"status":"ok","now": <UTC ISO 字串>}）。
   - 再跑 `pytest tests/test_health.py -v` 確認 PASS。
3. commit：feat(step10): scaffold FastAPI app with health endpoint。

⚠️ 這個 session 只做 Task 1。做完 commit 後停下來回報，不要自動往 Task 2 做。
```

---

## 提醒

- **Session 之間靠 git 接續**：同機同 branch，commit 留著就能接；想跨機/備份就每個 session 結尾 push。
- **Task 12 部署**那個 session 你要在場：Dokploy 建 app、接同網路 Postgres 獨立 app、注入 secrets、設 Compose Path 指向 `stock_calendar_backend/`。
- 外部資料源（TWSE/Yahoo/Stooq/NASDAQ Trader）是公開/非官方 API，**寫 parser 前一定先 curl 實測存 fixture**，否則形狀變了白寫。
