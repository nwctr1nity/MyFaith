import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/content/hadith.dart';
import '../core/content/quran.dart';

final surahIndexProvider = FutureProvider<List<SurahInfo>>((ref) async {
  final raw = await rootBundle.loadString('assets/quran/surahs.json');
  return [
    for (final item in jsonDecode(raw) as List) ?SurahInfo.fromJson(item),
  ];
});

final surahTextProvider = FutureProvider.family<SurahText, int>((
  ref,
  number,
) async {
  final raw = await rootBundle.loadString(surahAsset(number));
  return SurahText.fromJson(jsonDecode(raw) as Map<String, Object?>);
});

final mushafLayoutProvider = FutureProvider<MushafLayout>((ref) async {
  final surahs = await ref.watch(surahIndexProvider.future);
  final raw = await rootBundle.loadString('assets/quran/layout.json');
  return MushafLayout.fromJson(jsonDecode(raw) as Map<String, Object?>, [
    for (final s in surahs) s.ayahCount,
  ]);
});

/// Tafsir of one surah, one entry per ayah. Keyed by (language, surah).
final tafsirProvider = FutureProvider.family<List<String>, (String, int)>((
  ref,
  key,
) async {
  final raw = await rootBundle.loadString(tafsirAsset(key.$1, key.$2));
  return [for (final v in jsonDecode(raw) as List) v as String];
});

final hadithPoolProvider = FutureProvider<List<Hadith>>((ref) async {
  final raw = await rootBundle.loadString('assets/hadith/daily.json');
  return [for (final item in jsonDecode(raw) as List) ?Hadith.fromJson(item)];
});

/// Every surah's text, for searching. Loaded on the first search.
final quranCorpusProvider = FutureProvider<List<SurahText>>((ref) async {
  final surahs = await ref.watch(surahIndexProvider.future);
  return [
    for (final s in surahs) await ref.watch(surahTextProvider(s.number).future),
  ];
});
