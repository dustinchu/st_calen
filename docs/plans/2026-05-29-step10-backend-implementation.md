# Step 10 — 後端 stock.wisplu.com.tw 實作計畫

> **For Claude:** REQUIRED SUB-SKILL: 實作時用 superpowers:executing-plans 逐 task 進行。
> **放置(Monorepo):** 後端住在這個 Flutter repo 的子資料夾 `stock_calendar_backend/`。**本計畫所有檔案路徑都相對於 `stock_calendar_backend/`**(例:`app/main.py` = `stock_calendar_backend/app/main.py`)。Dokploy deploy 時設 Build Path / compose 路徑指向該子資料夾。後端 commit 會進 Flutter repo 歷史(可接受)。

**Goal:** 依 `04-backend-spec.md` 建一個 FastAPI + Postgres 後端,提供股票搜尋 / 收盤價查詢 / 範圍查詢 / 健康檢查,並用 cron 每日從 TWSE / Yahoo 抓收盤價,部署到既有 Dokploy 環境的 `stock.wisplu.com.tw`。

**Architecture:** 單一 FastAPI app(`app/`),同一個 Docker image 跑兩種 entrypoint——web(gunicorn+uvicorn workers)與 cron(APScheduler)。外部資料源(TWSE openapi / Yahoo / Stooq)只在 cron 抓,寫進 Postgres;web 端點只讀 DB(已有就回、沒有回 404),不即時打外部,避免阻塞與雪崩。

**Tech Stack(預設選型,實作前可調):** Python 3.12 / FastAPI / Uvicorn+Gunicorn / SQLAlchemy 2.0(sync)+ psycopg3 / Alembic / httpx(outbound)/ APScheduler(cron)/ pytest + httpx mock。沿用公司 hainihongo 的 FastAPI+Dokploy 模式。

---

## ✅ Resolved Decisions(已拍板,2026-05-29)

- **D-A 股票主檔來源 = 官方全清單**(免費官方,無金鑰)。
  - **台股:** TWSE OpenAPI——`STOCK_DAY_ALL`(全上市股票:代號+名稱+OHLC+量,收盤與主檔同源)+ `t187ap03_L`(上市公司基本資料,取產業別 sector);**上櫃**用 TPEx OpenAPI。
  - **美股:** NASDAQ Trader Symbol Directory——`nasdaqlisted.txt` + `otherlisted.txt`(含 NYSE/AMEX),管道分隔純文字全市場清單。
  - 策略:`seed_stocks` 一次性灌入 + cron 定期(如每週)刷新主檔。見 Phase C(parse)+ Phase F(sync job)。
- **D-B repo 結構 = Monorepo 子資料夾**:`stock_calendar_backend/`(在 Flutter repo 內)。Dokploy 設 Build Path 指該子資料夾。後端 commit 進 Flutter repo 歷史。本計畫路徑皆相對於該資料夾。
- **D-C 部署 = 既有 Dokploy**:沿用 hainihongo 的 compose 模式(見 Task 12 調整清單);Postgres 為同 `dokploy-network` 上的**獨立 Dokploy app**,`POSTGRES_URL` 走 secrets 注入 `.env`。使用者有權限,push 到 GitHub 即可 deploy。
- **D-D API key = 不做**:此 API 只有公開股價、無使用者隱私資料,spec 亦定調「暫時公開」。改用 **Traefik rate limit 60 req/min/IP** 擋濫用(Task 13 optional)。日後需要再加 key。
- **D-E 端點形狀**:`/quotes/{symbol}/range`(app 主用,回日期→收盤陣列)與單日 `/quotes/{symbol}?date=` **兩個都做**。僅 Step 11 對接備忘,不影響後端實作。

---

## 前置:資料源端點實測(動工第 0 件事)

外部資料源是非官方/公開 API,形狀會變。**寫任何抓取碼前,先用 curl 實測確認當前回應格式**,否則 parser 全部白寫:

```bash
# 台股:TWSE openapi 當日全市場收盤
curl -s "https://openapi.twse.com.tw/v1/exchangeReport/STOCK_DAY_ALL" | head -c 2000
# 美股:Yahoo Finance 非官方 quote
curl -s "https://query1.finance.yahoo.com/v7/finance/quote?symbols=AAPL" | head -c 2000
# 美股備援:Stooq CSV
curl -s "https://stooq.com/q/d/l/?s=aapl.us&i=d" | head -c 500
```

把實際回應貼進各 parser task 的測試 fixture(真實 sample),用 TDD 寫 parser。

---

## Phase A:專案骨架

### Task 1:建 repo 骨架 + 依賴

