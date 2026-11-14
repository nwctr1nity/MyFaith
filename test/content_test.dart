import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_app/core/content/hadith.dart';
import 'package:muslim_app/core/content/quran.dart';
import 'package:muslim_app/core/content/salawat.dart';

Object? _json(String path) => jsonDecode(File(path).readAsStringSync());

void main() {
  late List<SurahInfo> surahs;

  setUpAll(() {
    surahs = [
      for (final item in _json('assets/quran/surahs.json') as List)
        SurahInfo.fromJson(item)!,
    ];
  });

  test('the index lists 114 surahs with 6236 ayahs', () {
    expect(surahs, hasLength(114));
    expect(surahs.first.name, isNotEmpty);
    expect(surahs.fold<int>(0, (sum, s) => sum + s.ayahCount), 6236);
    for (var i = 0; i < surahs.length; i++) {
      expect(surahs[i].number, i + 1);
      expect(surahs[i].russianName, isNotEmpty);
      expect(surahs[i].arabicName, isNotEmpty);
    }
  });

  test('every surah has Arabic, Russian and English for every ayah', () {
    for (final s in surahs) {
      final text = SurahText.fromJson(
        _json(surahAsset(s.number)) as Map<String, Object?>,
      );
      for (final list in [text.arabic, text.russian, text.english]) {
        expect(list, hasLength(s.ayahCount), reason: 'surah ${s.number}');
        expect(list.every((a) => a.trim().isNotEmpty), isTrue,
            reason: 'surah ${s.number}');
      }
    }
  });

  test('every ayah has a tafsir entry in all three languages', () {
    for (final language in ['ru', 'en', 'ar']) {
      for (final s in surahs) {
        final entries = _json(tafsirAsset(language, s.number)) as List;
        expect(entries, hasLength(s.ayahCount),
            reason: '$language surah ${s.number}');
        expect(entries.every((e) => (e as String).trim().isNotEmpty), isTrue,
            reason: '$language surah ${s.number}');
      }
    }
  });

  test('Al-Fatiha opens with the basmala and has no extra header', () {
    final fatiha = SurahText.fromJson(
      _json(surahAsset(1)) as Map<String, Object?>,
    );
    expect(fatiha.arabic.first, basmala);
    expect(surahs[0].showsBasmalaHeader, isFalse);
    expect(surahs[8].showsBasmalaHeader, isFalse);
    expect(surahs[1].showsBasmalaHeader, isTrue);
  });

  test('the hadith pool is complete in all three languages', () {
    final pool = [
      for (final item in _json('assets/hadith/daily.json') as List)
        Hadith.fromJson(item)!,
    ];
    expect(pool.length, greaterThan(2000));
    expect({for (final h in pool) h.number}, hasLength(pool.length));
    for (final h in pool) {
      expect(h.number, inInclusiveRange(1, 7563));
      expect(h.arabic.trim(), isNotEmpty);
      expect(h.english.trim(), isNotEmpty);
      expect(h.russian.trim(), isNotEmpty);
    }
  });

  test('salawat have text and translations', () {
    expect(salawatList, isNotEmpty);
    for (final s in salawatList) {
      expect(s.arabic, isNotEmpty);
      expect(s.translation('ru'), isNotEmpty);
      expect(s.translation('en'), isNotEmpty);
      expect(s.translation('ar'), isNull);
    }
  });
}
