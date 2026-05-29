import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/core/firebase/fcm_service.dart';

void main() {
  group('buildDeviceDoc', () {
    test('含 fcmToken / platform / appVersion / updatedAt(serverTimestamp)', () {
      final doc = buildDeviceDoc(
        token: 'tok-123',
        platform: 'android',
        appVersion: '2.0.0',
      );
      expect(doc['fcmToken'], 'tok-123');
      expect(doc['platform'], 'android');
      expect(doc['appVersion'], '2.0.0');
      expect(doc['updatedAt'], isA<FieldValue>());
    });
  });

  group('shouldWriteDevice', () {
    test('uid 與 token 皆非空 → true', () {
      expect(shouldWriteDevice(uid: 'u1', token: 't1'), isTrue);
    });

    test('uid null（匿名登入離線失敗）→ false', () {
      expect(shouldWriteDevice(uid: null, token: 't1'), isFalse);
    });

    test('token null（iOS 未設 APNs）→ false', () {
      expect(shouldWriteDevice(uid: 'u1', token: null), isFalse);
    });

    test('空字串視為無效 → false', () {
      expect(shouldWriteDevice(uid: '', token: 't1'), isFalse);
      expect(shouldWriteDevice(uid: 'u1', token: ''), isFalse);
    });
  });

  group('pickDeviceId', () {
    test('iOS 用 identifierForVendor', () {
      expect(
        pickDeviceId(
          isIOS: true,
          iosIdentifierForVendor: 'ios-vendor-id',
          androidId: 'android-id',
        ),
        'ios-vendor-id',
      );
    });

    test('Android 用 androidId', () {
      expect(
        pickDeviceId(
          isIOS: false,
          iosIdentifierForVendor: 'ios-vendor-id',
          androidId: 'android-id',
        ),
        'android-id',
      );
    });

    test('原生 id null / 空 → null（呼叫端 gating 跳過寫入）', () {
      expect(pickDeviceId(isIOS: true, iosIdentifierForVendor: null), isNull);
      expect(pickDeviceId(isIOS: false, androidId: ''), isNull);
    });
  });
}
