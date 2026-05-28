import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/result.dart';
import '../../models/calendar_doc.dart';

/// CalendarDoc 的 Firestore 遠端資料來源（薄層 wrapper）。
///
/// 路徑：`users/{uid}/calendars/{calendarId}`，`calendarId` = `CalendarDoc.id`（uuid）。
///
/// **序列化決策（Step 8）**：DateTime 欄位（`createdAt` / `updatedAt` / `predictions[].date`）
/// 寫入 Firestore 用 `Timestamp` 原生型別，可做 server-side range query；讀回時再轉成
/// ISO 8601 String 餵給 `CalendarDoc.fromJson()`（json_serializable 預設吃 String）。
/// `Stock.market` 等 enum 沿用 `toJson()` 的 `name` 字串。
///
/// **Stream 契約（Step 8）**：[watch] / [watchByStock] 對齊 [local DS]
/// （`box.watch()`）的「不補初始 emit」契約——用 `.skip(1)` 跳過 Firestore snapshot
/// listener 預設的第一筆當前狀態。Repository（Step 9）合成 stream 時：
/// 1. `get()` 拿一次當前值；2. `watch()` 接後續 delta。Local / Remote 行為對稱。
///
/// 不做 retry / queue / cache，這些屬於 Repository 層。
class CalendarFirestoreDataSource {
  final FirebaseFirestore _firestore;

  CalendarFirestoreDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('calendars');

  Future<Result<CalendarDoc, AppError>> get({
    required String uid,
    required String calendarId,
  }) async {
    try {
      final snap = await _col(uid).doc(calendarId).get();
      if (!snap.exists) {
        return Result.failure(NotFoundError('calendar not found: $calendarId'));
      }
      return Result.success(_fromFirestore(snap.data()!));
    } on FirebaseException catch (e) {
      return Result.failure(_mapFirebaseException(e));
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  Future<Result<List<CalendarDoc>, AppError>> listByStock({
    required String uid,
    required String symbol,
  }) async {
    try {
      final snap =
          await _col(uid).where('symbol', isEqualTo: symbol).get();
      final docs = snap.docs
          .map((d) => _fromFirestore(d.data()))
          .toList(growable: false);
      return Result.success(docs);
    } on FirebaseException catch (e) {
      return Result.failure(_mapFirebaseException(e));
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  Future<Result<void, AppError>> put({
    required String uid,
    required CalendarDoc doc,
  }) async {
    try {
      await _col(uid).doc(doc.id).set(_toFirestore(doc));
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(_mapFirebaseException(e));
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  Future<Result<void, AppError>> delete({
    required String uid,
    required String calendarId,
  }) async {
    try {
      await _col(uid).doc(calendarId).delete();
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(_mapFirebaseException(e));
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  /// 訂閱單一 calendar doc 變動。emit `CalendarDoc?`（null = 已刪除）。
  /// `.skip(1)` 跳過 snapshot listener 預設的初始 emit，對齊 local DS 契約。
  Stream<CalendarDoc?> watch({
    required String uid,
    required String calendarId,
  }) {
    return _col(uid).doc(calendarId).snapshots().skip(1).map((snap) {
      if (!snap.exists) return null;
      return _fromFirestore(snap.data()!);
    });
  }

  /// 訂閱指定 symbol 名下的 calendar 變動，emit 整批當前 query 結果。
  /// `.skip(1)` 跳過初始 emit。
  Stream<List<CalendarDoc>> watchByStock({
    required String uid,
    required String symbol,
  }) {
    return _col(uid)
        .where('symbol', isEqualTo: symbol)
        .snapshots()
        .skip(1)
        .map((snap) => snap.docs
            .map((d) => _fromFirestore(d.data()))
            .toList(growable: false));
  }

  // ─── 序列化 helpers ─────────────────────────────────────────────────────────

  Map<String, dynamic> _toFirestore(CalendarDoc doc) {
    final json = doc.toJson();
    json['createdAt'] = Timestamp.fromDate(doc.createdAt);
    json['updatedAt'] = Timestamp.fromDate(doc.updatedAt);
    json['predictions'] = doc.predictions.map((p) {
      final pj = p.toJson();
      pj['date'] = Timestamp.fromDate(p.date);
      return pj;
    }).toList();
    return json;
  }

  CalendarDoc _fromFirestore(Map<String, dynamic> data) {
    final m = Map<String, dynamic>.from(data);
    m['createdAt'] = _timestampToIso(m['createdAt']);
    m['updatedAt'] = _timestampToIso(m['updatedAt']);
    final preds = m['predictions'];
    if (preds is List) {
      m['predictions'] = preds.map((p) {
        final pm = Map<String, dynamic>.from(p as Map);
        pm['date'] = _timestampToIso(pm['date']);
        return pm;
      }).toList();
    }
    return CalendarDoc.fromJson(m);
  }

  String _timestampToIso(Object? v) {
    if (v is Timestamp) return v.toDate().toUtc().toIso8601String();
    if (v is String) return v;
    throw FormatException('expected Timestamp or ISO String, got ${v.runtimeType}');
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
