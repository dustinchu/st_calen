import 'dart:async';

import 'package:hive/hive.dart';

import '../../core/firebase/auth_service.dart';
import '../../core/storage/hive_boxes.dart';
import '../../core/utils/result.dart';
import '../models/calendar_doc.dart';
import '../sources/local/calendar_local_ds.dart';
import '../sources/remote/calendar_firestore_ds.dart';

/// CalendarDoc 的 Repository：本地優先 + 背景同步 + 待同步佇列。
///
/// 寫入流程：
/// 1. `local.put` 立即完成，UI 透過 hot stream 收到更新。
/// 2. 背景 `unawaited` 推到 Firestore；失敗 → 把 composite key 塞進 meta box 的
///    `pending_calendar_writes` 佇列。
/// 3. 下次 [flushPendingWrites]（由呼叫端在 bootstrap / 網路恢復時觸發）逐筆重試。
///
/// 讀取流程：
/// - `get`：先 local；miss 且已登入 → 拉 remote（透過 `listByStock` + filter
///   year/month，因為 remote DS 沒有 `getByYearMonth` 介面）→ 寫回 local → 回值。
///   remote 也沒有 → 回 `Success(null)`（「沒預測過」是合法狀態，非 NotFoundError）。
/// - `watch`：先用 `get` 補初始 emit，再接 local `watchByStock`；每次 delta 都
///   re-read target (symbol, year, month)，避免 local DS 「同 symbol 任意 month
///   delete 一律 emit null」誤觸發。
///
/// 跨裝置即時同步：Phase 1 規格不接 Firestore snapshot listener，靠下次 `get`
/// 觸發 remote pull。
class CalendarRepository {
  final CalendarLocalDataSource _local;
  final CalendarFirestoreDataSource _remote;
  final AuthService _auth;
  final Box<dynamic> _metaBox;

  CalendarRepository({
    required CalendarLocalDataSource local,
    required CalendarFirestoreDataSource remote,
    required AuthService auth,
    required Box<dynamic> metaBox,
  })  : _local = local,
        _remote = remote,
        _auth = auth,
        _metaBox = metaBox;

  // ─── 讀取 ────────────────────────────────────────────────────────────────

  Future<Result<CalendarDoc?, AppError>> get({
    required String symbol,
    required int year,
    required int month,
  }) async {
    final localR = await _local.get(symbol: symbol, year: year, month: month);
    if (localR is Success<CalendarDoc, AppError>) {
      return Result.success(localR.value);
    }
    // local miss → 嘗試 remote（已登入才試）
    final uid = _auth.currentUserId;
    if (uid == null) return const Result.success(null);

    final remoteR = await _remote.listByStock(uid: uid, symbol: symbol);
    switch (remoteR) {
      case Success(value: final list):
        final match = list
            .where((d) => d.year == year && d.month == month)
            .toList(growable: false);
        if (match.isEmpty) return const Result.success(null);
        final doc = match.first;
        // 寫回 local cache（失敗忽略，下次 get 還會重試）
        await _local.put(doc);
        return Result.success(doc);
      case Failure(error: final e):
        if (e is NotFoundError) return const Result.success(null);
        return Result.failure(e);
    }
  }

  /// Hot stream：初始 emit 來自 [get]（local-first，可能 fall through 到 remote），
  /// 之後接 local box 變動。每次變動都 re-read target (symbol, year, month)，
  /// 避免 local DS 「同 symbol 任意 month delete 一律 emit null」誤觸發。
  ///
  /// 採用手動 [StreamController] 管理內部 subscription（不用 `async*` + `await for`），
  /// 避免 broadcast stream 在 listener cancel 時內部 subscription 漏拆。
  Stream<CalendarDoc?> watch({
    required String symbol,
    required int year,
    required int month,
  }) {
    late StreamController<CalendarDoc?> controller;
    StreamSubscription<CalendarDoc?>? inner;

    Future<void> reread() async {
      final r = await _local.get(symbol: symbol, year: year, month: month);
      if (controller.isClosed) return;
      controller.add(switch (r) {
        Success(value: final v) => v,
        Failure() => null,
      });
    }

    controller = StreamController<CalendarDoc?>(
      onListen: () async {
        final initial = await get(symbol: symbol, year: year, month: month);
        if (controller.isClosed) return;
        controller.add(initial.fold((v) => v, (_) => null));
        inner = _local.watchByStock(symbol).listen((_) => reread());
      },
      onCancel: () async {
        await inner?.cancel();
        inner = null;
      },
    );
    return controller.stream;
  }

  // ─── 寫入 ────────────────────────────────────────────────────────────────

  Future<Result<void, AppError>> put(CalendarDoc doc) async {
    final localR = await _local.put(doc);
    if (localR is Failure<void, AppError>) return localR;

    final uid = _auth.currentUserId;
    if (uid != null) {
      unawaited(_pushPutToRemote(uid: uid, doc: doc));
    }
    return const Result.success(null);
  }

