import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/core/ads/ads_service.dart';

void main() {
  group('adUnitId', () {
    test('debug 一律回測試 unit（忽略注入值）', () {
      final id = adUnitId(
        isDebug: true,
        isAndroid: true,
        kind: AdKind.banner,
        injectedId: 'ca-app-pub-REAL/123',
      );
      expect(id, kTestBannerAndroid);
    });

    test('release 有注入 → 回注入值', () {
      final id = adUnitId(
        isDebug: false,
        isAndroid: true,
        kind: AdKind.interstitial,
        injectedId: 'ca-app-pub-REAL/999',
      );
      expect(id, 'ca-app-pub-REAL/999');
    });

    test('release 缺值（空字串）→ fallback 測試 unit', () {
      final id = adUnitId(
        isDebug: false,
        isAndroid: false,
        kind: AdKind.interstitial,
        injectedId: '',
      );
      expect(id, kTestInterstitialIos);
    });

    test('banner / interstitial × android / ios 測試 unit 對應正確', () {
      expect(
        adUnitId(isDebug: true, isAndroid: true, kind: AdKind.banner),
        kTestBannerAndroid,
      );
      expect(
        adUnitId(isDebug: true, isAndroid: false, kind: AdKind.banner),
        kTestBannerIos,
      );
      expect(
        adUnitId(isDebug: true, isAndroid: true, kind: AdKind.interstitial),
        kTestInterstitialAndroid,
      );
      expect(
        adUnitId(isDebug: true, isAndroid: false, kind: AdKind.interstitial),
        kTestInterstitialIos,
      );
    });
  });

  group('shouldShowInterstitial', () {
    final today = DateTime(2026, 5, 29);

    test('第 1、2 次出圖未到每 3 次 → false', () {
      expect(
        shouldShowInterstitial(
            exportCount: 1, shownToday: 0, countDate: today, today: today),
        isFalse,
      );
      expect(
        shouldShowInterstitial(
            exportCount: 2, shownToday: 0, countDate: today, today: today),
        isFalse,
      );
    });

    test('第 3 次出圖 → true', () {
      expect(
        shouldShowInterstitial(
            exportCount: 3, shownToday: 0, countDate: today, today: today),
        isTrue,
      );
    });

    test('第 6 次出圖且當日已顯示 2 次（< 3）→ true', () {
      expect(
        shouldShowInterstitial(
            exportCount: 6, shownToday: 2, countDate: today, today: today),
        isTrue,
      );
    });

    test('當日已顯示 3 次 → 即使第 9 次出圖也 false（每日上限）', () {
      expect(
        shouldShowInterstitial(
            exportCount: 9, shownToday: 3, countDate: today, today: today),
        isFalse,
      );
    });

    test('跨日 → 當日計數重置 → 第 3 次出圖回 true', () {
      final yesterday = DateTime(2026, 5, 28);
      expect(
        shouldShowInterstitial(
            exportCount: 3, shownToday: 3, countDate: yesterday, today: today),
        isTrue,
      );
    });
  });
}
