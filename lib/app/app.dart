import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/settings/viewmodel/settings_view_model.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/calendar_themes.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // U3：App 主題依 AppSettings.themeId 決定（byId 吸收 legacy id；
    // 預設 'def' → dark）。每套主題自帶 brightness / 語意色 / brutalist。
    final themeId = ref.watch(settingsViewModelProvider).valueOrNull?.themeId;
    final calendarTheme = CalendarThemes.byId(themeId ?? 'def');
    final themeData = AppTheme.fromCalendarTheme(calendarTheme);
    return MaterialApp.router(
      title: '股市行事曆',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      darkTheme: themeData,
      themeMode: calendarTheme.brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      routerConfig: router,
    );
  }
}
