import 'package:timezone/timezone.dart' as tz;

import '../hijri.dart';
import '../prayer/prayer_calculator.dart';
import 'alarm_settings.dart';

enum PlannedKind {
  adhan,

  /// A quiet notice that a prayer has begun, for the prayers whose adhan
  /// is switched off.
  prayerNotice,
  reminder,
  hadith,
  suhoor,
  suhoorStop,
  tahajjud,
  adhkarMorning,
  adhkarEvening,

  /// Friday morning: Surah al-Kahf.
  kahf,

  /// Shown when the planned window runs out, asking to open the app.
  refresh,
}

class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.kind,
    required this.time,
    this.slot,
    this.prayerTime,
  });

  /// Stable per day offset and kind, so replanning overwrites, never doubles.
  final int id;
  final PlannedKind kind;
  final tz.TZDateTime time;

  /// The prayer an adhan or reminder is for.
  final PrayerSlot? slot;

  /// For reminders and suhoor alarms: the prayer time they count down to.
  final tz.TZDateTime? prayerTime;
}

/// How many days ahead are scheduled. The app replans on every launch.
const planHorizonDays = 10;

/// True when the alarm settings ask for a suhoor alarm before the fast of
/// the given calendar day.
bool isSuhoorDay(AlarmSettings alarms, int year, int month, int day) {
  if (!alarms.suhoorEnabled) return false;
  if (alarms.suhoorEveryDay) return true;
  final hijri = hijriFor(year, month, day, adjustment: alarms.hijriAdjustment);
  if (alarms.suhoorInRamadan && hijri.isRamadan) return true;
  if (alarms.suhoorWhiteDays && hijri.isWhiteDay) return true;
  final weekday = DateTime.utc(year, month, day).weekday;
  if (alarms.suhoorMonThu &&
      (weekday == DateTime.monday || weekday == DateTime.thursday)) {
    return true;
  }
  return false;
}

/// Everything to schedule from [now] on, sorted by time. Pure: the same
/// inputs always give the same plan.
List<PlannedNotification> planNotifications({
  required PrayerPlace place,
  required PrayerSettings prayerSettings,
  required AlarmSettings alarms,
  required DateTime now,
  int days = planHorizonDays,
  PrayerCalculator calculator = const PrayerCalculator(),
}) {
  final location = tz.getLocation(place.timeZone);
  final localNow = tz.TZDateTime.from(now, location);
  final plan = <PlannedNotification>[];

  void add(PlannedNotification n) {
    if (n.time.isAfter(now)) plan.add(n);
  }

  PrayerDay dayAt(int offset) {
    // Calendar arithmetic in UTC avoids daylight-saving surprises.
    final date = DateTime.utc(
      localNow.year,
      localNow.month,
      localNow.day + offset,
    );
    return calculator.compute(
      place: place,
      settings: prayerSettings,
      year: date.year,
      month: date.month,
      day: date.day,
    );
  }

  var previous = dayAt(-1);
  PrayerDay? last;
  for (var d = 0; d < days; d++) {
    final today = dayAt(d);
    last = today;
    final fajr = today[PrayerSlot.fajr];

    for (final slot in PrayerSlot.values) {
      if (!alarms.adhanSlots.contains(slot)) {
        // Sunrise is not a prayer: with its bell off there is nothing to
        // announce.
        if (slot != PrayerSlot.sunrise) {
          add(
            PlannedNotification(
              id: 6000 + d * 10 + slot.index,
              kind: PlannedKind.prayerNotice,
              time: today[slot],
              slot: slot,
            ),
          );
        }
        continue;
      }
      final time = today[slot];
      add(
        PlannedNotification(
          id: 1000 + d * 10 + slot.index,
          kind: PlannedKind.adhan,
          time: time,
          slot: slot,
        ),
      );
      if (alarms.reminderMinutes > 0 && slot != PrayerSlot.sunrise) {
        add(
          PlannedNotification(
            id: 2000 + d * 10 + slot.index,
            kind: PlannedKind.reminder,
            time: time.subtract(Duration(minutes: alarms.reminderMinutes)),
            slot: slot,
            prayerTime: time,
          ),
        );
      }
    }

    if (alarms.hadithNotification) {
      add(
        PlannedNotification(
          id: 3000 + d,
          kind: PlannedKind.hadith,
          time: tz.TZDateTime(
            location,
            today.year,
            today.month,
            today.day,
            alarms.hadithHour,
          ),
        ),
      );
    }

    if (isSuhoorDay(alarms, today.year, today.month, today.day)) {
      add(
        PlannedNotification(
          id: 4000 + d,
          kind: PlannedKind.suhoor,
          time: fajr.subtract(
            Duration(minutes: alarms.suhoorMinutesBeforeFajr),
          ),
          prayerTime: fajr,
        ),
      );
      // The warning does not depend on the wake-up time: someone who is
      // already up may want only the warning.
      if (alarms.suhoorStopWarningMinutes > 0) {
        add(
          PlannedNotification(
            id: 4500 + d,
            kind: PlannedKind.suhoorStop,
            time: fajr.subtract(
              Duration(minutes: alarms.suhoorStopWarningMinutes),
            ),
            prayerTime: fajr,
          ),
        );
      }
    }

    if (alarms.tahajjudEnabled) {
      final weekday = DateTime.utc(today.year, today.month, today.day).weekday;
      if (alarms.tahajjudWeekdays.contains(weekday)) {
        add(
          PlannedNotification(
            id: 5000 + d,
            kind: PlannedKind.tahajjud,
            // The night that ends with this morning's Fajr began on the
            // previous calendar day.
            time: alarms.tahajjudAtLastThird
                ? previous.lastThirdOfNight
                : fajr.subtract(
                    Duration(minutes: alarms.tahajjudMinutesBeforeFajr),
                  ),
            prayerTime: fajr,
          ),
        );
      }
    }
    if (alarms.adhkarMorning) {
      add(
        PlannedNotification(
          id: 7000 + d,
          kind: PlannedKind.adhkarMorning,
          time: fajr.add(const Duration(minutes: 30)),
        ),
      );
    }
    if (alarms.adhkarEvening) {
      add(
        PlannedNotification(
          id: 7100 + d,
          kind: PlannedKind.adhkarEvening,
          time: today[PrayerSlot.asr].add(const Duration(minutes: 15)),
        ),
      );
    }
    if (alarms.kahfFriday &&
        DateTime.utc(today.year, today.month, today.day).weekday ==
            DateTime.friday) {
      add(
        PlannedNotification(
          id: 7200 + d,
          kind: PlannedKind.kahf,
          time: tz.TZDateTime(location, today.year, today.month, today.day, 9),
        ),
      );
    }
    previous = today;
  }

  if (last != null && plan.isNotEmpty) {
    plan.add(
      PlannedNotification(
        id: 9000,
        kind: PlannedKind.refresh,
        time: last[PrayerSlot.isha].add(const Duration(minutes: 30)),
      ),
    );
  }

  plan.sort((a, b) => a.time.compareTo(b.time));
  return plan;
}
