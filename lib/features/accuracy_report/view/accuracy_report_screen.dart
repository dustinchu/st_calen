import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../calendar/viewmodel/calendar_view_model.dart';
import '../../share_image/model/share_template.dart';
import '../../share_image/view/share_preview_screen.dart';
import '../viewmodel/accuracy_report.dart';
import '../viewmodel/accuracy_report_view_model.dart';

/// 準度報告頁：本月 / 近 3 月 / 全部 Tab + 統計卡 + 每月命中率折線 + 分享 CTA。
/// 跨所有股票聚合（最佳股票才有意義）。命中率口徑 settled-only。
class AccuracyReportScreen extends ConsumerWidget {
  const AccuracyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(reportTabSelectionProvider);
    final reportAsync = ref.watch(accuracyReportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('準度報告')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: SegmentedButton<ReportTab>(
                segments: [
                  for (final t in ReportTab.values)
                    ButtonSegment(value: t, label: Text(t.label)),
                ],
                selected: {tab},
                onSelectionChanged: (s) =>
                    ref.read(reportTabSelectionProvider.notifier).set(s.first),
              ),
            ),
            Expanded(
              child: reportAsync.when(
                data: (report) => _ReportBody(report: report),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('讀取失敗：$e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportBody extends ConsumerWidget {
  const _ReportBody({required this.report});

  final AccuracyReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (report.summary.total == 0) {
      return const _EmptyState();
    }

    final summary = report.summary;
    final best = report.bestStock;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(label: '總預測數', value: '${summary.total}'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(label: '命中數', value: '${summary.hit}'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: '命中率',
                value: '${summary.hitRatePercent}%',
                emphasize: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: '最佳股票',
                value: best == null ? '—' : best.symbol,
                sub: best == null
                    ? '需 ${AccuracyReport.kBestStockMinSettled} 筆結算'
                    : '${best.hitRatePercent}%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('每月命中率', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: _HitRateChart(series: report.monthlySeries),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => _shareReport(context, ref),
          icon: const Icon(Icons.ios_share),
          label: const Text('分享我的成績'),
        ),
      ],
    );
  }

  void _shareReport(BuildContext context, WidgetRef ref) {
    final symbol = ref.read(currentSymbolProvider);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SharePreviewScreen(
        symbol: symbol ?? '全部',
        initialTemplate: ShareTemplate.reportCard,
        reportDocs: report.docs,
        reportPeriodLabel: report.tab.label,
        reportSymbolLabel: '全部',
      ),
    ));
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.sub,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final String? sub;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: emphasize ? scheme.primary : scheme.onSurface,
              ),
            ),
            if (sub != null) ...[
              const SizedBox(height: 4),
              Text(
                sub!,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 每月命中率折線。X = 有預測的年月（升序），Y = 命中率 %（0–100）。
class _HitRateChart extends StatelessWidget {
  const _HitRateChart({required this.series});

  final List<MonthlyHitRate> series;

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return Center(
        child: Text(
          '尚無已結算的預測',
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final spots = [
      for (var i = 0; i < series.length; i++)
        FlSpot(i.toDouble(), series[i].hitRatePercent.toDouble()),
    ];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (series.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: scheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: scheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (_) => FlLine(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text('${value.toInt()}%',
                    style: const TextStyle(fontSize: 11)),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= series.length) {
                  return const SizedBox.shrink();
                }
                final m = series[i];
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text('${m.month}月',
                      style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touched) => [
              for (final spot in touched)
                LineTooltipItem(
                  '${series[spot.x.toInt()].month}月 ${spot.y.toInt()}%',
                  TextStyle(
                    color: scheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insights, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '尚無預測紀錄',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '在月曆加入預測並結算後，這裡會顯示你的命中率統計。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
    );
  }
}
