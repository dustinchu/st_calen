// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accuracy_report_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$accuracyReportHash() => r'ac4a985f0bd995dc0ebba7115658a4acf8f2c71a';

/// 準度報告：讀本地所有 [CalendarDoc]，依選中 Tab 即時聚合成 [AccuracyReport]。
///
/// 資料源用 [calendarLocalDataSourceProvider].getAll()（本地聚合全部股票/月份），
/// 不經 repository（repo 只有 per-(symbol,year,month) 介面）。每次即時算，
/// Phase 1 資料量小、先不做 report cache。
///
/// Copied from [accuracyReport].
@ProviderFor(accuracyReport)
final accuracyReportProvider =
    AutoDisposeFutureProvider<AccuracyReport>.internal(
  accuracyReport,
  name: r'accuracyReportProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$accuracyReportHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AccuracyReportRef = AutoDisposeFutureProviderRef<AccuracyReport>;
String _$reportTabSelectionHash() =>
    r'26b7d80001862f5e4357c1eceeb14b849717741e';

/// 當前選中的報告 Tab（本月 / 近 3 月 / 全部）。
///
/// Copied from [ReportTabSelection].
@ProviderFor(ReportTabSelection)
final reportTabSelectionProvider =
    AutoDisposeNotifierProvider<ReportTabSelection, ReportTab>.internal(
  ReportTabSelection.new,
  name: r'reportTabSelectionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportTabSelectionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportTabSelection = AutoDisposeNotifier<ReportTab>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
