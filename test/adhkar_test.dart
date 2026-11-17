import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_app/core/content/adhkar.dart';
import 'package:muslim_app/core/content/dhikr.dart';
import 'package:muslim_app/core/content/ramadan.dart';

void main() {
  test('every entry is complete and has its own counter', () {
    final all = [...dhikrList, ...morningAdhkar, ...eveningAdhkar, iftarDua];
    expect(all.map((d) => d.id).toSet().length, all.length);
    for (final d in [...morningAdhkar, ...eveningAdhkar, iftarDua]) {
      for (final text in [
        d.arabic,
        d.latin,
        d.cyrillic,
        d.english,
        d.russian,
        d.source,
        d.noteEn,
        d.noteRu,
      ]) {
        expect(text.trim(), isNotEmpty, reason: d.id);
      }
      expect(d.goal, greaterThan(0));
      // Cyrillic only in the Russian fields, none in the English ones.
      expect(RegExp('[а-яА-Я]').hasMatch(d.english + d.latin), isFalse,
          reason: d.id);
      expect(RegExp('[а-яА-Я]').hasMatch(d.russian), isTrue, reason: d.id);
    }
  });

  test('morning and evening wordings differ where the hadith differs', () {
    final morning = morningAdhkar.firstWhere((d) => d.id == 'm_bika');
    final evening = eveningAdhkar.firstWhere((d) => d.id == 'e_bika');
    expect(morning.arabic, contains('النُّشُورُ'));
    expect(evening.arabic, contains('الْمَصِيرُ'));
    expect(
      morningAdhkar.firstWhere((d) => d.id == 'm_subhan').source,
      'Muslim 2692',
    );
  });
}
