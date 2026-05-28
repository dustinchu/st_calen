import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/core/utils/result.dart';
import 'package:stock_calendar/data/sources/remote/device_firestore_ds.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late DeviceFirestoreDataSource ds;

  const uid = 'user-1';
  const deviceId = 'device-A';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    ds = DeviceFirestoreDataSource(firestore);
  });

  test('put then get round trip', () async {
    final data = {
      'fcmToken': 'tok-123',
      'platform': 'ios',
      'appVersion': '2.0.0',
    };
    final put = await ds.put(uid: uid, deviceId: deviceId, data: data);
    expect(put.isSuccess, isTrue);

    final got = await ds.get(uid: uid, deviceId: deviceId);
    final value = (got as Success<Map<String, dynamic>, AppError>).value;
    expect(value['fcmToken'], 'tok-123');
    expect(value['platform'], 'ios');
  });

  test('get returns NotFoundError when device missing', () async {
    final r = await ds.get(uid: uid, deviceId: 'never');
    expect(r.isFailure, isTrue);
    expect((r as Failure<Map<String, dynamic>, AppError>).error,
        isA<NotFoundError>());
  });

  test('put overwrites existing device doc', () async {
    await ds.put(uid: uid, deviceId: deviceId, data: {'fcmToken': 'old'});
    await ds.put(uid: uid, deviceId: deviceId, data: {'fcmToken': 'new'});
    final got = await ds.get(uid: uid, deviceId: deviceId);
    expect((got as Success<Map<String, dynamic>, AppError>).value['fcmToken'],
        'new');
  });

  test('delete then get returns NotFoundError', () async {
    await ds.put(uid: uid, deviceId: deviceId, data: {'fcmToken': 'x'});
    final del = await ds.delete(uid: uid, deviceId: deviceId);
    expect(del.isSuccess, isTrue);
    final got = await ds.get(uid: uid, deviceId: deviceId);
    expect((got as Failure<Map<String, dynamic>, AppError>).error,
        isA<NotFoundError>());
  });

  test('delete non-existent device still succeeds', () async {
    final del = await ds.delete(uid: uid, deviceId: 'never-existed');
    expect(del.isSuccess, isTrue);
  });
}
