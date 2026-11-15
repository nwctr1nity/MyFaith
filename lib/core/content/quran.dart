class SurahInfo {
  const SurahInfo({
    required this.number,
    required this.name,
    required this.englishMeaning,
    required this.russianName,
    this.russianMeaning = '',
    required this.arabicName,
    required this.ayahCount,
    required this.makkan,
  });

  final int number;

  /// Latin transliteration, for example `Al-Baqara`.
  final String name;
  final String englishMeaning;
  final String russianName;

  /// What the name means in Russian, for example `Пчёлы`.
  final String russianMeaning;
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

  /// The meaning of the name in the interface language, or an empty
  /// string when there is none to show (Arabic).
  String localizedMeaning(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return russianMeaning;
      case 'ar':
        return '';
      default:
        return englishMeaning;
    }
  }

  /// The name with its meaning in brackets, for example `Ан-Нахль (Пчёлы)`.
  /// The brackets are left out when the meaning only repeats the name.
  String titleWithMeaning(String languageCode) {
    final name = localizedName(languageCode);
    final meaning = localizedMeaning(languageCode);
    if (meaning.isEmpty || foldForSearch(meaning) == foldForSearch(name)) {
      return name;
    }
    return '$name ($meaning)';
  }

  /// Whether [query] finds this surah by number, name or meaning.
  bool matches(String query) {
    final q = foldForSearch(query);
    if (q.isEmpty) return true;
    if (int.tryParse(query.trim()) == number) return true;
    return foldForSearch(name).contains(q) ||
        foldForSearch(russianName).contains(q) ||
        foldForSearch(russianMeaning).contains(q) ||
        foldForSearch(englishMeaning).contains(q) ||
        stripArabicMarks(arabicName).contains(stripArabicMarks(query.trim()));
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
      russianMeaning: json['ruM'] as String? ?? '',
      arabicName: json['ar'] as String? ?? '',
      ayahCount: ayahs,
      makkan: json['makkan'] == true,
    );
  }
}

/// Lower case, `ё` as `е`, and without spaces, hyphens and apostrophes, so
/// that `пчелы` finds `Пчёлы` and `al baqara` finds `Al-Baqara`.
String foldForSearch(String text) => text
    .toLowerCase()
    .replaceAll('ё', 'е')
    .replaceAll(RegExp(r"[\-'’`‘ ]"), '');

final _arabicMarks = RegExp(
  '[\u064B-\u065F\u0670\u06D6-\u06ED\u08D3-\u08FF\u0640\u200F]',
);

/// Arabic without vowel marks and with the alif and yeh variants unified,
/// so that a word typed on a plain keyboard finds the vocalised text.
String stripArabicMarks(String text) => text
    .replaceAll(_arabicMarks, '')
    .replaceAll(RegExp('[\u0671\u0622\u0623\u0625]'), '\u0627')
    .replaceAll('\u0649', '\u064A');

/// The kinds of tajweed colouring, in the order the data files number them.
enum TajweedKind {
  ghunnah,
  qalqalah,
  maddNatural,
  maddArid,
  maddWajib,
  maddLazim,
  tafkhim,
  silent,
}

/// A coloured stretch of an ayah, in UTF-16 offsets.
class TajweedSpan {
  const TajweedSpan(this.start, this.length, this.kind);

  final int start;
  final int length;
  final TajweedKind kind;

  int get end => start + length;
}

/// The text of one surah: Arabic plus the bundled translations.
class SurahText {
  const SurahText({
    required this.arabic,
    required this.russian,
    required this.english,
    this.latin = const [],
    this.cyrillic = const [],
    this.tajweed = const [],
  });

  final List<String> arabic;
  final List<String> russian;
  final List<String> english;

  /// Transliteration in Latin and Cyrillic letters.
  final List<String> latin;
  final List<String> cyrillic;
  final List<List<TajweedSpan>> tajweed;

