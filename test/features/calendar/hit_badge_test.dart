import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/features/calendar/view/widgets/hit_badge.dart';
import 'package:stock_calendar/features/calendar/viewmodel/settlement_view_model.dart';

void main() {
  group('hitBadgeOf (軸二：命中徽章決策)', () {
    test('hit → HitBadge.hit（金✓）', () {
      expect(hitBadgeOf(SettleStatus.hit, isPast: true), HitBadge.hit);
      expect(hitBadgeOf(SettleStatus.hit, isPast: false), HitBadge.hit);
    });
    test('miss → HitBadge.miss（灰✗）', () {
      expect(hitBadgeOf(SettleStatus.miss, isPast: true), HitBadge.miss);
      expect(hitBadgeOf(SettleStatus.miss, isPast: false), HitBadge.miss);
    });
    test('unsettled 且過去日 → HitBadge.unsettled（淡灰空心圈）', () {
      expect(
          hitBadgeOf(SettleStatus.unsettled, isPast: true), HitBadge.unsettled);
    });
    test('unsettled 且未來日 → HitBadge.none（未來日不上色）', () {
      expect(hitBadgeOf(SettleStatus.unsettled, isPast: false), HitBadge.none);
    });
  });
}
