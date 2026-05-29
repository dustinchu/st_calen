import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/features/share_image/model/share_template.dart';

void main() {
  group('ShareTemplate', () {
    test('values 順序 = fullCalendar / singleDay / reportCard', () {
      expect(ShareTemplate.values, [
        ShareTemplate.fullCalendar,
        ShareTemplate.singleDay,
        ShareTemplate.reportCard,
      ]);
    });

    test('每個 template 的 displayName 不為空', () {
      for (final t in ShareTemplate.values) {
        expect(t.displayName, isNotEmpty);
      }
    });
  });
}