**Files:**
- Create: `pyproject.toml`(或 `requirements.txt`)、`.gitignore`、`README.md`
- Create: `app/__init__.py`、`app/main.py`(最小 FastAPI app,只有 `/api/v1/health`)
- Create: `app/config.py`(讀環境變數:`POSTGRES_URL`、`SERVICE_NAME`、`ENV`)

**依賴清單(pin 版本):** `fastapi`、`uvicorn[standard]`、`gunicorn`、`sqlalchemy>=2.0`、`psycopg[binary]>=3`、`alembic`、`httpx`、`apscheduler`、`pydantic-settings`;dev:`pytest`、`pytest-asyncio`、`httpx`(TestClient)、`respx`(mock httpx)。

**Step 1:** 先寫 health 端點的 failing test(用 FastAPI `TestClient`):

```python
# tests/test_health.py
from fastapi.testclient import TestClient
from app.main import app

def test_health_returns_ok():
    client = TestClient(app)
    r = client.get("/api/v1/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"
    assert "now" in r.json()
```

**Step 2:** `pytest tests/test_health.py -v` → FAIL(app 還沒有此路由 / import error)。
**Step 3:** 最小實作 `app/main.py` 的 health 路由(回 `{"status":"ok","now": <UTC ISO>}`)。
**Step 4:** `pytest tests/test_health.py -v` → PASS。
**Step 5:** commit `feat: scaffold FastAPI app with health endpoint`。

### Task 2:Postgres 連線 + SQLAlchemy session

**Files:**
- Create: `app/db.py`(engine、`SessionLocal`、`get_db()` FastAPI dependency)
- Create: `app/models.py`(`Base` declarative base)

**驗收:** 寫一個 test 用 SQLite in-memory 或 testcontainers Postgres 確認 `get_db()` 能開 session、`Base.metadata` 可建立。commit `feat: add db session + base`。

> 註:test DB 策略二選一——(a) testcontainers-postgres(最真,需 docker);(b) SQLite in-memory(快,但 numeric/date 行為與 PG 有差)。**建議 testcontainers**,因為有 upsert(`ON CONFLICT`)與 timestamptz。若 CI 無 docker 再退 SQLite。

---

## Phase B:資料模型 + Migration

### Task 3:三張表的 SQLAlchemy models

**Files:** Modify `app/models.py`

依 spec 建 `Stock` / `Quote` / `WatchedSymbol`:
- `stocks`: `symbol`(PK, text)、`market`、`name`、`sector`(nullable)、`updated_at`(timestamptz)
- `quotes`: PK `(symbol, trade_date)`、`open/high/low/close/change_percent`(numeric)、`volume`(bigint)、`source`、`inserted_at`;index on `trade_date`
- `watched_symbols`: `symbol`(PK)、`last_requested_at`(timestamptz)

**Step:** 寫 model → 寫一個 test 建表 + 塞一筆 + 查回(round-trip,確認型別) → commit `feat: add stocks/quotes/watched_symbols models`。

### Task 4:Alembic 初始化 + 第一個 migration

**Files:** Create `alembic.ini`、`alembic/env.py`(讀 `POSTGRES_URL`、綁 `Base.metadata`)、`alembic/versions/0001_init.py`

**驗收:** `alembic upgrade head` 在本機 PG 建出三張表;`alembic downgrade base` 可回滾。commit `feat: alembic init + initial schema migration`。

---

## Phase C:外部資料源 adapter(TDD,純函式為主)

> 每個 adapter 拆兩塊:**fetch(IO,httpx)** 與 **parse(純函式)**。parse 用真實 sample fixture 做 TDD;fetch 用 `respx` mock httpx。

### Task 5:台股 TWSE adapter

**Files:** Create `app/sources/twse.py`、`tests/sources/test_twse.py`、`tests/sources/fixtures/twse_stock_day_all.json`(前置步驟 curl 存下的真實 sample)

- `parse_twse_daily(raw: list) -> list[QuoteRow]`:從 STOCK_DAY_ALL 的欄位(代號/開/高/低/收/成交量)映射成內部 `QuoteRow`,計算 `change_percent`,`source="twse"`。處理「無資料 / `--` / 千分位逗號」等髒值。
- `fetch_twse_daily(client) -> list[QuoteRow]`:httpx GET + 呼叫 parse。
- **順帶取主檔(D-A):** STOCK_DAY_ALL 同時含代號+名稱 → 另一個純函式 `parse_twse_stocks(raw) -> list[StockRow]`(market=tw),供主檔 upsert 用。

