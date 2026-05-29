import 'package:timezone/timezone.dart' as tz;

/// 純函式：給定 [now]，回傳「下一次」落在 [hour]:[minute] 的時刻（同時區）。
/// 今天該時刻仍在未來 → 回今天；已過或剛好相等 → 回明天（zonedSchedule 需未來時間）。
tz.TZDateTime nextInstanceOfTime(
  tz.TZDateTime now, {
  required int hour,
  required int minute,
}) {
  var scheduled =
      tz.TZDateTime(now.location, now.year, now.month, now.day, hour, minute);
  if (!scheduled.isAfter(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

/// 純函式：下一次落在指定 [weekday]（DateTime.monday=1 … sunday=7）的
/// [hour]:[minute] 時刻。以 [nextInstanceOfTime] 為起點，逐日推進到目標星期。
tz.TZDateTime nextInstanceOfWeekdayTime(
  tz.TZDateTime now, {
  required int weekday,
  required int hour,
  required int minute,
}) {
  var scheduled = nextInstanceOfTime(now, hour: hour, minute: minute);
  while (scheduled.weekday != weekday) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}
