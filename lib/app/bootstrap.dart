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

import '../core/firebase/fcm_service.dart';
import '../core/notifications/notification_service.dart';
import '../core/storage/hive_boxes.dart';
import '../core/storage/hive_init.dart';
import '../data/sources/remote/device_firestore_ds.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp();
  await HiveInit.init();
  // meta box 在 bootstrap 開啟，讓 router redirect 可同步讀 onboarding flag。
  await Hive.openBox<dynamic>(kMetaBox);
  // calendar box 在 bootstrap 開啟，讓 CalendarViewModel sync 取得 box。
  await Hive.openBox<dynamic>(kCalendarsBox);
  // stocks box 在 bootstrap 開啟，讓 StockListViewModel sync 取得 box。
  await Hive.openBox<dynamic>(kStocksBox);
  await _ensureSignedIn();

  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Taipei'));

  await notificationService.init();
  unawaited(notificationService.requestPermissions());

  _startFcm();

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
