import 'package:hijri/hijri_calendar.dart';

/// A date in the Hijri calendar (Umm al-Qura tables).
class HijriDate {
  const HijriDate(this.year, this.month, this.day);

  final int year;

  /// 1 = Muharram, 9 = Ramadan, 12 = Dhu al-Hijjah.
  final int month;
  final int day;

  bool get isRamadan => month == 9;

  /// The 13th, 14th and 15th, the "white days" recommended for fasting.
  bool get isWhiteDay => day >= 13 && day <= 15;
}

/// Hijri date of the Gregorian calendar day. [adjustment] shifts the result
/// by whole days to follow a local moon sighting.
HijriDate hijriFor(int year, int month, int day, {int adjustment = 0}) {
  final h = HijriCalendar.fromDate(DateTime(year, month, day + adjustment));
  return HijriDate(h.hYear, h.hMonth, h.hDay);
}

/// The Gregorian calendar day (at UTC midnight) a Hijri date falls on,
/// the inverse of [hijriFor].
DateTime gregorianFor(int year, int month, int day, {int adjustment = 0}) {
  final g = HijriCalendar().hijriToGregorian(year, month, day);
  return DateTime.utc(g.year, g.month, g.day - adjustment);
}

/// 29 or 30.
int hijriMonthLength(int year, int month) =>
    HijriCalendar().getDaysInMonth(year, month);

/// Days of the Hijri year worth knowing in advance.
enum HijriEvent {
  newYear(1, 1),
  ashura(1, 10),
  ramadan(9, 1),
  lastTenNights(9, 21),
  eidFitr(10, 1),
  firstTenDays(12, 1),
  arafah(12, 9),
  eidAdha(12, 10),
  tashriq(12, 11, days: 3);

  const HijriEvent(this.month, this.day, {this.days = 1});

  final int month;
  final int day;

  /// How many days it lasts on the calendar.
  final int days;
}

/// The event marked on a Hijri day, if any.
HijriEvent? hijriEventOn(int month, int day) {
  for (final e in HijriEvent.values) {
    if (e.month == month && day >= e.day && day < e.day + e.days) return e;
  }
  return null;
}

/// A coming event with the Gregorian day it starts on.
class UpcomingEvent {
  const UpcomingEvent(this.event, this.hijriYear, this.date, this.daysLeft);

  final HijriEvent event;
  final int hijriYear;
  final DateTime date;
  final int daysLeft;
}

/// Every event of the next twelve months, nearest first, counted from the
/// Gregorian day given.
List<UpcomingEvent> upcomingHijriEvents(
  int year,
  int month,
  int day, {
  int adjustment = 0,
}) {
  final today = DateTime.utc(year, month, day);
  final now = hijriFor(year, month, day, adjustment: adjustment);
  final list = <UpcomingEvent>[];
  for (final hijriYear in [now.year, now.year + 1]) {
    for (final e in HijriEvent.values) {
      final date = gregorianFor(
        hijriYear,
        e.month,
        e.day,
        adjustment: adjustment,
      );
      final left = date.difference(today).inDays;
      if (left >= 0 && left < 355) {
        list.add(UpcomingEvent(e, hijriYear, date, left));
      }
    }
  }
  list.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
  return list;
}
