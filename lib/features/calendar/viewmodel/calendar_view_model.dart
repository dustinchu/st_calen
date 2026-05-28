import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../data/models/calendar_doc.dart';
import '../../../data/models/prediction.dart';
import '../../../data/repositories/calendar_repository.dart';
import '../../../data/sources/local/calendar_local_ds.dart';
import '../../../data/sources/remote/calendar_firestore_ds.dart';
import '../../auth/viewmodel/auth_view_model.dart';

part 'calendar_view_model.g.dart';

/// Calendar 相關 box / DS / Repository 的 provider wiring。
/// Step 9 完成時刻意不開 provider，留到 Step 13 ViewModel 出現再一次接通。

@Riverpod(keepAlive: true)
CalendarLocalDataSource calendarLocalDataSource(Ref ref) =>
    CalendarLocalDataSource(Hive.box<dynamic>(kCalendarsBox));

@Riverpod(keepAlive: true)
CalendarFirestoreDataSource calendarFirestoreDataSource(Ref ref) =>
    CalendarFirestoreDataSource(FirebaseFirestore.instance);

@Riverpod(keepAlive: true)
CalendarRepository calendarRepository(Ref ref) => CalendarRepository(
      local: ref.watch(calendarLocalDataSourceProvider),
      remote: ref.watch(calendarFirestoreDataSourceProvider),
      auth: ref.watch(authServiceProvider),
      metaBox: Hive.box<dynamic>(kMetaBox),
    );

/// 當前選中的股票 symbol。Step 14 chips 切換會 update 這個 provider。
/// 本 step 還沒接 stock 管理 UI，初始為 null → CalendarScreen 顯示 empty state。
@Riverpod(keepAlive: true)
class CurrentSymbol extends _$CurrentSymbol {
  @override
  String? build() => null;

  void set(String? symbol) => state = symbol;
}

/// 當前 focused month（取月初 UTC，day=1, time=0）。
/// table_calendar 的 onPageChanged 會 update 這個 provider。
@Riverpod(keepAlive: true)
class FocusedMonth extends _$FocusedMonth {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime.utc(now.year, now.month, 1);
  }

  void set(DateTime month) {
    state = DateTime.utc(month.year, month.month, 1);
  }
}

/// 訂閱當前 (symbol, year, month) 的 CalendarDoc。
/// symbol == null → 直接 emit null（empty state），不訂閱 repository。
/// symbol 或 month 變動 → riverpod 自動 invalidate + 重新 subscribe。
@riverpod
Stream<CalendarDoc?> calendarViewModel(Ref ref) {
  final symbol = ref.watch(currentSymbolProvider);
  if (symbol == null) return Stream.value(null);
  final month = ref.watch(focusedMonthProvider);
  return ref.watch(calendarRepositoryProvider).watch(
        symbol: symbol,
        year: month.year,
        month: month.month,
      );
}

/// CalendarDoc.predictions list → Map<day-of-month, Prediction>，
/// 提供 widget 用 O(1) lookup。Pure derived state，無 side effect。
Map<int, Prediction> predictionsByDay(CalendarDoc? doc) {
  if (doc == null) return const {};
  return {
    for (final p in doc.predictions) p.date.toLocal().day: p,
  };
}
