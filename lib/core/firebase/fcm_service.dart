import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/sources/remote/device_firestore_ds.dart';

/// 組裝寫入 `users/{uid}/devices/{deviceId}` 的 doc。
/// updatedAt 用 serverTimestamp，由 Firestore 端蓋寫入時間（含 onTokenRefresh 更新）。
Map<String, dynamic> buildDeviceDoc({
  required String token,
  required String platform,
  required String appVersion,
}) =>
    {
      'fcmToken': token,
      'platform': platform,
      'appVersion': appVersion,
      'updatedAt': FieldValue.serverTimestamp(),
    };

/// gating：uid 與 token 皆非空才寫入。
/// bootstrap 匿名登入可能離線失敗 → uid 為 null；iOS 未設 APNs → token 可能為 null。
bool shouldWriteDevice({String? uid, String? token}) =>
    uid != null && uid.isNotEmpty && token != null && token.isNotEmpty;

/// 從平台原生識別碼挑 deviceId（不持久化，每次啟動現讀）。
/// 換裝置 → identifierForVendor / androidId 不同 → deviceId 不同。
/// null / 空 → 回 null，呼叫端 gating 會跳過寫入。
String? pickDeviceId({
  required bool isIOS,
  String? iosIdentifierForVendor,
  String? androidId,
}) {
  final raw = isIOS ? iosIdentifierForVendor : androidId;
  if (raw == null || raw.isEmpty) return null;
  return raw;
}

/// FCM 遠端推播 token 管理（Phase 1 只存 token，不收 / 不發推播）。
///
/// 與本地通知 `NotificationService` 分層：本檔只負責
/// 取 token / 請求權限 / 監聽 onTokenRefresh / 寫入 device doc。
/// 平台互動（FirebaseMessaging / device_info_plus / Firestore）不單測，
/// 純邏輯（[buildDeviceDoc] / [shouldWriteDevice] / [pickDeviceId]）抽出單測。
class FcmService {
  FcmService({
    required DeviceFirestoreDataSource deviceDs,
    FirebaseMessaging? messaging,
    DeviceInfoPlugin? deviceInfo,
  })  : _deviceDs = deviceDs,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final DeviceFirestoreDataSource _deviceDs;
  final FirebaseMessaging _messaging;
  final DeviceInfoPlugin _deviceInfo;

  String? _lastUid;
  StreamSubscription<String?>? _uidSub;
  StreamSubscription<String>? _tokenSub;

  /// 請求通知權限（iOS 會觸發系統 dialog；已授權則回當前狀態，不重複跳）。
  Future<void> requestPermission() => _messaging.requestPermission();

  /// bootstrap 呼叫一次。訂閱 uid 變動（含離線登入後恢復）與 onTokenRefresh。
  /// uid 首次出現 / 變動時取 token 寫入；token 輪替時以當前 uid 重寫。
  void start(Stream<String?> uidStream) {
    _uidSub = uidStream.listen((uid) {
      if (uid == null || uid == _lastUid) return;
      _lastUid = uid;
      unawaited(_register(uid));
    });
    _tokenSub = _messaging.onTokenRefresh.listen((token) {
      unawaited(_write(_lastUid, token));
    });
  }

  Future<void> dispose() async {
    await _uidSub?.cancel();
    await _tokenSub?.cancel();
  }

  Future<void> _register(String uid) async {
    final token = await _messaging.getToken();
    await _write(uid, token);
  }

  Future<void> _write(String? uid, String? token) async {
    if (!shouldWriteDevice(uid: uid, token: token)) return;
    final deviceId = await _resolveDeviceId();
    if (deviceId == null) return;
    final appVersion = (await PackageInfo.fromPlatform()).version;
    await _deviceDs.put(
      uid: uid!,
      deviceId: deviceId,
      data: buildDeviceDoc(
        token: token!,
        platform: Platform.isIOS ? 'ios' : 'android',
        appVersion: appVersion,
      ),
    );
  }

  Future<String?> _resolveDeviceId() async {
    if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      return pickDeviceId(
        isIOS: true,
        iosIdentifierForVendor: info.identifierForVendor,
      );
    }
    final info = await _deviceInfo.androidInfo;
    return pickDeviceId(isIOS: false, androidId: info.id);
  }
}
