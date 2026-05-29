import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/core/analytics/analytics_service.dart';

void main() {
  group('buildAnalyticsParams', () {
    test('保留非 null 值', () {
      final params = buildAnalyticsParams({'symbol': '2330', 'market': 'tw'});
      expect(params, {'symbol': '2330', 'market': 'tw'});
    });

    test('去除 null 值（其餘保留）', () {
      final params = buildAnalyticsParams({'symbol': '2330', 'note': null});
      expect(params, {'symbol': '2330'});
      expect(params.containsKey('note'), isFalse);
    });

    test('全 null → 空 map', () {
      final params = buildAnalyticsParams({'a': null, 'b': null});
      expect(params, isEmpty);
    });

    test('空輸入 → 空 map', () {
      expect(buildAnalyticsParams({}), isEmpty);
    });

    test('保留數值型別（非僅字串）', () {
      final params = buildAnalyticsParams({'count': 3, 'symbol': '2330'});
      expect(params['count'], 3);
      expect(params['symbol'], '2330');
    });

    test('回傳型別為 Map<String, Object>（Analytics 不接受 null 值）', () {
      final params = buildAnalyticsParams({'x': null, 'y': 'v'});
      expect(params, isA<Map<String, Object>>());
    });
  });
}
