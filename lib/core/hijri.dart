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
