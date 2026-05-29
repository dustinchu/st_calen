import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // U1：暫時固定深色 OLED 基底，先讓新風貌可截圖驗收。
    // 既有 5 套主題 byId 接線（含淺色）留 U3 接回。
    final darkTheme = AppTheme.dark();
    return MaterialApp.router(
      title: '股市行事曆',
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
