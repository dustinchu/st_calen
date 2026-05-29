/// App 級常數集中點。
///
/// 環境變數從 `--dart-define=...` 注入，預設值對齊 production。

const String kStockApiBaseUrl = String.fromEnvironment(
  'STOCK_API_BASE',
  defaultValue: 'https://stock.wisplu.com.tw',
);

// TODO(step26): 替換為正式上架的隱私權政策 / 服務條款網址（目前為 placeholder）。
const String kPrivacyPolicyUrl = 'https://stock.wisplu.com.tw/privacy';
const String kTermsOfServiceUrl = 'https://stock.wisplu.com.tw/terms';
