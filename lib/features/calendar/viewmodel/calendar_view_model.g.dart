// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarLocalDataSourceHash() =>
    r'e477788cc806d740bd73282d2d67b83f82d0e888';

/// Calendar 相關 box / DS / Repository 的 provider wiring。
/// Step 9 完成時刻意不開 provider，留到 Step 13 ViewModel 出現再一次接通。
///
/// Copied from [calendarLocalDataSource].
@ProviderFor(calendarLocalDataSource)
final calendarLocalDataSourceProvider =
    Provider<CalendarLocalDataSource>.internal(
  calendarLocalDataSource,
  name: r'calendarLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CalendarLocalDataSourceRef = ProviderRef<CalendarLocalDataSource>;
String _$calendarFirestoreDataSourceHash() =>
    r'8988edbd093c17e803129321369ff25ab5cc8f32';

/// See also [calendarFirestoreDataSource].
@ProviderFor(calendarFirestoreDataSource)
final calendarFirestoreDataSourceProvider =
    Provider<CalendarFirestoreDataSource>.internal(
  calendarFirestoreDataSource,
  name: r'calendarFirestoreDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarFirestoreDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CalendarFirestoreDataSourceRef
    = ProviderRef<CalendarFirestoreDataSource>;
String _$calendarRepositoryHash() =>
    r'66e8e0e7bd8a29927a8b946976d85e81b1e8ee45';

/// See also [calendarRepository].
@ProviderFor(calendarRepository)
final calendarRepositoryProvider = Provider<CalendarRepository>.internal(
  calendarRepository,
  name: r'calendarRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CalendarRepositoryRef = ProviderRef<CalendarRepository>;
String _$calendarViewModelHash() => r'08171d0e3d3c18a9e278e256b57b4a51659033a2';

/// 訂閱當前 (symbol, year, month) 的 CalendarDoc。
/// symbol == null → 直接 emit null（empty state），不訂閱 repository。
/// symbol 或 month 變動 → riverpod 自動 invalidate + 重新 subscribe。
///
/// Copied from [calendarViewModel].
@ProviderFor(calendarViewModel)
final calendarViewModelProvider =
    AutoDisposeStreamProvider<CalendarDoc?>.internal(
  calendarViewModel,
  name: r'calendarViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CalendarViewModelRef = AutoDisposeStreamProviderRef<CalendarDoc?>;
String _$currentSymbolHash() => r'b4a6f906e0a3b39a560c16ee0c78b027b73c14e9';

/// 當前選中的股票 symbol。Step 14 chips 切換會 update 這個 provider。
/// 本 step 還沒接 stock 管理 UI，初始為 null → CalendarScreen 顯示 empty state。
///
/// Copied from [CurrentSymbol].
@ProviderFor(CurrentSymbol)
final currentSymbolProvider = NotifierProvider<CurrentSymbol, String?>.internal(
  CurrentSymbol.new,
  name: r'currentSymbolProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentSymbolHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentSymbol = Notifier<String?>;
String _$focusedMonthHash() => r'c7040362cdee2b6e2dc083d5f1f0d3361f24b080';

/// 當前 focused month（取月初 UTC，day=1, time=0）。
/// table_calendar 的 onPageChanged 會 update 這個 provider。
///
/// Copied from [FocusedMonth].
@ProviderFor(FocusedMonth)
final focusedMonthProvider = NotifierProvider<FocusedMonth, DateTime>.internal(
  FocusedMonth.new,
  name: r'focusedMonthProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$focusedMonthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FocusedMonth = Notifier<DateTime>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
