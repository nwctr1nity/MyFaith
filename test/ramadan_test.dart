import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_app/core/hijri.dart';
import 'package:muslim_app/core/prayer/prayer_calculator.dart';
import 'package:muslim_app/core/ramadan.dart';
import 'package:timezone/data/latest.dart' as tzdata;

void main() {
  tzdata.initializeTimeZones();
  const calculator = PrayerCalculator();
  const place = PrayerPlace(
    latitude: 43.2525,
    longitude: 76.9115,
    timeZone: 'Asia/Almaty',
  );
  const settings = PrayerSettings(
    method: CalcMethod.muslimWorldLeague,
    madhab: AsrMadhab.hanafi,
    adjustments: {},
  );
  PrayerDay dayOf(DateTime d) => calculator.compute(
    place: place,
    settings: settings,
    year: d.year,
    month: d.month,
    day: d.day,
  );

  test('the countdown starts with the Maghrib before the first fast and '
      'ends with the Maghrib of the last one', () {
    final first = gregorianFor(1448, 9, 1);
    final eve = dayOf(first.subtract(const Duration(days: 1)));
    final maghrib = eve[PrayerSlot.maghrib];
    bool active(PrayerDay day, DateTime now) =>
        ramadanActive(mode: RamadanMode.auto, today: day, now: now);

    expect(active(eve, maghrib.subtract(const Duration(minutes: 1))), isFalse);
    expect(active(eve, maghrib), isTrue);

    final firstDay = dayOf(first);
    // The first suhoor, before dawn of the first fast.
    expect(
      active(
        firstDay,
        firstDay[PrayerSlot.fajr].subtract(const Duration(hours: 1)),
      ),
      isTrue,
    );

    final lastDay = dayOf(
      first.add(Duration(days: hijriMonthLength(1448, 9) - 1)),
    );
    final lastMaghrib = lastDay[PrayerSlot.maghrib];
    expect(
      active(lastDay, lastMaghrib.subtract(const Duration(minutes: 1))),
      isTrue,
    );
    expect(active(lastDay, lastMaghrib), isFalse);
  });

  test('always and never ignore the calendar', () {
    final day = dayOf(DateTime.utc(2026, 11, 17));
    final noon = day[PrayerSlot.dhuhr];
    expect(
      ramadanActive(mode: RamadanMode.always, today: day, now: noon),
      isTrue,
    );
    expect(
      ramadanActive(mode: RamadanMode.never, today: day, now: noon),
      isFalse,
    );
    expect(
      ramadanActive(mode: RamadanMode.auto, today: day, now: noon),
      isFalse,
    );
  });

  test('by day the fast runs to Maghrib, by night suhoor runs to Fajr', () {
    final day = dayOf(DateTime.utc(2027, 2, 20));
    final next = dayOf(DateTime.utc(2027, 2, 21))[PrayerSlot.fajr];
    FastMoment at(DateTime now) =>
        fastMoment(today: day, tomorrowFajr: next, now: now);

    final early = at(day[PrayerSlot.fajr].subtract(const Duration(hours: 1)));
    expect(early.fasting, isFalse);
    expect(early.until, day[PrayerSlot.fajr]);

    final noon = at(day[PrayerSlot.dhuhr]);
    expect(noon.fasting, isTrue);
    expect(noon.until, day[PrayerSlot.maghrib]);

    final evening = at(day[PrayerSlot.isha]);
    expect(evening.fasting, isFalse);
    expect(evening.until, next);
  });
}
