import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/calendar_themes.dart';
import '../../../data/models/calendar_doc.dart';
import '../../settings/viewmodel/settings_view_model.dart';
import '../../share_image/view/share_preview_screen.dart';
import '../../stock/view/stock_chips_bar.dart';
import '../viewmodel/calendar_view_model.dart';
import 'widgets/calendar_month_view.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currentSymbolProvider);
    final docAsync = ref.watch(calendarViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(symbol ?? '股市行事曆'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            tooltip: '準度報告',
            onPressed: () => context.push('/report'),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: '分享月曆',
            onPressed: symbol == null
                ? null
                : () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => SharePreviewScreen(symbol: symbol),
                    )),
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: '月曆主題',
            onPressed: docAsync.valueOrNull == null
                ? null
                : () => _pickCalendarTheme(context, ref, docAsync.value!),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: StockChipsBar(),
        ),
      ),
      body: symbol == null
          ? const _EmptyState()
          : docAsync.when(
              data: (doc) => CalendarMonthView(doc: doc),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('讀取失敗：$e')),
            ),
    );
  }

  Future<void> _pickCalendarTheme(
      BuildContext context, WidgetRef ref, CalendarDoc doc) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => _CalendarThemePickerSheet(currentId: doc.themeId),
    );
    if (picked == null) return;
    final repo = ref.read(calendarRepositoryProvider);
    await repo.put(doc.copyWith(
      themeId: picked,
      updatedAt: DateTime.now().toUtc(),
    ));
  }
}

class _CalendarThemePickerSheet extends ConsumerWidget {
  const _CalendarThemePickerSheet({required this.currentId});

  final String currentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeId =
        ref.watch(settingsViewModelProvider).valueOrNull?.themeId ?? 'default';
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('此月曆主題',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "選『預設』會跟隨 App 主題（目前：${CalendarThemes.byId(appThemeId).displayName}）",
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).hintColor),
            ),
          ),
          const SizedBox(height: 8),
          for (final t in CalendarThemes.all)
            ListTile(
              leading: CircleAvatar(backgroundColor: t.seed, radius: 12),
              title: Text(t.displayName),
              trailing: t.id == currentId
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () => Navigator.of(context).pop(t.id),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '請新增股票',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              '尚未加入任何自選股，加入後即可在此規劃預測。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
