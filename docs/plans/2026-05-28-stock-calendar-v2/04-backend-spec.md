# 04 — 後端 API 規格（stock.wisplu.com.tw）

## 部署環境

- 部署在公司既有 Dokploy 環境
- 與其他服務（如 hainihongo）共用 `dokploy-network` + Traefik + Let's Encrypt
- 子網域：`stock.wisplu.com.tw`
- 技術棧：**FastAPI + Uvicorn (ASGI) + Postgres**（沿用 hainihongo 模式）
- 排程：獨立 `stock-cron` container（同個 image，不同 entrypoint）

## docker-compose.yml（參考結構）

```yaml
version: '3.8'

services:
  stock-web:
    build: .
    restart: always
    env_file:
      - .env
    environment:
      SERVICE_NAME: web
    networks:
      - dokploy-network
    command: ["sh", "-c", "alembic upgrade head && gunicorn app.main:app --workers 2 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000 --access-logfile - --error-logfile - --timeout 60 --forwarded-allow-ips=*"]
    labels:
      - traefik.enable=true
      - traefik.http.routers.stock-web.rule=Host(`stock.wisplu.com.tw`)
      - traefik.http.routers.stock-web.entrypoints=websecure
      - traefik.http.routers.stock-web.tls.certResolver=letsencrypt
      - traefik.http.services.stock-web.loadbalancer.server.port=8000

  stock-cron:
    build: .
    restart: always
    depends_on:
      stock-web:
        condition: service_started
    env_file:
      - .env
    environment:
      SERVICE_NAME: cron
    networks:
      - dokploy-network
    command: python -m app.cron_main

networks:
  dokploy-network:
    external: true
```

`POSTGRES_URL` 透過 Dokploy secrets 注入 `.env`，Postgres 為共用獨立 app。

## 資料表

### `stocks`

| 欄位 | 型別 | 說明 |
|------|------|------|
| symbol | text PK | 2330.TW / AAPL |
| market | text | tw / us |
| name | text | 台積電 / Apple Inc. |
| sector | text NULL | |
| updated_at | timestamptz | |

### `quotes`

| 欄位 | 型別 | 說明 |
|------|------|------|
| symbol | text | FK -> stocks.symbol |
| trade_date | date | |
| open | numeric | |
| high | numeric | |
| low | numeric | |
| close | numeric | |
| change_percent | numeric | |
| volume | bigint | |
| source | text | twse / yahoo |
| inserted_at | timestamptz | |

PK = (symbol, trade_date)，加 index on `trade_date`。

### `watched_symbols`（被 App 端關注的清單，給 cron 用）

| 欄位 | 型別 | 說明 |
|------|------|------|
| symbol | text PK | |
| last_requested_at | timestamptz | App 最近一次查詢時間 |

> 規則：App 端每次查詢 `/quote/{symbol}` 時，後端順手 upsert `watched_symbols`，cron 只抓 30 天內被查過的 symbol，節省成本。

## API 端點

### `GET /api/v1/stocks/search?q={keyword}&market={tw|us}`

模糊搜尋股票（代號或名稱）。

**Response 200**
```json
{
  "items": [
    { "symbol": "2330.TW", "market": "tw", "name": "台積電" },
    { "symbol": "2330", "market": "tw", "name": "台積電" }
  ]
}
```

### `GET /api/v1/stocks/{symbol}`

取得股票基本資料。

**Response 200**
```json
{
  "symbol": "2330.TW",
  "market": "tw",
  "name": "台積電",
  "sector": "半導體"
}
```

**Response 404**
```json
{ "error": "stock_not_found" }
```

### `GET /api/v1/quotes/{symbol}?date={yyyy-MM-dd}`

取得指定日期收盤價。`date` 省略則回最新一筆。

**Response 200**
```json
{
  "symbol": "2330.TW",
  "date": "2026-05-27",
  "open": 1180,
  "high": 1200,
  "low": 1175,
  "close": 1195,
  "change_percent": 1.27,
  "source": "twse"
}
```

**Response 404**：當日無資料（休市 / 未開盤）。

### `GET /api/v1/quotes/{symbol}/range?from={d}&to={d}`

範圍查詢（用於月曆載入時批次取得整月資料）。

**Response 200**
```json
{
  "symbol": "2330.TW",
  "quotes": [
    { "date": "2026-05-01", "close": 1190, ... },
    { "date": "2026-05-02", "close": 1192, ... }
  ]
}
```

### `GET /api/v1/health`

健康檢查（App 啟動時可選擇性 ping，決定是否啟用自動結算 UI）。

```json
{ "status": "ok", "now": "2026-05-28T01:23:45Z" }
```

## 資料來源策略

### 台股
- 主來源：**TWSE 公開資料** (`https://openapi.twse.com.tw/`)
- 備援：Yahoo TW (`https://tw.stock.yahoo.com/`) HTML 爬蟲

### 美股
- 主來源：**Yahoo Finance** 非官方 endpoint (`query1.finance.yahoo.com/v7/finance/quote`)
- 備援：Stooq (`https://stooq.com/q/d/?s={symbol}&f=...&i=d`) CSV

主來源失敗自動退到備援，雙雙失敗則該日資料缺失，App 端會 fallback 手動輸入。

## 排程（cron）

- **台股 cron**：每日 15:00 (Asia/Taipei) — 收盤後抓當日所有 `watched_symbols`（市場過濾 tw）
- **美股 cron**：每日 17:00 (America/New_York) ≈ 隔日 06:00 (Asia/Taipei) — 收盤後抓 `watched_symbols`（市場過濾 us）
- **每週日 02:00**：清理 `watched_symbols` 中 30 天未被查的紀錄

使用 `APScheduler` 在 `app/cron_main.py` 內排程。

## 限流與快取

- 同一個 symbol 同一天的 quote → Postgres 內已有就直接回，不打外部
- Nginx / Traefik 層加 rate limit：每 IP 60 req/min
- 回應加 `Cache-Control: public, max-age=300`（5 分鐘）

## App 端整合注意

- dio timeout：**connect 3s / receive 5s**（避免阻塞 UI）
- 失敗時 ViewModel 回傳 `Result.failure(AppError.quoteUnavailable)`
- UI 顯示「無法取得，請手動輸入收盤價」+ 輸入框
- 不重試，避免雪崩（後端有問題時不要再炸後端）

## 安全

- API 暫時開放公開（無需 token）
- 之後可加 simple API key（從 `--dart-define=STOCK_API_KEY=xxx` 注入）防爬
- HTTPS only（Traefik 已處理）
