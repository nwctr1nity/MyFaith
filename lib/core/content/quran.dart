class SurahInfo {
  const SurahInfo({
    required this.number,
    required this.name,
    required this.englishMeaning,
    required this.russianName,
    required this.arabicName,
    required this.ayahCount,
    required this.makkan,
  });

  final int number;

  /// Latin transliteration, for example `Al-Baqara`.
  final String name;
  final String englishMeaning;
  final String russianName;
  final String arabicName;
  final int ayahCount;
  final bool makkan;

  /// Name in the interface language.
  String localizedName(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return russianName;
      case 'ar':
        return arabicName;
      default:
        return name;
    }
  }

  /// Every surah except At-Tawba opens with the basmala; in Al-Fatiha it is
  /// the first ayah itself, so it is not repeated as a header there.
  bool get showsBasmalaHeader => number != 1 && number != 9;

  static SurahInfo? fromJson(Object? json) {
    if (json is! Map) return null;
    final n = json['n'];
    final ayahs = json['ayahs'];
    if (n is! int || ayahs is! int) return null;
    return SurahInfo(
      number: n,
      name: json['name'] as String? ?? '',
      englishMeaning: json['en'] as String? ?? '',
      russianName: json['ru'] as String? ?? '',
      arabicName: json['ar'] as String? ?? '',
      ayahCount: ayahs,
      makkan: json['makkan'] == true,
    );
  }
}

/// The text of one surah: Arabic plus the bundled translations.
class SurahText {
  const SurahText({
    required this.arabic,
    required this.russian,
    required this.english,
  });

  final List<String> arabic;
  final List<String> russian;
  final List<String> english;

  /// Translation in the interface language, or null for Arabic.
  List<String>? translation(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return russian;
      case 'ar':
        return null;
      default:
        return english;
    }
  }

  static SurahText fromJson(Map<String, Object?> json) {
    List<String> list(String key) =>
        [for (final v in (json[key] as List? ?? const [])) v as String];
    return SurahText(
      arabic: list('ar'),
      russian: list('ru'),
      english: list('en'),
    );
  }
}

const basmala = 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ';

String surahAsset(int number) =>
    'assets/quran/s/${number.toString().padLeft(3, '0')}.json';

/// Tafsir language for an interface language.
String tafsirLanguage(String languageCode) =>
    const ['ru', 'ar'].contains(languageCode) ? languageCode : 'en';

String tafsirAsset(String languageCode, int surah) =>
    'assets/tafsir/${tafsirLanguage(languageCode)}/'
    '${surah.toString().padLeft(3, '0')}.json';
