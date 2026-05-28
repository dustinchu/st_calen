import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/storage/hive_boxes.dart';
import '../core/storage/hive_init.dart';
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
  await _ensureSignedIn();

  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Taipei'));

  unawaited(MobileAds.instance.initialize());

  runApp(const ProviderScope(child: MyApp()));
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
