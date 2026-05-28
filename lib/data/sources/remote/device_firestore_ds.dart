import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/result.dart';

/// 裝置註冊（FCM token 等）的 Firestore 遠端資料來源。
///
/// 路徑：`users/{uid}/devices/{deviceId}`。`deviceId` 由呼叫端傳入
/// （Step 22 用 `device_info_plus` 取得，本 step 只接介面）。
///
/// FCM token 只寫不讀，無 watch / list 介面。
class DeviceFirestoreDataSource {
  final FirebaseFirestore _firestore;

  DeviceFirestoreDataSource(this._firestore);

  DocumentReference<Map<String, dynamic>> _doc(String uid, String deviceId) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('devices')
          .doc(deviceId);

  Future<Result<Map<String, dynamic>, AppError>> get({
    required String uid,
    required String deviceId,
  }) async {
    try {
      final snap = await _doc(uid, deviceId).get();
      if (!snap.exists) {
        return Result.failure(NotFoundError('device not found: $deviceId'));
      }
      return Result.success(snap.data()!);
    } on FirebaseException catch (e) {
      return Result.failure(_mapFirebaseException(e));
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  Future<Result<void, AppError>> put({
    required String uid,
    required String deviceId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _doc(uid, deviceId).set(data);
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(_mapFirebaseException(e));
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  Future<Result<void, AppError>> delete({
    required String uid,
    required String deviceId,
  }) async {
    try {
      await _doc(uid, deviceId).delete();
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(_mapFirebaseException(e));
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  AppError _mapFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'unavailable':
      case 'deadline-exceeded':
      case 'cancelled':
        return NetworkError('${e.code}: ${e.message ?? ''}');
      case 'not-found':
        return NotFoundError('${e.code}: ${e.message ?? ''}');
      default:
        return UnknownError('${e.code}: ${e.message ?? ''}');
    }
  }
}
