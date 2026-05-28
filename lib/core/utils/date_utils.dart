import 'package:intl/intl.dart';

/// 將時間正規化到當日 00:00（local time）。
DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// 兩個 DateTime 是否落在同一日（忽略時分秒與 timezone）。
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// 2026-05-28
String formatYmd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

/// 2026-05
String formatMonth(DateTime d) => DateFormat('yyyy-MM').format(d);
