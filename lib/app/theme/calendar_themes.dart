import 'package:flutter/material.dart';

import 'brutalist_decor.dart';
import 'semantic_colors.dart';

/// 月曆主題：定義 App 主色 / 明暗 / 月曆與分享卡的染色，並攜帶三軸語意色與
/// neo-brutalist 裝飾。畫面 ThemeData 由 `AppTheme.fromCalendarTheme` 組出。
///
/// hit/miss/unsettled 為**分享版型** cell 底色（U8 會改讀 [semantic]）；
/// 螢幕月曆的命中狀態已於 U2 改為徽章，cell 底不再編碼命中。
@immutable
class CalendarTheme {
  const CalendarTheme({
    required this.id,
    required this.displayName,
    required this.brightness,
    required this.seed,
    required this.monthBackground,
    required this.hitCellBg,
    required this.missCellBg,
    required this.unsettledCellBg,
    this.semantic = SemanticColors.dark,
    this.brutalist = BrutalistDecor.none,
    this.useOledScheme = false,
  });

  final String id;
  final String displayName;

  /// App 明暗：fromSeed 衍生用；dark 另走 OLED override（[useOledScheme]）。
  final Brightness brightness;
  final Color seed;
  final Color monthBackground;
  final Color hitCellBg;
  final Color missCellBg;
  final Color unsettledCellBg;

  /// 三軸語意色（§2）。5 套共用 §2 canonical（[SemanticColors.dark]）——
  /// 語意恆定是「能不能被讀懂」的核心，主題只變 surface/seed，不變語意。
  final SemanticColors semantic;

  /// neo-brutalist 裝飾（meme 啟用，其餘 [BrutalistDecor.none]）。
  final BrutalistDecor brutalist;

  /// dark 專用：用 app_theme 手填的 OLED ColorScheme（fromSeed 衍生不夠黑）。
  final bool useOledScheme;
}

/// 5 套內建主題 + id 解析。
class CalendarThemes {
  const CalendarThemes._();

  /// 暗夜（新預設）：OLED 黑底 + 藍主色（Stitch _1/_5、DESIGN.md）。
  static const CalendarTheme dark = CalendarTheme(
    id: 'dark',
    displayName: '暗夜',
    brightness: Brightness.dark,
    seed: Color(0xFF4D8EFF),
    monthBackground: Color(0xFF051424),
    hitCellBg: Color(0xFF3D3000),
    missCellBg: Color(0xFF222A33),
    unsettledCellBg: Color(0xFF1C2B3C),
    useOledScheme: true,
  );

  /// 晴天：淺色乾淨現代（保留給偏好淺色者）。
  static const CalendarTheme light = CalendarTheme(
    id: 'light',
    displayName: '晴天',
    brightness: Brightness.light,
    seed: Color(0xFF1E88E5),
    monthBackground: Color(0xFFFFFFFF),
    hitCellBg: Color(0xFFFFF0C2),
    missCellBg: Color(0xFFE8EAED),
    unsettledCellBg: Color(0xFFF1F3F4),
  );

  /// 紅綠：財經紅漲綠跌強對比（Stitch _6）。
  static const CalendarTheme redgreen = CalendarTheme(
    id: 'redgreen',
    displayName: '紅綠',
    brightness: Brightness.dark,
    seed: Color(0xFFFF3B30),
    monthBackground: Color(0xFF0B0E11),
    hitCellBg: Color(0xFF3D3000),
    missCellBg: Color(0xFF22262B),
    unsettledCellBg: Color(0xFF16191D),
  );

  /// 極簡：黑白線條、留白、近無彩（Stitch _7）。
  static const CalendarTheme minimal = CalendarTheme(
    id: 'minimal',
    displayName: '極簡',
    brightness: Brightness.light,
    seed: Color(0xFF424242),
    monthBackground: Color(0xFFFFFFFF),
    hitCellBg: Color(0xFFF5F5F5),
    missCellBg: Color(0xFFEEEEEE),
    unsettledCellBg: Color(0xFFFAFAFA),
  );

  /// 迷因：高對比 + 2px 實邊 + 硬陰影 + emoji（Stitch _8）。
  static const CalendarTheme meme = CalendarTheme(
    id: 'meme',
    displayName: '迷因',
    brightness: Brightness.light,
    seed: Color(0xFFFFB300),
    monthBackground: Color(0xFFFFFDE7),
    hitCellBg: Color(0xFFFFD600),
    missCellBg: Color(0xFFE0E0E0),
    unsettledCellBg: Color(0xFFFFFFFF),
    brutalist: BrutalistDecor.meme,
  );

  static const List<CalendarTheme> all = [
    dark,
    light,
    redgreen,
    minimal,
    meme,
  ];

  /// 舊 id → 新 id 映射（U3 決策）：legacy 淺色一律收進新預設 dark；
  /// mono 風格最近 minimal。不破壞 Hive 既有 themeId（靠 [resolveId] 吸收）。
  static const Map<String, String> _legacyIds = {
    'def': 'dark',
    'default': 'dark',
    'warm': 'dark',
    'cool': 'dark',
    'nature': 'dark',
    'mono': 'minimal',
  };

  /// 純函式：任意 id（含 legacy / unknown）→ 內建 id。
  /// 命中 [all] → 自身；命中 legacy → 映射；其餘 → `dark`（新預設）。
  static String resolveId(String id) {
    for (final t in all) {
      if (t.id == id) return id;
    }
    return _legacyIds[id] ?? dark.id;
  }

  /// 解析任意 id 為內建主題（永不報錯，未知 → dark）。
  static CalendarTheme byId(String id) {
    final resolved = resolveId(id);
    return all.firstWhere((t) => t.id == resolved);
  }
}
