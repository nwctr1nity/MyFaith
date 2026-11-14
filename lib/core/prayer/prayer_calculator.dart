import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:timezone/timezone.dart' as tz;

/// The six daily events shown in the timetable, in chronological order.
enum PrayerSlot { fajr, sunrise, dhuhr, asr, maghrib, isha }

enum AsrMadhab { shafi, hanafi }

/// Calculation methods offered in settings. Each maps to an adhan_dart preset.
enum CalcMethod {
  muslimWorldLeague,
  russia,
  turkiye,
  ummAlQura,
  egyptian,
  karachi,
  northAmerica,
  dubai,
  qatar,
  kuwait,
  gulfRegion,
  singapore,
  indonesian,
  tehran,
  jafari,
  france,
  jordan,
  morocco,
  algerian,
  tunisia,
  portugal,
  moonsightingCommittee,
}

adhan.CalculationParameters _presetFor(CalcMethod method) {
  switch (method) {
    case CalcMethod.muslimWorldLeague:
      return adhan.CalculationMethodParameters.muslimWorldLeague();
    case CalcMethod.russia:
      return adhan.CalculationMethodParameters.russia();
    case CalcMethod.turkiye:
      return adhan.CalculationMethodParameters.turkiye();
    case CalcMethod.ummAlQura:
      return adhan.CalculationMethodParameters.ummAlQura();
    case CalcMethod.egyptian:
      return adhan.CalculationMethodParameters.egyptian();
    case CalcMethod.karachi:
      return adhan.CalculationMethodParameters.karachi();
    case CalcMethod.northAmerica:
      return adhan.CalculationMethodParameters.northAmerica();
    case CalcMethod.dubai:
      return adhan.CalculationMethodParameters.dubai();
    case CalcMethod.qatar:
      return adhan.CalculationMethodParameters.qatar();
    case CalcMethod.kuwait:
      return adhan.CalculationMethodParameters.kuwait();
    case CalcMethod.gulfRegion:
      return adhan.CalculationMethodParameters.gulfRegion();
    case CalcMethod.singapore:
      return adhan.CalculationMethodParameters.singapore();
    case CalcMethod.indonesian:
      return adhan.CalculationMethodParameters.indonesian();
    case CalcMethod.tehran:
      return adhan.CalculationMethodParameters.tehran();
    case CalcMethod.jafari:
      return adhan.CalculationMethodParameters.jafari();
    case CalcMethod.france:
      return adhan.CalculationMethodParameters.france();
    case CalcMethod.jordan:
      return adhan.CalculationMethodParameters.jordan();
    case CalcMethod.morocco:
      return adhan.CalculationMethodParameters.morocco();
    case CalcMethod.algerian:
      return adhan.CalculationMethodParameters.algerian();
    case CalcMethod.tunisia:
      return adhan.CalculationMethodParameters.tunisia();
    case CalcMethod.portugal:
      return adhan.CalculationMethodParameters.portugal();
    case CalcMethod.moonsightingCommittee:
      return adhan.CalculationMethodParameters.moonsightingCommittee();
  }
}

/// Fajr and Isha angles of a method, for display in settings.
({double fajr, double isha, int ishaInterval}) methodAngles(CalcMethod method) {
  final p = _presetFor(method);
  return (fajr: p.fajrAngle, isha: p.ishaAngle, ishaInterval: p.ishaInterval ?? 0);
}

/// The method a country's religious authority is known to use. Countries not
/// listed fall back to the Muslim World League.
CalcMethod defaultMethodForCountry(String countryCode) {
  const byCountry = <String, CalcMethod>{
    'RU': CalcMethod.russia,
    'TR': CalcMethod.turkiye,
    'SA': CalcMethod.ummAlQura,
    'EG': CalcMethod.egyptian,
    'PK': CalcMethod.karachi,
    'IN': CalcMethod.karachi,
    'BD': CalcMethod.karachi,
    'AF': CalcMethod.karachi,
    'US': CalcMethod.northAmerica,
    'CA': CalcMethod.northAmerica,
    'AE': CalcMethod.dubai,
    'QA': CalcMethod.qatar,
    'KW': CalcMethod.kuwait,
    'BH': CalcMethod.gulfRegion,
    'OM': CalcMethod.gulfRegion,
    'SG': CalcMethod.singapore,
    'MY': CalcMethod.singapore,
    'BN': CalcMethod.singapore,
    'ID': CalcMethod.indonesian,
    'IR': CalcMethod.tehran,
    'FR': CalcMethod.france,
    'JO': CalcMethod.jordan,
    'MA': CalcMethod.morocco,
    'DZ': CalcMethod.algerian,
    'TN': CalcMethod.tunisia,
    'PT': CalcMethod.portugal,
  };
  return byCountry[countryCode.toUpperCase()] ?? CalcMethod.muslimWorldLeague;
}

/// Everything that changes the computed times apart from place and date.
class PrayerSettings {
  const PrayerSettings({
    this.method = CalcMethod.muslimWorldLeague,
    this.madhab = AsrMadhab.shafi,
    this.adjustments = const {},
  });

  final CalcMethod method;
  final AsrMadhab madhab;

  /// Manual corrections in minutes, to match a local mosque timetable.
  final Map<PrayerSlot, int> adjustments;

