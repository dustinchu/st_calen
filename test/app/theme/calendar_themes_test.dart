import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/app/theme/calendar_themes.dart';

void main() {
  group('CalendarThemes.resolveId（純函式 id 映射）', () {
    test('5 套內建 id 解析為自身', () {
      for (final id in ['dark', 'light', 'redgreen', 'minimal', 'meme']) {
        expect(CalendarThemes.resolveId(id), id);
      }
    });

    test('legacy 淺色 id（def/default/warm/cool/nature）→ dark（新預設）', () {
      for (final id in ['def', 'default', 'warm', 'cool', 'nature']) {
        expect(CalendarThemes.resolveId(id), 'dark');
      }
    });

    test('legacy mono → minimal（風格最近）', () {
      expect(CalendarThemes.resolveId('mono'), 'minimal');
    });

    test('未知 / 空字串 → dark', () {
      expect(CalendarThemes.resolveId('nope'), 'dark');
      expect(CalendarThemes.resolveId(''), 'dark');
    });
  });

  group('CalendarThemes.byId', () {
    test('回傳 resolveId 對應的內建主題', () {
      expect(CalendarThemes.byId('mono').id, 'minimal');
      expect(CalendarThemes.byId('def').id, 'dark');
      expect(CalendarThemes.byId('redgreen').id, 'redgreen');
      expect(CalendarThemes.byId('nope').id, 'dark');
    });

    test('all 恰好 5 套，順序 dark/light/redgreen/minimal/meme', () {
      expect(CalendarThemes.all.length, 5);
      expect(
        CalendarThemes.all.map((t) => t.id).toList(),
        ['dark', 'light', 'redgreen', 'minimal', 'meme'],
      );
    });
  });

  group('每主題 SemanticColors（§2 三軸分離健全性）', () {
    test('軸二命中金 不撞 軸一任一方向色，且 hit ≠ miss', () {
      for (final t in CalendarThemes.all) {
        final s = t.semantic;
        for (final dir in [s.up, s.down, s.flat, s.neutral]) {
          expect(s.hit, isNot(dir), reason: '${t.id}: hit 不得撞軸一方向色');
        }
        expect(s.hit, isNot(s.miss), reason: '${t.id}: hit 不得等於 miss');
      }
    });
  });

  group('BrutalistDecor（每主題裝飾）', () {
    test('僅 meme 帶 neo-brutalist 實邊 + 硬陰影，其餘為 none', () {
      for (final t in CalendarThemes.all) {
        if (t.id == 'meme') {
          expect(t.brutalist.borderWidth, greaterThan(0));
          expect(t.brutalist.hardShadow, isTrue);
        } else {
          expect(t.brutalist.borderWidth, 0);
          expect(t.brutalist.hardShadow, isFalse);
        }
      }
    });
  });
}