  /// Transliteration for the interface language, or null for Arabic.
  List<String>? transliteration(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return cyrillic;
      case 'ar':
        return null;
      default:
        return latin;
    }
  }

  List<TajweedSpan> tajweedOf(int ayah) =>
      ayah >= 1 && ayah <= tajweed.length ? tajweed[ayah - 1] : const [];

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
    List<String> list(String key) => [
      for (final v in (json[key] as List? ?? const [])) v as String,
    ];
    final arabic = list('ar');
    final spans = <List<TajweedSpan>>[];
    final raw = json['tj'];
    if (raw is List) {
      for (var a = 0; a < raw.length && a < arabic.length; a++) {
        final flat = raw[a];
        final row = <TajweedSpan>[];
        if (flat is List) {
          for (var i = 0; i + 2 < flat.length; i += 3) {
            final start = flat[i], length = flat[i + 1], kind = flat[i + 2];
            if (start is int &&
                length is int &&
                kind is int &&
                start >= 0 &&
                length > 0 &&
                start + length <= arabic[a].length &&
                kind >= 0 &&
                kind < TajweedKind.values.length) {
              row.add(TajweedSpan(start, length, TajweedKind.values[kind]));
            }
          }
        }
        spans.add(row);
      }
    }
    return SurahText(
      arabic: arabic,
      russian: list('ru'),
      english: list('en'),
      latin: list('tl'),
      cyrillic: list('tc'),
      tajweed: spans,
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

/// A position in the Quran: surah and ayah, both from 1.
typedef Verse = (int surah, int ayah);

/// Where the 604 pages and 30 juz of the Madinah mushaf begin.
class MushafLayout {
  MushafLayout({
    required this.pageStarts,
    required this.juzStarts,
    required this.ayahCounts,
  });

  final List<Verse> pageStarts;
  final List<Verse> juzStarts;

  /// Number of ayahs in each surah.
  final List<int> ayahCounts;

  int get pageCount => pageStarts.length;
  int get juzCount => juzStarts.length;

  static int _compare(Verse a, Verse b) =>
      a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2;

  static int _find(List<Verse> starts, Verse verse) {
    var low = 0, high = starts.length - 1;
    while (low < high) {
      final mid = (low + high + 1) ~/ 2;
      if (_compare(starts[mid], verse) <= 0) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }
    return low + 1;
  }

  /// The page (from 1) that holds [verse].
  int pageOf(Verse verse) => _find(pageStarts, verse);

  /// The juz (from 1) that holds [verse].
  int juzOf(Verse verse) => _find(juzStarts, verse);

  int juzOfPage(int page) => juzOf(pageStarts[page - 1]);

  int pageOfJuz(int juz) => pageOf(juzStarts[juz - 1]);

  /// The verse after [verse], or null at the end of the Quran.
  Verse? next(Verse verse) {
    if (verse.$2 < ayahCounts[verse.$1 - 1]) return (verse.$1, verse.$2 + 1);
    if (verse.$1 < ayahCounts.length) return (verse.$1 + 1, 1);
    return null;
  }

  /// Every verse on [page], in reading order.
  List<Verse> versesOn(int page) {
    final end = page < pageCount ? pageStarts[page] : null;
    final out = <Verse>[];
    Verse? v = pageStarts[page - 1];
    while (v != null && (end == null || _compare(v, end) < 0)) {
      out.add(v);
      v = next(v);
    }
    return out;
  }

  static MushafLayout fromJson(Map<String, Object?> json, List<int> counts) {
    List<Verse> list(String key) => [
      for (final v in json[key] as List) ((v as List)[0] as int, v[1] as int),
    ];
    return MushafLayout(
      pageStarts: list('pages'),
      juzStarts: list('juz'),
      ayahCounts: counts,
    );
  }
}

/// A reciter whose ayah-by-ayah recordings are streamed from everyayah.com.
class Reciter {
  const Reciter(this.id, this.folder, this.name, this.arabicName);

  final String id;
  final String folder;
  final String name;
  final String arabicName;

  String url(Verse verse) =>
      'https://everyayah.com/data/$folder/'
      '${verse.$1.toString().padLeft(3, '0')}'
      '${verse.$2.toString().padLeft(3, '0')}.mp3';
}

const reciters = <Reciter>[
  Reciter('alafasy', 'Alafasy_128kbps', 'Mishary Alafasy', 'مشاري العفاسي'),
  Reciter(
    'husary',
    'Husary_128kbps',
    'Mahmoud Khalil Al-Husary',
    'محمود خليل الحصري',
  ),
  Reciter(
    'minshawi',
    'Minshawy_Murattal_128kbps',
    'Muhammad Siddiq Al-Minshawi',
    'محمد صديق المنشاوي',
  ),
  Reciter(
    'abdulbasit',
    'Abdul_Basit_Murattal_192kbps',
    'Abdul Basit Abdus Samad',
    'عبد الباسط عبد الصمد',
  ),
  Reciter(
    'sudais',
    'Abdurrahmaan_As-Sudais_192kbps',
    'Abdur-Rahman As-Sudais',
    'عبد الرحمن السديس',
  ),
];

Reciter reciterById(String? id) =>
    reciters.firstWhere((r) => r.id == id, orElse: () => reciters.first);

/// A verse found by [searchQuran], with the text it was found in.
class SearchHit {
  const SearchHit(this.verse, this.text, this.start, this.length);

  final Verse verse;

  /// The translation or the Arabic of the verse, whichever matched.
  final String text;

  /// Where the query sits in [text].
  final int start;
  final int length;
}

String _foldWords(String text) => text.toLowerCase().replaceAll('ё', 'е');

/// Finds [query] in the translation for [languageCode], or in the Arabic
/// when the query is written in Arabic letters. Case and `ё`/`е` do not
/// matter; Arabic is matched without its vowel marks.
List<SearchHit> searchQuran(
  List<SurahText> corpus,
  String query,
  String languageCode, {
  int limit = 300,
}) {
  final trimmed = query.trim();
  if (trimmed.length < 2) return const [];
  final arabic = RegExp('[ء-ي]').hasMatch(trimmed);
  final hits = <SearchHit>[];
  if (arabic) {
    final needle = stripArabicMarks(trimmed);
    for (var s = 0; s < corpus.length; s++) {
      final ayahs = corpus[s].arabic;
      for (var a = 0; a < ayahs.length; a++) {
        if (stripArabicMarks(ayahs[a]).contains(needle)) {
          hits.add(SearchHit((s + 1, a + 1), ayahs[a], 0, 0));
          if (hits.length >= limit) return hits;
        }
      }
    }
    return hits;
  }
  final needle = _foldWords(trimmed);
  for (var s = 0; s < corpus.length; s++) {
    final ayahs = corpus[s].translation(languageCode);
    if (ayahs == null) return hits;
    for (var a = 0; a < ayahs.length; a++) {
      // Folding keeps the length, so the offset fits the original text.
      final at = _foldWords(ayahs[a]).indexOf(needle);
      if (at >= 0) {
        hits.add(SearchHit((s + 1, a + 1), ayahs[a], at, needle.length));
        if (hits.length >= limit) return hits;
      }
    }
  }
  return hits;
}
