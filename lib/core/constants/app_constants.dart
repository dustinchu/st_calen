/// App 級常數集中點。
///
/// 環境變數從 `--dart-define=...` 注入，預設值對齊 production。

const String kStockApiBaseUrl = String.fromEnvironment(
  'STOCK_API_BASE',
  defaultValue: 'https://stock.wisplu.com.tw',
);