**TDD:** 先寫 `test_parse_twse_daily_maps_fields` + `test_parse_skips_rows_with_dashes` + `test_change_percent_computed` + `test_parse_twse_stocks_extracts_symbol_name`(用 fixture)→ FAIL → 實作 parse → PASS。fetch 用 respx mock fixture。commit。

### Task 6:美股 Yahoo adapter + Stooq 備援

**Files:** Create `app/sources/yahoo.py`、`app/sources/stooq.py` + 對應 tests/fixtures

- `parse_yahoo_quote(raw: dict) -> QuoteRow`(從 `quoteResponse.result[0]`)
- `parse_stooq_csv(csv: str) -> list[QuoteRow]`
- 各自 fetch + parse,TDD 同上。commit。

### Task 7:來源 fallback 策略(純函式)

**Files:** Create `app/sources/resolver.py`、`tests/sources/test_resolver.py`

- `fetch_quote_with_fallback(symbol, market, primary, backup) -> QuoteRow | None`:主來源失敗(throw / 空)→ 退備援;雙雙失敗 → `None`(該日缺資料)。
- **TDD:** mock primary 丟例外、backup 回值 → 應回 backup;兩者皆失敗 → `None`。**不重試**(對齊 spec「避免雪崩」)。commit。

### Task 7.5:股票主檔來源(D-A 官方全清單)

**Files:** Create `app/sources/stock_master.py`、`tests/sources/test_stock_master.py` + fixtures

- 台股 sector:`parse_twse_company_info(raw)`(TWSE `t187ap03_L`,取代號→產業別,補進主檔 sector)。
- 上櫃:`parse_tpex_stocks(raw)`(TPEx OpenAPI 上櫃清單,market=tw)。
- 美股:`parse_nasdaq_directory(text)`——解析 NASDAQ Trader `nasdaqlisted.txt` / `otherlisted.txt`(管道 `|` 分隔,跳檔尾 `File Creation Time` 那行、跳 test issue / ETF 視需要),產出 `StockRow`(market=us)。
- **TDD:** 各 parser 用真實 sample fixture 測欄位映射 + 髒行跳過。commit `feat: stock master list parsers (twse/tpex/nasdaq)`。

---

## Phase D:Service 層(DB 讀寫)

### Task 8:quote repository / service

**Files:** Create `app/services/quotes.py`、`tests/services/test_quotes.py`(testcontainers PG)

- `upsert_quotes(db, rows)`:`INSERT ... ON CONFLICT (symbol, trade_date) DO UPDATE`。
- `get_quote(db, symbol, date|None) -> Quote | None`:date 省略回最新一筆。
- `get_range(db, symbol, from, to) -> list[Quote]`。
- `touch_watched(db, symbol)`:upsert `watched_symbols.last_requested_at = now()`。
- TDD 每個方法。commit。

### Task 9:stock search / detail service

**Files:** Create `app/services/stocks.py` + tests

- `search_stocks(db, q, market|None) -> list[Stock]`:`ILIKE %q%` on symbol OR name,可選 market 過濾,limit(如 20)。
- `get_stock(db, symbol) -> Stock | None`。
- TDD(含大小寫不敏感、symbol 與 name 都能命中)。commit。

---

## Phase E:API 端點(FastAPI router + TestClient)

### Task 10:四個 v1 端點 + Pydantic response schema

**Files:** Create `app/api/v1/stocks.py`、`app/api/v1/quotes.py`、`app/schemas.py`;Modify `app/main.py`(掛 router)

端點(對齊 spec):
- `GET /api/v1/stocks/search?q=&market=` → `{items:[...]}`
- `GET /api/v1/stocks/{symbol}` → 200 / 404 `{"error":"stock_not_found"}`
- `GET /api/v1/quotes/{symbol}?date=` → 200 / 404(當日無資料);**順手 `touch_watched`**
- `GET /api/v1/quotes/{symbol}/range?from=&to=` → `{symbol, quotes:[...]}`;**順手 `touch_watched`**
- 回應加 header `Cache-Control: public, max-age=300`

**TDD:** 每個端點用 `TestClient` + 預先塞測試資料,測 200 形狀、404、`Cache-Control`、`touch_watched` 有寫入。commit 每組。

---

## Phase F:Cron

### Task 11:APScheduler 排程 + 抓取 job

**Files:** Create `app/cron_main.py`、`app/cron/jobs.py` + tests(job 邏輯抽純函式可測)

