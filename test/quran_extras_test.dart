import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_app/core/content/dhikr.dart';
import 'package:muslim_app/core/content/names.dart';
import 'package:muslim_app/core/content/quran.dart';

SurahText _surah(int n) => SurahText.fromJson(
  jsonDecode(
    File('assets/quran/s/${n.toString().padLeft(3, '0')}.json')
        .readAsStringSync(),
  ) as Map<String, Object?>,
);

void main() {
  late List<SurahInfo> surahs;
  late MushafLayout layout;

  setUpAll(() {
    surahs = [
      for (final item in jsonDecode(
        File('assets/quran/surahs.json').readAsStringSync(),
      ) as List)
        ?SurahInfo.fromJson(item),
    ];
    layout = MushafLayout.fromJson(
      jsonDecode(File('assets/quran/layout.json').readAsStringSync())
          as Map<String, Object?>,
      [for (final s in surahs) s.ayahCount],
    );
  });

  test('every bundled file the Quran needs is declared as an asset', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final path in [
      'assets/quran/surahs.json',
      'assets/quran/layout.json',
      'assets/quran/s/',
    ]) {
      expect(pubspec, contains('- $path'), reason: path);
    }
  });

  test('a surah is found by the meaning of its name, with or without ё', () {
    final bees = surahs[15];
    expect(bees.titleWithMeaning('ru'), 'Ан-Нахль (Пчёлы)');
    expect(bees.titleWithMeaning('en'), contains('('));
    expect(bees.titleWithMeaning('ar'), bees.arabicName);
    for (final q in ['Пчёлы', 'пчелы', 'ПЧЕЛ', 'нахль', '16', 'bee']) {
      expect(bees.matches(q), isTrue, reason: q);
    }
    expect(bees.matches('корова'), isFalse);
    expect(surahs.where((s) => s.matches('пчелы')).length, 1);
  });

  test('a name that is its own meaning is not repeated in brackets', () {
    expect(surahs[9].titleWithMeaning('ru'), 'Юнус');
    expect(surahs.every((s) => s.russianMeaning.isNotEmpty), isTrue);
  });

  test('the mushaf has 604 pages and 30 juz covering every ayah once', () {
    expect(layout.pageCount, 604);
    expect(layout.juzCount, 30);
    var total = 0;
    for (var p = 1; p <= layout.pageCount; p++) {
      final verses = layout.versesOn(p);
      expect(verses, isNotEmpty, reason: 'page $p');
      expect(layout.pageOf(verses.first), p);
      expect(layout.pageOf(verses.last), p);
      total += verses.length;
    }
    expect(total, 6236);
    expect(layout.pageOf((1, 1)), 1);
    expect(layout.pageOf((2, 255)), 42);
    expect(layout.pageOf((114, 6)), 604);
    expect(layout.juzOf((2, 142)), 2);
    expect(layout.juzOf((78, 1)), 30);
    expect(layout.pageOfJuz(30), 582);
    expect(layout.next((1, 7)), (2, 1));
    expect(layout.next((114, 6)), isNull);
  });

  test('every ayah has a transliteration and valid tajweed spans', () {
    for (var n = 1; n <= 114; n++) {
      final text = _surah(n);
      final count = surahs[n - 1].ayahCount;
      expect(text.latin.length, count, reason: 'surah $n');
      expect(text.cyrillic.length, count, reason: 'surah $n');
      expect(text.tajweed.length, count, reason: 'surah $n');
      for (var a = 1; a <= count; a++) {
        expect(text.latin[a - 1].trim(), isNotEmpty);
        expect(
          RegExp('[a-zA-Z]').hasMatch(text.cyrillic[a - 1]),
          isFalse,
          reason: '$n:$a ${text.cyrillic[a - 1]}',
        );
        var at = 0;
        for (final s in text.tajweedOf(a)) {
          expect(s.start, greaterThanOrEqualTo(at), reason: '$n:$a');
          expect(s.end, lessThanOrEqualTo(text.arabic[a - 1].length));
          at = s.end;
        }
      }
    }
  });

  test('tajweed marks the well-known places', () {
    String kindAt(SurahText t, int ayah, String piece, TajweedKind kind) {
      final arabic = t.arabic[ayah - 1];
      return [
        for (final s in t.tajweedOf(ayah))
          if (s.kind == kind) arabic.substring(s.start, s.end),
      ].where((x) => x.contains(piece)).join();
    }

    final fatiha = _surah(1);
    // The madd of "ad-daalleen" is the textbook six-count lengthening.
    expect(
      kindAt(fatiha, 7, '\u0627\u0653', TajweedKind.maddLazim),
      isNotEmpty,
    );
    final ikhlas = _surah(112);
    // "lam yakun lahu": the noon is merged into the lam.
    expect(kindAt(ikhlas, 4, 'ن', TajweedKind.silent), isNotEmpty);
    final baqara = _surah(2);
    // "min tahtiha" hides the noon; "abwab" style qalqalah on a still ba.
    expect(kindAt(baqara, 25, 'ن', TajweedKind.ghunnah), isNotEmpty);
    expect(kindAt(baqara, 20, 'ب', TajweedKind.qalqalah), isNotEmpty);
    expect(
      kindAt(baqara, 20, '\u0627\u0653', TajweedKind.maddMuttasil),
      isNotEmpty,
    );
    expect(
      kindAt(baqara, 20, '\u0627\u0653', TajweedKind.maddMunfasil),
      isNotEmpty,
    );
  });

  test('search finds a word in the translation and in the Arabic', () {
    final corpus = [for (var n = 1; n <= 114; n++) _surah(n)];
    final bees = searchQuran(corpus, 'пчеле', 'ru');
    expect(bees.map((h) => h.verse), contains((16, 68)));
    final hit = bees.firstWhere((h) => h.verse == (16, 68));
    expect(
      hit.text.substring(hit.start, hit.start + hit.length).toLowerCase(),
      'пчеле',
    );
    // ё and е are the same letter for the search.
    expect(searchQuran(corpus, 'пчёле', 'ru').length, bees.length);
    expect(
      searchQuran(corpus, 'bee', 'en').map((h) => h.verse),
      contains((16, 68)),
    );
    // Arabic typed without vowel marks.
    expect(
      searchQuran(corpus, 'النحل', 'ru').map((h) => h.verse),
      contains((16, 68)),
    );
    expect(searchQuran(corpus, 'я', 'ru'), isEmpty);
    expect(searchQuran(corpus, 'аллах', 'ru', limit: 50).length, 50);
  });

  test('there are 99 names and every quiz question has one right answer', () {
    expect(divineNames.length, 99);
    expect({for (final n in divineNames) n.arabic}.length, 99);
    final random = Random(7);
    for (final language in ['ru', 'en']) {
      for (var i = 0; i < 99; i++) {
        final q = nameQuestion(i, random.nextInt, language);
        expect(q.options.length, 3);
        expect(q.options.where((o) => o == q.name).length, 1);
        expect({for (final o in q.options) o.meaning(language)}.length, 3);
      }
    }
  });

  test(
    'dhikr starts with the three basic ones and every entry is complete',
    () {
      expect(dhikrList.take(3).map((d) => d.id), [
        'subhanallah',
        'alhamdulillah',
        'allahuakbar',
      ]);
      expect({for (final d in dhikrList) d.id}.length, dhikrList.length);
      for (final d in dhikrList) {
        expect(d.goal, greaterThan(0), reason: d.id);
        expect(d.source, isNotEmpty, reason: d.id);
        expect(d.noteRu, isNotEmpty, reason: d.id);
        expect(d.noteEn, isNotEmpty, reason: d.id);
        expect(RegExp('[a-zA-Z]').hasMatch(d.cyrillic), isFalse, reason: d.id);
      }
      expect(dhikrList.where((d) => d.dua), isNotEmpty);
    },
  );
}
