import 'package:firebase_analytics/firebase_analytics.dart';

/// 組裝 Analytics 事件參數：去除 null 值（Analytics 僅接受非 null 的 String/num）。
///
/// 抽成純函式以便單測（Step 24 決策5：plugin 互動靠實機，參數組裝靠單測）。
Map<String, Object> buildAnalyticsParams(Map<String, Object?> raw) {
  final params = <String, Object>{};
  raw.forEach((key, value) {
    if (value != null) params[key] = value;
  });
  return params;
}

/// 關鍵事件埋點 → Firebase Analytics。
///
/// 事件清單（Step 24 自訂，05-features 無指定）：
/// - `add_stock`         params: symbol, market
/// - `create_prediction` params: symbol, direction
/// - `share_image`       params: template, method（save / share）
class AnalyticsService {
  AnalyticsService([FirebaseAnalytics? analytics]) : _analytics = analytics;

  // 延後解析 instance（避免 Firebase 未 init 時於建構即 throw，如單測環境）。
  final FirebaseAnalytics? _analytics;

  Future<void> _log(String name, Map<String, Object?> raw) async {
    try {
      final analytics = _analytics ?? FirebaseAnalytics.instance;
      await analytics.logEvent(
        name: name,
        parameters: buildAnalyticsParams(raw),
      );
    } catch (_) {
      // 埋點失敗不可中斷使用者流程（Firebase 未初始化 / plugin 錯誤皆 swallow）。
    }
  }

  Future<void> logAddStock({required String symbol, required String market}) =>
      _log('add_stock', {'symbol': symbol, 'market': market});

  Future<void> logCreatePrediction({
    required String symbol,
    required String direction,
  }) =>
      _log('create_prediction', {'symbol': symbol, 'direction': direction});

  Future<void> logShareImage({
    required String template,
    required String method,
  }) =>
      _log('share_image', {'template': template, 'method': method});
}

final analyticsService = AnalyticsService();
