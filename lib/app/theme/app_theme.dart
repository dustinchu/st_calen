import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color _defaultSeed = Color(0xFF1E88E5);

  static ThemeData light() => fromSeed(_defaultSeed, Brightness.light);

  static ThemeData dark() => fromSeed(_defaultSeed, Brightness.dark);

  static ThemeData fromSeed(Color seed, Brightness brightness) => ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: brightness,
        ),
      );
}
