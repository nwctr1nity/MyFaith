import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_app/core/hijri.dart';

void main() {
  test('Gregorian and Hijri conversions are inverse, with a shift too', () {
    for (final adjustment in [-2, 0, 1]) {
      for (var offset = 0; offset < 800; offset += 7) {
        final g = DateTime.utc(2026, 1, 1 + offset);
        final h = hijriFor(g.year, g.month, g.day, adjustment: adjustment);
        expect(
          gregorianFor(h.year, h.month, h.day, adjustment: adjustment),
          g,
        );
      }
    }
  });

  test('a month has 29 or 30 days and its last day is followed by the 1st',
      () {
    for (var month = 1; month <= 12; month++) {
      final length = hijriMonthLength(1448, month);
      expect(length, anyOf(29, 30));
      final last = gregorianFor(1448, month, length);
      final next = hijriFor(last.year, last.month, last.day + 1);
      expect(next.day, 1);
    }
  });

  test('events are found on their days', () {
    expect(hijriEventOn(9, 1), HijriEvent.ramadan);
    expect(hijriEventOn(12, 13), HijriEvent.tashriq);
    expect(hijriEventOn(12, 14), isNull);
    expect(hijriEventOn(3, 12), isNull);
  });

  test('the coming events start with the nearest and cover a year', () {
    final list = upcomingHijriEvents(2026, 11, 17);
    expect(list.length, HijriEvent.values.length);
    expect(list.first.daysLeft, lessThanOrEqualTo(list.last.daysLeft));
    final ramadan = list.firstWhere((e) => e.event == HijriEvent.ramadan);
    expect(ramadan.date.year, 2027);
    expect(ramadan.date.month, 2);
  });
}
