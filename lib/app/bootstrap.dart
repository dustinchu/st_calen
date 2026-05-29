import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/ads/ads_service.dart';
import '../core/crash/crash_service.dart';
import '../core/firebase/fcm_service.dart';
import '../core/notifications/notification_service.dart';
import '../core/storage/hive_boxes.dart';
import '../core/storage/hive_init.dart';
import '../data/models/app_settings.dart';
import '../data/sources/remote/device_firestore_ds.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp();
  // 全域錯誤接線（onError 雙鉤）緊接 Firebase init 後、其餘啟動流程之前，
  // 以盡早捕捉後續初始化的未捕捉錯誤。不讀任何 settings（避開 KI-1）。
  await crashService.init();

  await HiveInit.init();
  // meta box 在 bootstrap 開啟，讓 router redirect 可同步讀 onboarding flag。
  await Hive.openBox<dynamic>(kMetaBox);
  // calendar box 在 bootstrap 開啟，讓 CalendarViewModel sync 取得 box。
  await Hive.openBox<dynamic>(kCalendarsBox);
  // stocks box 在 bootstrap 開啟，讓 StockListViewModel sync 取得 box。
  await Hive.openBox<dynamic>(kStocksBox);
  // settings box 在 bootstrap 開啟（KI-1）：settingsLocalDataSourceProvider 以
  // 同步 Hive.box(kSettingsBox) 取 box，真機啟動 build SettingsViewModel 前若未開會 crash。
  final settingsBox = await Hive.openBox<dynamic>(kSettingsBox);
  await _ensureSignedIn();

  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Taipei'));

  await notificationService.init();
  unawaited(notificationService.requestPermissions());
  // KI-2：首次啟動依持久設定重排每日提醒。預設 notificationsEnabled=true，
  // 未曾 toggle 的使用者也能收到 14:30 提醒。applyEnabled 內 cancelAll + 同 id
  // zonedSchedule 覆蓋，idempotent，重複啟動安全。settings 缺值 → 預設 true。
  final storedSettings = settingsBox.get(kSettingsKey) as AppSettings?;
  if (storedSettings?.notificationsEnabled ?? true) {
    unawaited(notificationService.applyEnabled(true));
  }

  _startFcm();

  // iOS ATT 授權應在 MobileAds.initialize 前請求（取 IDFA）；Android no-op。
  await adsService.requestTrackingAuthorization();
  unawaited(MobileAds.instance.initialize());

  runApp(const ProviderScope(child: MyApp()));
}

/// FCM token 寫入 `users/{uid}/devices/{deviceId}`。
/// gate 在 uid 非空（離線匿名登入失敗 → 之後 userChanges emit uid 再補寫），
/// 並監聽 onTokenRefresh 自動更新。Phase 1 只存 token，不收 / 不發推播。
void _startFcm() {
  final fcmService = FcmService(
    deviceDs: DeviceFirestoreDataSource(FirebaseFirestore.instance),
  );
  unawaited(fcmService.requestPermission());
  fcmService.start(FirebaseAuth.instance.userChanges().map((u) => u?.uid));
}

/// 啟動時自動匿名登入。失敗（離線、provider 未啟用）只 swallow，
/// 不 block 啟動 —— AuthViewModel 之後仍會反映 signed-out 狀態，
/// UI 可繼續使用 Hive 本地資料。
Future<void> _ensureSignedIn() async {
  try {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (_) {
    // 之後 Step 9 sync 流程若需要 uid 會自行檢查 currentUserId == null。
  }
}
