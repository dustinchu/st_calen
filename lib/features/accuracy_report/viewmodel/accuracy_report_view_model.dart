import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/calendar_doc.dart';
import '../../calendar/viewmodel/calendar_view_model.dart';
import 'accuracy_report.dart';

part 'accuracy_report_view_model.g.dart';

/// 當前選中的報告 Tab（本月 / 近 3 月 / 全部）。
@riverpod
class ReportTabSelection extends _$ReportTabSelection {
  @override
  ReportTab build() => ReportTab.thisMonth;

  void set(ReportTab tab) => state = tab;
}

/// 準度報告：讀本地所有 [CalendarDoc]，依選中 Tab 即時聚合成 [AccuracyReport]。
///
/// 資料源用 [calendarLocalDataSourceProvider].getAll()（本地聚合全部股票/月份），
/// 不經 repository（repo 只有 per-(symbol,year,month) 介面）。每次即時算，
/// Phase 1 資料量小、先不做 report cache。
@riverpod
Future<AccuracyReport> accuracyReport(Ref ref) async {
  final tab = ref.watch(reportTabSelectionProvider);
  final ds = ref.watch(calendarLocalDataSourceProvider);
  final result = await ds.getAll();
  final docs = result.fold<List<CalendarDoc>>(
    (value) => value,
    (_) => const <CalendarDoc>[],
  );
  return AccuracyReport.from(docs, tab, DateTime.now());
}
