import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_app/core/location/city.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  late List<City> cities;

  setUpAll(() {
    tzdata.initializeTimeZones();
    cities = parseCities(File('assets/cities.tsv').readAsStringSync());
  });

  test('the bundled list parses completely', () {
    final lines = File('assets/cities.tsv')
        .readAsLinesSync()
        .where((l) => l.isNotEmpty)
        .length;
    expect(cities.length, lines);
    expect(cities.length, greaterThan(30000));
  });

  test('every city has a time zone the app can resolve', () {
    final unknown = <String>{};
    for (final c in cities) {
      try {
        tz.getLocation(c.timeZone);
      } on tz.LocationNotFoundException {
        unknown.add(c.timeZone);
      }
    }
    expect(unknown, isEmpty);
  });

  test('search works in English, Russian and Arabic', () {
    expect(searchCities(cities, 'almaty').first.city.name, 'Almaty');
    final ru = searchCities(cities, 'Алматы').first;
    expect(ru.city.name, 'Almaty');
    expect(ru.matchedName, 'Алматы');
    expect(searchCities(cities, 'казань').first.city.countryCode, 'RU');
    expect(searchCities(cities, 'مكة').first.city.name, 'Makkah');
    // An English spelling that differs from the list's own name.
    expect(searchCities(cities, 'Mecca').first.city.name, 'Makkah');
  });

  test('larger cities come first and ё equals е', () {
    final moscow = searchCities(cities, 'Москва').first;
    expect(moscow.city.name, 'Moscow');
    expect(moscow.city.countryCode, 'RU');
    expect(searchCities(cities, 'орел'), isNotEmpty);
    expect(
      searchCities(cities, 'орёл').map((m) => m.city.name),
      searchCities(cities, 'орел').map((m) => m.city.name),
    );
  });

  test('empty and unknown queries return nothing', () {
    expect(searchCities(cities, '  '), isEmpty);
    expect(searchCities(cities, 'zzzzqqqq'), isEmpty);
  });

  test('nearest city', () {
    expect(nearestCity(cities, 43.24, 76.90)?.name, 'Almaty');
    // Middle of the Pacific.
    expect(nearestCity(cities, 0, -150), isNull);
  });

  test('broken lines are skipped', () {
    expect(City.fromTsv('only\ttwo'), isNull);
    expect(City.fromTsv('A\tKZ\tx\ty\tAsia/Almaty\t1\t'), isNull);
    expect(parseCities('A\tKZ\t1.0\t2.0\tAsia/Almaty\t5\t\n\nbad\n').length, 1);
  });
}
