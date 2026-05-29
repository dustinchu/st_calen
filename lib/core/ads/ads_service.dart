import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 廣告種類。
enum AdKind { banner, interstitial }

// Google 官方測試 ad unit（debug 一律用，release 缺注入值時 fallback）。
const String kTestBannerAndroid = 'ca-app-pub-3940256099942544/9214589741';
const String kTestBannerIos = 'ca-app-pub-3940256099942544/2435281174';
const String kTestInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
const String kTestInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';

// 正式 ad unit 由 --dart-define 注入（android / ios × banner / interstitial）。
const String _envBannerAndroid = String.fromEnvironment('ADMOB_BANNER_ANDROID');
const String _envBannerIos = String.fromEnvironment('ADMOB_BANNER_IOS');
const String _envInterstitialAndroid =
    String.fromEnvironment('ADMOB_INTERSTITIAL_ANDROID');
const String _envInterstitialIos =
    String.fromEnvironment('ADMOB_INTERSTITIAL_IOS');

String _testId(bool isAndroid, AdKind kind) {
  switch (kind) {
    case AdKind.banner:
      return isAndroid ? kTestBannerAndroid : kTestBannerIos;
    case AdKind.interstitial:
      return isAndroid ? kTestInterstitialAndroid : kTestInterstitialIos;
  }
}

/// 選 ad unit ID。
/// debug：一律測試 unit（忽略注入值）。
/// release：用注入值；缺值（null/空）→ fallback 測試 unit（永不 crash）。
String adUnitId({
  required bool isDebug,
  required bool isAndroid,
  required AdKind kind,
  String? injectedId,
}) {
  if (isDebug) return _testId(isAndroid, kind);
  if (injectedId != null && injectedId.isNotEmpty) return injectedId;
  return _testId(isAndroid, kind);
}

/// 是否該顯示 interstitial。
/// 「每 3 次出圖才一次」：exportCount 為 3 的倍數。
/// 「每用戶每天最多 3 次」：當日已顯示 < 3；跨日（countDate != today）計數重置。
bool shouldShowInterstitial({
  required int exportCount,
  required int shownToday,
  required DateTime countDate,
  required DateTime today,
}) {
  if (exportCount <= 0 || exportCount % 3 != 0) return false;
  final effectiveShown = _sameDay(countDate, today) ? shownToday : 0;
  return effectiveShown < 3;
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _injectedId(bool isAndroid, AdKind kind) {
  switch (kind) {
    case AdKind.banner:
      return isAndroid ? _envBannerAndroid : _envBannerIos;
    case AdKind.interstitial:
      return isAndroid ? _envInterstitialAndroid : _envInterstitialIos;
  }
}

/// 依當前 build mode / 平台解析該用哪個 ad unit ID。
String resolveAdUnitId(AdKind kind) => adUnitId(
      isDebug: kDebugMode,
      isAndroid: Platform.isAndroid,
      kind: kind,
      injectedId: _injectedId(Platform.isAndroid, kind),
    );

/// AdMob 廣告載入 / 顯示 + interstitial 頻率控制。
///
/// 與 bootstrap 既有 `MobileAds.instance.initialize()` 分層：
/// init 留 bootstrap，本檔只負責載入 / 顯示 / 控頻率 / ATT。
/// 頻率計數純記憶體（App 關閉即重置，Phase 1 簡化，不動 Hive schema）。
/// 平台互動（InterstitialAd / ATT plugin）不單測，
/// 純邏輯（[adUnitId] / [shouldShowInterstitial]）抽出單測。
class AdsService {
  int _exportCount = 0;
  int _shownToday = 0;
  DateTime? _countDate;
  InterstitialAd? _interstitial;

  /// iOS ATT：首次（notDetermined）才跳系統授權 dialog。
  /// Android / 非 iOS no-op。應在 MobileAds.initialize 前呼叫（取 IDFA）。
  Future<void> requestTrackingAuthorization() async {
    if (!Platform.isIOS) return;
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  /// 預載 interstitial（dismiss / 顯示失敗後自動補載下一個）。
  void preloadInterstitial() {
    InterstitialAd.load(
      adUnitId: resolveAdUnitId(AdKind.interstitial),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitial = null;
              preloadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              _interstitial = null;
              preloadInterstitial();
            },
          );
          _interstitial = ad;
        },
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  /// 出圖完成後呼叫。控頻率後決定是否顯示 interstitial。
  /// 廣告尚未備妥則先預載，留待下次出圖顯示。
  void onImageExported() {
    _exportCount++;
    final now = DateTime.now();
    if (!shouldShowInterstitial(
      exportCount: _exportCount,
      shownToday: _shownToday,
      countDate: _countDate ?? now,
      today: now,
    )) {
      return;
    }
    final ad = _interstitial;
    if (ad == null) {
      preloadInterstitial();
      return;
    }
    if (_countDate == null || !_sameDay(_countDate!, now)) {
      _shownToday = 0;
      _countDate = now;
    }
    _shownToday++;
    ad.show();
    _interstitial = null;
  }
}

/// 全域單例（對齊 `notificationService`）。
final AdsService adsService = AdsService();
