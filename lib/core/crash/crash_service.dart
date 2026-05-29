import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show FlutterError;

/// 全域錯誤接線 → Crashlytics。
///
/// 決策（Step 24）：
/// - `FlutterError.onError` + `PlatformDispatcher.onError` 雙鉤（Flutter 3.x 官方推薦），
///   不用 runZonedGuarded 包 runApp。
/// - debug 也強制開啟收集（`setCrashlyticsCollectionEnabled(true)`），讓「debug 故意
///   crash → console 收到」的驗收可直接在 debug 跑。
class CrashService {
  CrashService([FirebaseCrashlytics? crashlytics])
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  /// 在 bootstrap（Firebase.initializeApp 之後、runApp 之前）呼叫。
  Future<void> init() async {
    await _crashlytics.setCrashlyticsCollectionEnabled(true);

    // Flutter framework 內的同步致命錯誤。
    FlutterError.onError = _crashlytics.recordFlutterFatalError;

    // 非同步、未被 framework 捕捉的錯誤；回傳 true 表示已處理。
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }
}

final crashService = CrashService();
