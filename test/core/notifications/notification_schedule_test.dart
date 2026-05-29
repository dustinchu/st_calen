import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/core/notifications/notification_schedule.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  late tz.Location taipei;

  setUpAll(() {
    tzdata.initializeTimeZones();
    taipei = tz.getLocation('Asia/Taipei');
  });

  tz.TZDateTime at(int y, int m, int d, int hh, int mm) =>
      tz.TZDateTime(taipei, y, m, d, hh, mm);

  group('nextInstanceOfTime', () {
    test('今天尚未到 14:30 → 回今天 14:30', () {
      // 2026-05-29 是週五，10:00
      final now = at(2026, 5, 29, 10, 0);
      final next = nextInstanceOfTime(now, hour: 14, minute: 30);
      expect(next, at(2026, 5, 29, 14, 30));
    });

    test('今天已過 14:30 → 回明天 14:30', () {
      final now = at(2026, 5, 29, 15, 0);
      final next = nextInstanceOfTime(now, hour: 14, minute: 30);
      expect(next, at(2026, 5, 30, 14, 30));
    });

    test('剛好 14:30:00 → 視為已過，回明天（zonedSchedule 需未來時間）', () {
      final now = at(2026, 5, 29, 14, 30);
      final next = nextInstanceOfTime(now, hour: 14, minute: 30);
      expect(next, at(2026, 5, 30, 14, 30));
    });
  });

  group('nextInstanceOfWeekdayTime', () {
    test('週三 10:00、目標週五 → 本週五 14:30', () {
      // 2026-05-27 週三
      final now = at(2026, 5, 27, 10, 0);
      final next = nextInstanceOfWeekdayTime(
        now,
        weekday: DateTime.friday,
        hour: 14,
        minute: 30,
      );
      expect(next, at(2026, 5, 29, 14, 30));
      expect(next.weekday, DateTime.friday);
    });

    test('週五 15:00、目標週五（今日時間已過）→ 下週五 14:30', () {
      final now = at(2026, 5, 29, 15, 0);
      final next = nextInstanceOfWeekdayTime(
        now,
        weekday: DateTime.friday,
        hour: 14,
        minute: 30,
      );
      expect(next, at(2026, 6, 5, 14, 30));
      expect(next.weekday, DateTime.friday);
    });

    test('週六、目標週一（跨週）→ 下週一 14:30', () {
      // 2026-05-30 週六
      final now = at(2026, 5, 30, 9, 0);
      final next = nextInstanceOfWeekdayTime(
        now,
        weekday: DateTime.monday,
        hour: 14,
        minute: 30,
      );
      expect(next, at(2026, 6, 1, 14, 30));
      expect(next.weekday, DateTime.monday);
    });
  });
}
