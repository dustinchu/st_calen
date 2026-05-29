import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/app/theme/calendar_themes.dart';

void main() {
  group('CalendarThemes.byId', () {
    test('5 built-in ids resolve to non-null themes with matching id', () {
      for (final id in ['default', 'warm', 'cool', 'mono', 'nature']) {
        final t = CalendarThemes.byId(id);
        expect(t.id, id);
      }
    });

    test('unknown id falls back to default', () {
      expect(CalendarThemes.byId('nope').id, 'default');
      expect(CalendarThemes.byId('').id, 'default');
      // legacy AppSettings default 'def' 也走 fallback
      expect(CalendarThemes.byId('def').id, 'default');
    });

    test('all contains exactly 5 themes', () {
      expect(CalendarThemes.all.length, 5);
    });
  });
}
