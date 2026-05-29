import 'package:hive/hive.dart';

import 'hive_boxes.dart';

/// 重設本地資料（清 Hive）。
///
/// 清空使用者資料 box（calendars / stocks）與 settings（回預設值），並移除 meta
/// 內的待同步佇列；**保留** onboarding 完成 flag（避免重設後被丟回 onboarding）。
/// 不觸碰 auth（保留匿名 UID）。quotes box 目前未實作快取，故不在範圍內。
Future<void> resetLocalData({
  required Box<dynamic> calendars,
  required Box<dynamic> stocks,
  required Box<dynamic> settings,
  required Box<dynamic> meta,
}) async {
  await calendars.clear();
  await stocks.clear();
  await settings.clear();
  await meta.delete(kPendingCalendarWritesKey);
  await meta.delete(kPendingCalendarDeletesKey);
  // kOnboardingCompletedKey 刻意保留。
}
