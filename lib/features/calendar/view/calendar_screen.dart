import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
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
