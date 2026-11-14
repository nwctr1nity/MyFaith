import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_app/core/prayer/prayer_calculator.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

const makkah = PrayerPlace(
  latitude: 21.4225,
  longitude: 39.8262,
  timeZone: 'Asia/Riyadh',
);
const almaty = PrayerPlace(
  latitude: 43.2525,
  longitude: 76.9115,
  timeZone: 'Asia/Almaty',
);
const auckland = PrayerPlace(
  latitude: -36.8485,
  longitude: 174.7633,
  timeZone: 'Pacific/Auckland',
);
const honolulu = PrayerPlace(
  latitude: 21.3069,
  longitude: -157.8583,
  timeZone: 'Pacific/Honolulu',
);
const tromso = PrayerPlace(
  latitude: 69.6492,
  longitude: 18.9553,
  timeZone: 'Europe/Oslo',
);

void main() {
  const calc = PrayerCalculator();

  setUpAll(tzdata.initializeTimeZones);

  PrayerDay day(
    PrayerPlace place, {
    PrayerSettings settings = const PrayerSettings(),
    int year = 2026,
    int month = 3,
    int dayOfMonth = 20,
  }) =>
      calc.compute(
        place: place,
        settings: settings,
        year: year,
        month: month,
        day: dayOfMonth,
      );

  test('times come in chronological order', () {
    for (final place in [makkah, almaty, auckland, honolulu]) {
      final d = day(place);
      final ordered = PrayerSlot.values.map((s) => d[s]).toList();
      for (var i = 1; i < ordered.length; i++) {
        expect(ordered[i].isAfter(ordered[i - 1]), isTrue,
            reason: '${place.timeZone}: ${PrayerSlot.values[i]}');
      }
      expect(d.nextFajr.isAfter(d[PrayerSlot.isha]), isTrue);
    }
  });

  test('every time falls on the requested local date, east and west', () {
    // Far from Greenwich the UTC date differs from the local one for part of
    // the day; a mix-up shows as times landing on the neighbouring date.
    for (final place in [makkah, almaty, auckland, honolulu]) {
      final d = day(place, month: 6, dayOfMonth: 15);
      for (final slot in PrayerSlot.values) {
        expect(d[slot].day, 15, reason: '${place.timeZone} $slot');
        expect(d[slot].month, 6, reason: '${place.timeZone} $slot');
      }
    }
  });

  test('Makkah at the equinox matches the sun', () {
    final d = day(makkah,
        settings: const PrayerSettings(method: CalcMethod.ummAlQura));
    // Solar noon: 20.7 min west of the zone meridian plus 7.5 min equation
    // of time puts it near 12:28.
    final dhuhr = d[PrayerSlot.dhuhr];
    expect(dhuhr.hour, 12);
    expect(dhuhr.minute, inInclusiveRange(24, 33));
    // Day and night are about equal.
    final daylight = d[PrayerSlot.maghrib].difference(d[PrayerSlot.sunrise]);
    expect(daylight.inMinutes, inInclusiveRange(12 * 60 - 5, 12 * 60 + 20));
    // Umm al-Qura sets Isha 90 minutes after Maghrib.
    expect(d[PrayerSlot.isha].difference(d[PrayerSlot.maghrib]).inMinutes, 90);
  });

  test('times are in the place zone, not UTC', () {
    final d = day(almaty);
    expect(d[PrayerSlot.dhuhr].location.name, 'Asia/Almaty');
    expect(d[PrayerSlot.dhuhr].timeZoneOffset, const Duration(hours: 5));
    // Almaty sits almost on its zone meridian (75°E), so noon is near 13:00
    // minus nothing: 12:5x local.
    expect(d[PrayerSlot.dhuhr].hour, inInclusiveRange(12, 13));
  });

  test('Hanafi Asr is later than Shafi Asr', () {
    final shafi = day(almaty);
    final hanafi =
        day(almaty, settings: const PrayerSettings(madhab: AsrMadhab.hanafi));
    expect(hanafi[PrayerSlot.asr].isAfter(shafi[PrayerSlot.asr]), isTrue);
    expect(hanafi[PrayerSlot.dhuhr], shafi[PrayerSlot.dhuhr]);
  });

  test('a manual correction shifts only its own prayer', () {
    final base = day(almaty);
    final shifted = day(
      almaty,
      settings: const PrayerSettings(adjustments: {PrayerSlot.fajr: 3}),
    );
    expect(
      shifted[PrayerSlot.fajr].difference(base[PrayerSlot.fajr]).inMinutes,
      3,
    );
    expect(shifted[PrayerSlot.isha], base[PrayerSlot.isha]);
  });

  test('a lower Fajr angle gives a later Fajr', () {
    final mwl = day(almaty); // 18°
    final russia =
        day(almaty, settings: const PrayerSettings(method: CalcMethod.russia));
    expect(methodAngles(CalcMethod.russia).fajr, lessThan(18));
    expect(russia[PrayerSlot.fajr].isAfter(mwl[PrayerSlot.fajr]), isTrue);
  });

  test('polar summer still yields a full, ordered timetable', () {
    final d = day(tromso, month: 5, dayOfMonth: 10);
    final ordered = PrayerSlot.values.map((s) => d[s]).toList();
    for (var i = 1; i < ordered.length; i++) {
      expect(ordered[i].isBefore(ordered[i - 1]), isFalse,
          reason: '${PrayerSlot.values[i]}');
    }
  });

  test('last third of the night lies between Maghrib and next Fajr', () {
    final d = day(almaty);
    expect(d.lastThirdOfNight.isAfter(d[PrayerSlot.maghrib]), isTrue);
    expect(d.lastThirdOfNight.isBefore(d.nextFajr), isTrue);
  });

  group('momentAt', () {
    late PrayerDay d;
    setUp(() => d = day(almaty));

    DateTime after(PrayerSlot slot, [int minutes = 1]) =>
        d[slot].add(Duration(minutes: minutes));

    test('before Fajr: next is Fajr, Isha is still running', () {
      final m = calc.momentAt(
          d, d[PrayerSlot.fajr].subtract(const Duration(minutes: 5)));
      expect(m.next, PrayerSlot.fajr);
      expect(m.nextTime, d[PrayerSlot.fajr]);
      expect(m.current, PrayerSlot.isha);
    });

    test('after Fajr: Fajr is running until sunrise', () {
      final m = calc.momentAt(d, after(PrayerSlot.fajr));
      expect(m.next, PrayerSlot.sunrise);
      expect(m.current, PrayerSlot.fajr);
    });

    test('between sunrise and Dhuhr nothing is running', () {
      final m = calc.momentAt(d, after(PrayerSlot.sunrise));
      expect(m.next, PrayerSlot.dhuhr);
      expect(m.current, isNull);
    });

    test('exactly at a prayer time that prayer has started', () {
      final m = calc.momentAt(d, d[PrayerSlot.asr]);
      expect(m.current, PrayerSlot.asr);
      expect(m.next, PrayerSlot.maghrib);
    });

    test('after Isha: next is tomorrow\'s Fajr', () {
      final m = calc.momentAt(d, after(PrayerSlot.isha));
      expect(m.next, PrayerSlot.fajr);
      expect(m.nextTime, d.nextFajr);
      expect(m.current, PrayerSlot.isha);
    });
  });

  test('computeForInstant uses the date of the place, not of UTC', () {
    // 2026-06-15 20:00 UTC is already June 16 in Auckland.
    final instant = DateTime.utc(2026, 6, 15, 20);
    final d = calc.computeForInstant(
      place: auckland,
      settings: const PrayerSettings(),
      now: instant,
    );
    expect(d.day, 16);
    final local = tz.TZDateTime.from(instant, tz.getLocation(auckland.timeZone));
    expect(local.day, 16);
  });

  test('country defaults', () {
    expect(defaultMethodForCountry('RU'), CalcMethod.russia);
    expect(defaultMethodForCountry('tr'), CalcMethod.turkiye);
    expect(defaultMethodForCountry('KZ'), CalcMethod.muslimWorldLeague);
    expect(defaultMethodForCountry(''), CalcMethod.muslimWorldLeague);
  });
}