  int adjustmentFor(PrayerSlot slot) => adjustments[slot] ?? 0;
}

/// A place with the time zone its timetable is shown in.
class PrayerPlace {
  const PrayerPlace({
    required this.latitude,
    required this.longitude,
    required this.timeZone,
  });

  final double latitude;
  final double longitude;

  /// IANA identifier, for example `Asia/Almaty`.
  final String timeZone;
}

/// One calendar day of prayer times, in the place's own time zone.
class PrayerDay {
  PrayerDay({
    required this.year,
    required this.month,
    required this.day,
    required this.times,
    required this.nextFajr,
    required this.lastThirdOfNight,
  });

  final int year;
  final int month;
  final int day;
  final Map<PrayerSlot, tz.TZDateTime> times;

  /// Fajr of the following day, used once Isha has passed.
  final tz.TZDateTime nextFajr;

  /// Start of the last third of the night that follows this day's Maghrib.
  final tz.TZDateTime lastThirdOfNight;

  tz.TZDateTime operator [](PrayerSlot slot) => times[slot]!;
}

/// The upcoming prayer and the one whose time is running now.
class PrayerMoment {
  const PrayerMoment({
    required this.next,
    required this.nextTime,
    required this.current,
  });

  final PrayerSlot next;
  final tz.TZDateTime nextTime;

  /// The prayer whose time is running. Null between sunrise and Dhuhr, when
  /// no prayer time is running. Before Fajr it is the previous day's Isha.
  final PrayerSlot? current;
}

class PrayerCalculator {
  const PrayerCalculator();

  /// Computes the timetable for the calendar date [year]-[month]-[day] as it
  /// is counted in the place's own time zone.
  PrayerDay compute({
    required PrayerPlace place,
    required PrayerSettings settings,
    required int year,
    required int month,
    required int day,
  }) {
    final location = tz.getLocation(place.timeZone);
    final coordinates = adhan.Coordinates(place.latitude, place.longitude);
    final preset = _presetFor(settings.method);
    final params = preset.copyWith(
      madhab: settings.madhab == AsrMadhab.hanafi
          ? adhan.Madhab.hanafi
          : adhan.Madhab.shafi,
      highLatitudeRule: adhan.HighLatitudeRule.recommended(coordinates),
      adjustments: {
        adhan.Prayer.fajr: settings.adjustmentFor(PrayerSlot.fajr),
        adhan.Prayer.sunrise: settings.adjustmentFor(PrayerSlot.sunrise),
        adhan.Prayer.dhuhr: settings.adjustmentFor(PrayerSlot.dhuhr),
        adhan.Prayer.asr: settings.adjustmentFor(PrayerSlot.asr),
        adhan.Prayer.maghrib: settings.adjustmentFor(PrayerSlot.maghrib),
        adhan.Prayer.isha: settings.adjustmentFor(PrayerSlot.isha),
      },
    );

    // adhan_dart reads only the calendar fields of the date and returns UTC
    // instants, so the local calendar date is passed as a plain UTC date.
    final times = adhan.PrayerTimes(
      date: DateTime.utc(year, month, day),
      coordinates: coordinates,
      calculationParameters: params,
    );
    final sunnah = adhan.SunnahTimes(times);

    tz.TZDateTime local(DateTime utc) => tz.TZDateTime.from(utc, location);

    return PrayerDay(
      year: year,
      month: month,
      day: day,
      times: {
        PrayerSlot.fajr: local(times.fajr),
        PrayerSlot.sunrise: local(times.sunrise),
        PrayerSlot.dhuhr: local(times.dhuhr),
        PrayerSlot.asr: local(times.asr),
        PrayerSlot.maghrib: local(times.maghrib),
        PrayerSlot.isha: local(times.isha),
      },
      nextFajr: local(times.fajrAfter),
      lastThirdOfNight: local(sunnah.lastThirdOfTheNight),
    );
  }

  /// Timetable for the day that [now] falls on in the place's time zone.
  PrayerDay computeForInstant({
    required PrayerPlace place,
    required PrayerSettings settings,
    required DateTime now,
  }) {
    final local = tz.TZDateTime.from(now, tz.getLocation(place.timeZone));
    return compute(
      place: place,
      settings: settings,
      year: local.year,
      month: local.month,
      day: local.day,
    );
  }

  /// Which prayer comes next after [now] and which one is running, given the
  /// timetable of the day [now] falls on.
  PrayerMoment momentAt(PrayerDay today, DateTime now) {
    PrayerSlot? lastPassed;
    for (final slot in PrayerSlot.values) {
      final time = today[slot];
      if (now.isBefore(time)) {
        final PrayerSlot? current;
        if (lastPassed == null) {
          // Before Fajr the running prayer is still last night's Isha.
          current = PrayerSlot.isha;
        } else if (lastPassed == PrayerSlot.sunrise) {
          // Sunrise ends Fajr and starts no prayer.
          current = null;
        } else {
          current = lastPassed;
        }
        return PrayerMoment(next: slot, nextTime: time, current: current);
      }
      lastPassed = slot;
    }
    return PrayerMoment(
      next: PrayerSlot.fajr,
      nextTime: today.nextFajr,
      current: PrayerSlot.isha,
    );
  }
}