  Future<Result<void, AppError>> delete({
    required String symbol,
    required int year,
    required int month,
  }) async {
    // 先讀出 calendarId，刪 local 後就拿不到了
    final docR = await _local.get(symbol: symbol, year: year, month: month);
    final String? calendarId =
        docR is Success<CalendarDoc, AppError> ? docR.value.id : null;

    final localR = await _local.delete(symbol: symbol, year: year, month: month);
    if (localR is Failure<void, AppError>) return localR;

    final uid = _auth.currentUserId;
    if (uid != null && calendarId != null) {
      unawaited(_pushDeleteToRemote(uid: uid, calendarId: calendarId));
    }
    return const Result.success(null);
  }

  // ─── 背景同步 ────────────────────────────────────────────────────────────

  Future<void> _pushPutToRemote({
    required String uid,
    required CalendarDoc doc,
  }) async {
    final key = CalendarLocalDataSource.keyOf(doc.symbol, doc.year, doc.month);
    try {
      final r = await _remote.put(uid: uid, doc: doc);
      if (r.isSuccess) {
        await _removeFromQueue(kPendingCalendarWritesKey, key);
      } else {
        await _addToQueue(kPendingCalendarWritesKey, key);
      }
    } catch (_) {
      await _addToQueue(kPendingCalendarWritesKey, key);
    }
  }

  Future<void> _pushDeleteToRemote({
    required String uid,
    required String calendarId,
  }) async {
    try {
      final r = await _remote.delete(uid: uid, calendarId: calendarId);
      if (r.isSuccess) {
        await _removeFromQueue(kPendingCalendarDeletesKey, calendarId);
      } else {
        await _addToQueue(kPendingCalendarDeletesKey, calendarId);
      }
    } catch (_) {
      await _addToQueue(kPendingCalendarDeletesKey, calendarId);
    }
  }

  /// 重試 meta box 內的待同步佇列。bootstrap 完成 + auth 完成後呼叫一次；
  /// 之後可由網路恢復事件再次呼叫（本 step 不接 connectivity_plus）。
  Future<void> flushPendingWrites() async {
    final uid = _auth.currentUserId;
    if (uid == null) return;

    // writes：composite key → 從 local 撈 doc → push
    final writes = _readQueue(kPendingCalendarWritesKey);
    for (final key in writes) {
      final parsed = _parseCompositeKey(key);
      if (parsed == null) {
        await _removeFromQueue(kPendingCalendarWritesKey, key);
        continue;
      }
      final (symbol, year, month) = parsed;
      final localR =
          await _local.get(symbol: symbol, year: year, month: month);
      if (localR is! Success<CalendarDoc, AppError>) {
        // local 已被刪除 → drop（delete queue 會處理 remote）
        await _removeFromQueue(kPendingCalendarWritesKey, key);
        continue;
      }
      final r = await _remote.put(uid: uid, doc: localR.value);
      if (r.isSuccess) {
        await _removeFromQueue(kPendingCalendarWritesKey, key);
      }
      // 失敗就保留下次再試
    }

    // deletes：calendarId → 直接 push
    final deletes = _readQueue(kPendingCalendarDeletesKey);
    for (final id in deletes) {
      final r = await _remote.delete(uid: uid, calendarId: id);
      if (r.isSuccess) {
        await _removeFromQueue(kPendingCalendarDeletesKey, id);
      }
    }
  }

  // ─── meta box helpers ───────────────────────────────────────────────────

  List<String> _readQueue(String key) {
    final raw = _metaBox.get(key);
    if (raw is List) return raw.cast<String>().toList(growable: false);
    return const [];
  }

  Future<void> _addToQueue(String key, String entry) async {
    final set = _readQueue(key).toSet()..add(entry);
    await _metaBox.put(key, set.toList(growable: false));
  }

  Future<void> _removeFromQueue(String key, String entry) async {
    final list = _readQueue(key);
    if (!list.contains(entry)) return;
    final updated = list.where((e) => e != entry).toList(growable: false);
    await _metaBox.put(key, updated);
  }

  /// `<symbol>:<YYYY-MM>` → `(symbol, year, month)`。
  /// symbol 本身可能含 `.`（如 `2330.TW`），但不會含 `:`，所以從右側切。
  (String, int, int)? _parseCompositeKey(String key) {
    final lastColon = key.lastIndexOf(':');
    if (lastColon <= 0 || lastColon == key.length - 1) return null;
    final symbol = key.substring(0, lastColon);
    final ym = key.substring(lastColon + 1);
    final parts = ym.split('-');
    if (parts.length != 2) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null) return null;
    return (symbol, year, month);
  }
}
