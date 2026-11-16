import '../prayer/prayer_calculator.dart';

/// A set of adhan recordings the user can choose.
class Muezzin {
  const Muezzin({
    required this.id,
    required this.names,
    required this.fajr,
    required this.other,
    this.perPrayer = const {},
  });

  final String id;

  /// Name by language code, with 'en' as the fallback.
  final Map<String, String> names;

  /// Recordings, as names of files in `android/.../res/raw`.
  final String fajr;
  final String other;

  /// Recordings made for one prayer, where the set has them.
  final Map<PrayerSlot, String> perPrayer;

  String name(String languageCode) => names[languageCode] ?? names['en']!;

  String sound(PrayerSlot slot) =>
      slot == PrayerSlot.fajr ? fajr : perPrayer[slot] ?? other;
}

/// The first one is the default.
const muezzins = <Muezzin>[
  Muezzin(
    id: 'doha',
    names: {'ru': 'Доха, Катар', 'en': 'Doha, Qatar', 'ar': 'الدوحة، قطر'},
    fajr: 'azan_doha_fajr',
    other: 'azan_doha_dhuhr',
    perPrayer: {
      PrayerSlot.asr: 'azan_doha_asr',
      PrayerSlot.maghrib: 'azan_doha_maghrib',
      PrayerSlot.isha: 'azan_doha_isha',
    },
  ),
];

Muezzin muezzinById(String? id) =>
    muezzins.firstWhere((m) => m.id == id, orElse: () => muezzins.first);