- `app/cron_main.py`:APScheduler BlockingScheduler,註冊 job:
  - 台股報價:每日 15:00 Asia/Taipei → 抓 `watched_symbols`(market tw)當日 → fallback → `upsert_quotes`
  - 美股報價:每日 17:00 America/New_York → 同上(market us)
  - 每週日 02:00 Asia/Taipei → 清 `watched_symbols` 中 `last_requested_at` 超過 30 天者
  - **股票主檔同步(D-A):** 每週(如週六 03:00)抓 TWSE/TPEx/NASDAQ 全清單 → upsert `stocks`(代號/名稱/sector)。
- **首次 seed:** 提供 `python -m app.seed_stocks` 一次性灌主檔(部署後跑一次,讓搜尋立刻有資料)。
- **TDD:** job 的「挑哪些 symbol、清理門檻、upsert 去重」抽純函式測;APScheduler 排程本身靠手動 / 部署驗收。commit。

---

## Phase G:容器化 + 部署

### Task 12:Dockerfile + docker-compose + 部署 Dokploy

**Files:** Create `Dockerfile`、`docker-compose.yml`、`.env.example`(皆在 `stock_calendar_backend/`)

**改寫自你 hainihongo 的 compose(D-C),逐項調整:**
- 全部 `hainihongo` → `stock`;router Host `hainihongo.wisplu.com.tw` → `` stock.wisplu.com.tw ``。
- **拿掉兩個 service 的 `volumes:` 區塊**(`dictionary_v2.db` bind mount 是 hainihongo 專屬;本服務用 Postgres,不需要)。
- **不放 `postgres` service**:Postgres 是同 `dokploy-network` 上的獨立 Dokploy app,`POSTGRES_URL` 由 Dokploy secrets 注入 `.env`(同你註解的模式)。
- `stock-web` command 照抄單行 gunicorn(**勿用 YAML 折疊 `>`,會吃掉 `--worker-class` → 退回 sync worker 撞 ASGI**):`sh -c "alembic upgrade head && gunicorn app.main:app --workers 2 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000 --access-logfile - --error-logfile - --timeout 60 --forwarded-allow-ips=*"`。
- `stock-cron` command `python -m app.cron_main`,`depends_on` stock-web。
- 保留 security-headers middleware labels(改名 stock-security-headers)。
- `Dockerfile`:`python:3.12-slim` + 裝依賴 + COPY app。
- **Monorepo build path:** Dokploy 的 Build / Compose 路徑指向 `stock_calendar_backend/`,使 `build: .` 解析到子資料夾。

**部署 + 驗收(需 D-C 權限):** push GitHub → Dokploy deploy → 跑一次 `python -m app.seed_stocks` 灌主檔 →
- `curl https://stock.wisplu.com.tw/api/v1/health` → 200 `{"status":"ok",...}`
- 搜尋一支已 seed 的股票回 items
- 對一支 `watched` symbol 跑一次 cron 後 `/quotes/{symbol}` 回真資料

commit + 在 `06-steps.md` Step 10 完成紀錄填 hash + 部署結果。

---

## Phase H:收尾

### Task 13(optional follow-up):

- **Traefik rate limit(60 req/min/IP)labels**——D-D 決定的防濫用手段,可在 Task 12 一併加上。
- API key(D-D 決定**先不做**):日後需要再加 middleware 檢查 header + env 注入 + app 端 `--dart-define=STOCK_API_KEY`。
- 監控 / 抓取失敗告警。

---

## 驗收 checklist(整個 Step 10)

- [ ] `pytest` 全綠(parser / service / endpoint 都有測)
- [ ] `alembic upgrade head` 乾淨建表、`downgrade` 可回滾
- [ ] `curl .../api/v1/health` 200
- [ ] 搜尋 / 單日 / 範圍端點回應形狀符合 `04-backend-spec.md`
- [ ] cron 手動觸發一次能抓到真實收盤並寫入(至少 1 支台股 + 1 支美股)
- [ ] 部署上線、Traefik TLS 正常
- [ ] 回填 `06-steps.md` Step 10 完成紀錄(hash + 決策 + 踩雷)

## 與 Step 11(app 端)的銜接

Step 10 上線後,Step 11 才把 app 的 `MockStockApiClient` 換成真實 Dio client:
- 真 `StockApiClient` 打 `/stocks/search` 與 `/quotes/{symbol}/range`
- `quote_repository` 含降級(timeout/404 → `Result.failure`)
- dio timeout connect 3s / receive 5s
- unit test 模擬 timeout / 404
- `--dart-define=STOCK_API_BASE=https://stock.wisplu.com.tw`(預設值已是它)

> Step 11 改 app 端(`lib/...`),Step 10 在 `stock_calendar_backend/`——雖同一個 monorepo,仍分開 commit(`feat(step10)` / `feat(step11)`)、分開驗收。
