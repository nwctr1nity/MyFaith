import 'hijri.dart';
import 'prayer/prayer_calculator.dart';

/// When the card with the fasting countdown is shown.
enum RamadanMode { auto, always, never }

/// Whether the fasting countdown belongs on screen at [now].
///
/// A Hijri day begins at sunset, so Ramadan begins with the Maghrib before
/// its first fast: that night already has tarawih and the first suhoor.
/// It ends with the Maghrib of the last fast, when the night of Eid begins.
bool ramadanActive({
  required RamadanMode mode,
  required PrayerDay today,
  required DateTime now,
  int hijriAdjustment = 0,
}) {
  switch (mode) {
    case RamadanMode.always:
      return true;
    case RamadanMode.never:
      return false;
    case RamadanMode.auto:
      final night = !now.isBefore(today[PrayerSlot.maghrib]);
      return hijriFor(
        today.year,
        today.month,
        today.day + (night ? 1 : 0),
        adjustment: hijriAdjustment,
      ).isRamadan;
  }
}

/// Where a fasting person is in the day.
class FastMoment {
  const FastMoment({required this.fasting, required this.until});

  /// True from Fajr to Maghrib.
  final bool fasting;

  /// Maghrib while fasting; otherwise the Fajr that ends suhoor.
  final DateTime until;
}

/// [tomorrowFajr] is needed after Maghrib, when the next Fajr is tomorrow's.
FastMoment fastMoment({
  required PrayerDay today,
  required DateTime tomorrowFajr,
  required DateTime now,
}) {
  final fajr = today[PrayerSlot.fajr];
  final maghrib = today[PrayerSlot.maghrib];
  if (now.isBefore(fajr)) return FastMoment(fasting: false, until: fajr);
  if (now.isBefore(maghrib)) return FastMoment(fasting: true, until: maghrib);
  return FastMoment(fasting: false, until: tomorrowFajr);
}
