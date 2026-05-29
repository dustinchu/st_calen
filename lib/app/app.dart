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
    final settings = ref.watch(settingsViewModelProvider).valueOrNull;
    final theme = CalendarThemes.byId(settings?.themeId ?? 'default');
    return MaterialApp.router(
      title: '股市行事曆',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.fromSeed(theme.seed, Brightness.light),
      darkTheme: AppTheme.fromSeed(theme.seed, Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
