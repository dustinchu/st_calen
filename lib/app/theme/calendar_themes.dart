import 'package:flutter/material.dart';

/// 月曆主題：定義 App seed 色與月曆 cell 染色。
///
/// hit/miss/unsettled 為 cell 底色（pastel），與 markerBuilder 的 icon 區分。
@immutable
class CalendarTheme {
  const CalendarTheme({
    required this.id,
    required this.displayName,
    required this.seed,
    required this.monthBackground,
    required this.hitCellBg,
    required this.missCellBg,
    required this.unsettledCellBg,
  });

  final String id;
  final String displayName;
  final Color seed;
  final Color monthBackground;
  final Color hitCellBg;
  final Color missCellBg;
  final Color unsettledCellBg;
}

/// 5 套內建主題 + byId 查表。
class CalendarThemes {
  const CalendarThemes._();

  static const CalendarTheme defaultTheme = CalendarTheme(
    id: 'default',
    displayName: '預設',
    seed: Color(0xFF1E88E5),
    monthBackground: Color(0xFFFFFFFF),
    hitCellBg: Color(0xFFC8E6C9),
    missCellBg: Color(0xFFFFCDD2),
    unsettledCellBg: Color(0xFFEEEEEE),
  );

  static const CalendarTheme warm = CalendarTheme(
    id: 'warm',
    displayName: '暖陽',
    seed: Color(0xFFFB8C00),
    monthBackground: Color(0xFFFFF8E7),
    hitCellBg: Color(0xFFFFE0B2),
    missCellBg: Color(0xFFFFAB91),
    unsettledCellBg: Color(0xFFD7CCC8),
  );

  static const CalendarTheme cool = CalendarTheme(
    id: 'cool',
    displayName: '海洋',
    seed: Color(0xFF0288D1),
    monthBackground: Color(0xFFE3F2FD),
    hitCellBg: Color(0xFFB3E5FC),
    missCellBg: Color(0xFFCE93D8),
    unsettledCellBg: Color(0xFFCFD8DC),
  );

  static const CalendarTheme mono = CalendarTheme(
    id: 'mono',
    displayName: '簡約',
    seed: Color(0xFF424242),
    monthBackground: Color(0xFFFAFAFA),
    hitCellBg: Color(0xFF9E9E9E),
    missCellBg: Color(0xFFE0E0E0),
    unsettledCellBg: Color(0xFFF5F5F5),
  );

  static const CalendarTheme nature = CalendarTheme(
    id: 'nature',
    displayName: '森林',
    seed: Color(0xFF388E3C),
    monthBackground: Color(0xFFF1F8E9),
    hitCellBg: Color(0xFFC5E1A5),
    missCellBg: Color(0xFFD7CCC8),
    unsettledCellBg: Color(0xFFE0E0E0),
  );

  static const List<CalendarTheme> all = [
    defaultTheme,
    warm,
    cool,
    mono,
    nature,
  ];

  /// 未知 id（含 legacy 'def'）回 [defaultTheme]，不報錯。
  static CalendarTheme byId(String id) {
    for (final t in all) {
      if (t.id == id) return t;
    }
    return defaultTheme;
  }
}
