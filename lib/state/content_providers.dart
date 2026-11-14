import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/content/hadith.dart';
import '../core/content/quran.dart';

final surahIndexProvider = FutureProvider<List<SurahInfo>>((ref) async {
  final raw = await rootBundle.loadString('assets/quran/surahs.json');
  return [
    for (final item in jsonDecode(raw) as List)
      ?SurahInfo.fromJson(item),
  ];
});

final surahTextProvider =
    FutureProvider.family<SurahText, int>((ref, number) async {
  final raw = await rootBundle.loadString(surahAsset(number));
  return SurahText.fromJson(jsonDecode(raw) as Map<String, Object?>);
});

/// Tafsir of one surah, one entry per ayah. Keyed by (language, surah).
final tafsirProvider = FutureProvider.family<List<String>, (String, int)>(
  (ref, key) async {
    final raw = await rootBundle.loadString(tafsirAsset(key.$1, key.$2));
    return [for (final v in jsonDecode(raw) as List) v as String];
  },
);

final hadithPoolProvider = FutureProvider<List<Hadith>>((ref) async {
  final raw = await rootBundle.loadString('assets/hadith/daily.json');
  return [
    for (final item in jsonDecode(raw) as List)
      ?Hadith.fromJson(item),
  ];
});
