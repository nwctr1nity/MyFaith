/// One hadith from Sahih al-Bukhari in three languages.
class Hadith {
  const Hadith({
    required this.number,
    required this.arabic,
    required this.english,
    required this.russian,
  });

  final int number;
  final String arabic;
  final String english;
  final String russian;

  /// Text in the interface language; Arabic interface reads the original.
  String translation(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return russian;
      case 'ar':
        return arabic;
      default:
        return english;
    }
  }

  static Hadith? fromJson(Object? json) {
    if (json is! Map) return null;
    final n = json['n'];
    final ar = json['ar'];
    final en = json['en'];
    final ru = json['ru'];
    if (n is! int || ar is! String || en is! String || ru is! String) {
      return null;
    }
    return Hadith(number: n, arabic: ar, english: en, russian: ru);
  }
}

/// Days since 1970-01-01 for a calendar date.
int dayNumber(int year, int month, int day) =>
    DateTime.utc(year, month, day).difference(DateTime.utc(1970)).inDays;

/// Index into a pool of [poolSize] hadiths for the given day. Consecutive
/// days jump through the pool by a fixed stride so neighbouring days do not
/// show neighbouring hadiths, and every hadith is shown once per cycle.
int dailyHadithIndex(int dayNumber, int poolSize) {
  if (poolSize <= 0) return 0;
  var stride = (poolSize * 0.618).round();
  if (stride < 1) stride = 1;
  while (_gcd(stride, poolSize) != 1) {
    stride++;
  }
  return (dayNumber % poolSize) * stride % poolSize;
}

int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
