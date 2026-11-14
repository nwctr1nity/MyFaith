import 'dart:math' as math;

/// A city from the bundled GeoNames list.
class City {
  const City({
    required this.name,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.timeZone,
    required this.population,
    this.altNames = const [],
  });

  /// English name.
  final String name;
  final String countryCode;
  final double latitude;
  final double longitude;
  final String timeZone;
  final int population;

  /// Names in Cyrillic and Arabic script, plus other Latin spellings for
  /// large cities, used for search.
  final List<String> altNames;

  /// Parses one line of `assets/cities.tsv`. Returns null for a broken line.
  static City? fromTsv(String line) {
    final parts = line.split('\t');
    if (parts.length < 6) return null;
    final lat = double.tryParse(parts[2]);
    final lng = double.tryParse(parts[3]);
    if (lat == null || lng == null) return null;
    return City(
      name: parts[0],
      countryCode: parts[1],
      latitude: lat,
      longitude: lng,
      timeZone: parts[4],
      population: int.tryParse(parts[5]) ?? 0,
      altNames: parts.length > 6 && parts[6].isNotEmpty
          ? parts[6].split('|')
          : const [],
    );
  }
}

/// A city found by a search, with the name that matched the query.
class CityMatch {
  const CityMatch(this.city, this.matchedName);

  final City city;

  /// The name to show: the alternate name the query matched, or the English
  /// name when the query matched that.
  final String matchedName;
}

List<City> parseCities(String tsv) {
  final cities = <City>[];
  for (final line in tsv.split('\n')) {
    if (line.isEmpty) continue;
    final city = City.fromTsv(line);
    if (city != null) cities.add(city);
  }
  return cities;
}

String _fold(String text) => text.toLowerCase().replaceAll('ё', 'е').trim();

/// Finds cities whose English or alternate name starts with [query], falling
/// back to names that contain it. [cities] must be sorted by population so the
/// largest matches come first.
List<CityMatch> searchCities(List<City> cities, String query, {int limit = 30}) {
  final q = _fold(query);
  if (q.isEmpty) return const [];
  final prefix = <CityMatch>[];
  final contains = <CityMatch>[];
  for (final city in cities) {
    CityMatch? asPrefix;
    CityMatch? asContains;
    final english = _fold(city.name);
    if (english.startsWith(q)) {
      asPrefix = CityMatch(city, city.name);
    } else if (english.contains(q)) {
      asContains = CityMatch(city, city.name);
    }
    if (asPrefix == null) {
      for (final alt in city.altNames) {
        final folded = _fold(alt);
        if (folded.startsWith(q)) {
          asPrefix = CityMatch(city, alt);
          break;
        }
        if (asContains == null && folded.contains(q)) {
          asContains = CityMatch(city, alt);
        }
      }
    }
    if (asPrefix != null) {
      prefix.add(asPrefix);
      if (prefix.length >= limit) break;
    } else if (asContains != null && contains.length < limit) {
      contains.add(asContains);
    }
  }
  return [...prefix, ...contains].take(limit).toList();
}

/// Great-circle distance in kilometres.
double distanceKm(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusKm = 6371.0;
  double rad(double deg) => deg * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(rad(lat1)) *
          math.cos(rad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return 2 * earthRadiusKm * math.asin(math.min(1, math.sqrt(a)));
}

/// The closest listed city within [maxKm], or null when none is that close.
City? nearestCity(
  List<City> cities,
  double latitude,
  double longitude, {
  double maxKm = 60,
}) {
  City? best;
  var bestKm = maxKm;
  for (final city in cities) {
    if ((city.latitude - latitude).abs() > 1) continue;
    final km = distanceKm(latitude, longitude, city.latitude, city.longitude);
    if (km < bestKm) {
      bestKm = km;
      best = city;
    }
  }
  return best;
}
