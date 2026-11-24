import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_app/core/alarms/alarm_settings.dart';
import 'package:muslim_app/core/alarms/notification_planner.dart';
import 'package:muslim_app/core/content/hadith.dart';
import 'package:muslim_app/core/hijri.dart';
import 'package:muslim_app/core/prayer/prayer_calculator.dart';
import 'package:muslim_app/core/qibla.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

const _almaty = PrayerPlace(
  latitude: 43.2525,
  longitude: 76.9115,
  timeZone: 'Asia/Almaty',
);

List<PlannedNotification> _plan(AlarmSettings alarms, DateTime now,
        {int days = planHorizonDays}) =>
    planNotifications(
      place: _almaty,
      prayerSettings: const PrayerSettings(),
      alarms: alarms,
      now: now,
      days: days,
    );

void main() {
  setUpAll(tzdata.initializeTimeZones);

  // 03:00 in Almaty on 14 November 2026, before Fajr.
  final night = DateTime.utc(2026, 11, 13, 22);

  test('plan is sorted, in the future and has unique ids', () {
    final plan = _plan(
      const AlarmSettings(
        reminderMinutes: 15,
        hadithNotification: true,
        suhoorEnabled: true,
        suhoorEveryDay: true,
        tahajjudEnabled: true,
      ),
      night,
    );
    expect(plan, isNotEmpty);
    for (var i = 1; i < plan.length; i++) {
      expect(plan[i].time.isBefore(plan[i - 1].time), isFalse);
    }
    expect(plan.every((p) => p.time.isAfter(night)), isTrue);
    expect({for (final p in plan) p.id}, hasLength(plan.length));
    // Android keeps at most 500 alarms per app.
    expect(plan.length, lessThan(400));
  });

  test('adhkar reminders follow Fajr and Asr, al-Kahf comes on Fridays', () {
    final plan = _plan(
      const AlarmSettings(
        adhkarMorning: true,
        adhkarEvening: true,
        kahfFriday: true,
      ),
      night,
    );
    final ids = plan.map((p) => p.id).toSet();
    expect(ids.length, plan.length);

    final fajr = plan.firstWhere(
      (p) => p.kind == PlannedKind.adhan && p.slot == PrayerSlot.fajr,
    );
    final morning = plan.firstWhere((p) => p.kind == PlannedKind.adhkarMorning);
    expect(morning.time.difference(fajr.time), const Duration(minutes: 30));

    final asr = plan.firstWhere(
      (p) => p.kind == PlannedKind.adhan && p.slot == PrayerSlot.asr,
    );
    final evening = plan.firstWhere((p) => p.kind == PlannedKind.adhkarEvening);
    expect(evening.time.difference(asr.time), const Duration(minutes: 15));

    final kahf = plan.where((p) => p.kind == PlannedKind.kahf).toList();
    // Ten days from a Saturday hold one Friday.
    expect(kahf, hasLength(1));
    expect(kahf.single.time.weekday, DateTime.friday);
    expect(kahf.single.time.hour, 9);

    expect(
      _plan(const AlarmSettings(), night).where(
        (p) =>
            p.kind == PlannedKind.adhkarMorning ||
            p.kind == PlannedKind.adhkarEvening ||
            p.kind == PlannedKind.kahf,
      ),
      isEmpty,
    );
  });

  test('adhan only for the chosen prayers', () {
    final plan = _plan(
      const AlarmSettings(adhanSlots: {PrayerSlot.fajr, PrayerSlot.maghrib}),
      night,
      days: 1,
    );
    final adhans = plan.where((p) => p.kind == PlannedKind.adhan);
    expect(adhans.map((p) => p.slot),
        [PrayerSlot.fajr, PrayerSlot.maghrib]);
    // The other prayers are announced quietly; sunrise is not a prayer.
    final notices = plan.where((p) => p.kind == PlannedKind.prayerNotice);
    expect(notices.map((p) => p.slot),
        [PrayerSlot.dhuhr, PrayerSlot.asr, PrayerSlot.isha]);
  });

  test('reminder comes the chosen minutes before the prayer', () {
    final plan = _plan(const AlarmSettings(reminderMinutes: 20), night, days: 1);
    final reminders =
        plan.where((p) => p.kind == PlannedKind.reminder).toList();
    expect(reminders, hasLength(5));
    for (final r in reminders) {
      expect(r.prayerTime!.difference(r.time).inMinutes, 20);
    }
  });

  test('suhoor rings before Fajr and the warning after it', () {
    final plan = _plan(
      const AlarmSettings(
        adhanSlots: {PrayerSlot.fajr},
        suhoorEnabled: true,
        suhoorEveryDay: true,
        suhoorMinutesBeforeFajr: 60,
        suhoorStopWarningMinutes: 10,
      ),
      night,
      days: 1,
    );
    final fajr = plan.firstWhere((p) => p.kind == PlannedKind.adhan).time;
    final suhoor = plan.firstWhere((p) => p.kind == PlannedKind.suhoor).time;
    final stop = plan.firstWhere((p) => p.kind == PlannedKind.suhoorStop).time;
    expect(fajr.difference(suhoor).inMinutes, 60);
    expect(fajr.difference(stop).inMinutes, 10);
  });

  test('suhoor days follow Ramadan, Mondays, Thursdays and white days', () {
    const ramadanOnly = AlarmSettings(suhoorEnabled: true);
    // 1 Ramadan 1447 is 18 February 2026 in the Umm al-Qura calendar.
    expect(hijriFor(2026, 2, 18).isRamadan, isTrue);
    expect(hijriFor(2026, 2, 18).day, 1);
    expect(isSuhoorDay(ramadanOnly, 2026, 2, 20), isTrue);
    expect(isSuhoorDay(ramadanOnly, 2026, 11, 16), isFalse);

    const monThu = AlarmSettings(
      suhoorEnabled: true,
      suhoorInRamadan: false,
      suhoorMonThu: true,
    );
    expect(isSuhoorDay(monThu, 2026, 11, 16), isTrue); // Monday
    expect(isSuhoorDay(monThu, 2026, 11, 19), isTrue); // Thursday
    expect(isSuhoorDay(monThu, 2026, 11, 17), isFalse);

    const white = AlarmSettings(
      suhoorEnabled: true,
      suhoorInRamadan: false,
      suhoorWhiteDays: true,
    );
    var whiteDays = 0;
    for (var d = 1; d <= 30; d++) {
      if (isSuhoorDay(white, 2026, 11, d)) whiteDays++;
    }
    expect(whiteDays, 3);

    expect(isSuhoorDay(const AlarmSettings(suhoorEveryDay: true), 2026, 11, 16),
        isFalse, reason: 'the main switch is off');
  });

  test('tahajjud rings in the last third, between Isha and Fajr', () {
    final plan = _plan(
      const AlarmSettings(
        adhanSlots: {PrayerSlot.fajr},
        tahajjudEnabled: true,
      ),
      // 20:00 in Almaty: tonight's alarm is still ahead.
      DateTime.utc(2026, 11, 14, 15),
      days: 2,
    );
    final tahajjud = plan.firstWhere((p) => p.kind == PlannedKind.tahajjud);
    final fajr = plan.firstWhere((p) => p.kind == PlannedKind.adhan).time;
    expect(tahajjud.time.isBefore(fajr), isTrue);
    expect(fajr.difference(tahajjud.time).inHours, inInclusiveRange(2, 5));
  });

  test('tahajjud respects weekdays and the fixed offset', () {
    final plan = _plan(
      const AlarmSettings(
        adhanSlots: {},
        tahajjudEnabled: true,
        tahajjudAtLastThird: false,
        tahajjudMinutesBeforeFajr: 30,
        tahajjudWeekdays: {DateTime.friday},
      ),
      night,
    );
    final alarms = plan.where((p) => p.kind == PlannedKind.tahajjud).toList();
    expect(alarms, isNotEmpty);
    expect(alarms.every((p) => p.time.weekday == DateTime.friday), isTrue);
    expect(alarms.first.prayerTime!.difference(alarms.first.time).inMinutes, 30);
  });

  test('the plan ends with a reminder to open the app', () {
    final plan = _plan(const AlarmSettings(), night);
    expect(plan.last.kind, PlannedKind.refresh);
  });

  test('daily hadith changes every day and covers the whole pool', () {
    const pool = 3006;
    final seen = <int>{};
    final start = dayNumber(2026, 11, 14);
    for (var d = 0; d < pool; d++) {
      seen.add(dailyHadithIndex(start + d, pool));
    }
    expect(seen, hasLength(pool));
    expect(dailyHadithIndex(start, pool),
        isNot(dailyHadithIndex(start + 1, pool)));
    expect(dayNumber(2026, 11, 15) - dayNumber(2026, 11, 14), 1);
  });

  test('qibla bearings match known values', () {
    // Published bearings: Almaty about 245°, Moscow 176°, New York 58°.
    expect(qiblaBearing(43.2525, 76.9115), closeTo(245, 2));
    expect(qiblaBearing(55.7558, 37.6173), closeTo(176, 2));
    expect(qiblaBearing(40.7128, -74.0060), closeTo(58.5, 2));
    expect(angleDifference(350, 10), 20);
    expect(angleDifference(10, 350), -20);
    expect(angleDifference(0, 180), 180);
  });
}
