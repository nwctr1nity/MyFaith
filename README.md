# MyFaith

Prayer times, adhan, qibla, Quran with translation and tafsir, daily hadith.
Works offline, no accounts, no subscriptions. Flutter, Android first.

Interface languages: Russian, English, Arabic (right to left).

## What works now

- Prayer times for a chosen city or the device location, computed on the
  device with [adhan_dart](https://pub.dev/packages/adhan_dart).
- 22 calculation methods, Shafi or Hanafi Asr, per-prayer corrections in
  minutes, automatic high-latitude rule.
- Offline search over 34,000 cities in English, Russian and Arabic.
- Countdown to the next prayer, last third of the night.

## Run

```sh
flutter pub get
flutter test
flutter run
```

## Layout

- `lib/core` — pure Dart: prayer time calculation, city search. No Flutter
  imports, covered by tests.
- `lib/state` — settings, saved with shared_preferences.
- `lib/features` — screens.
- `lib/l10n` — translations (`app_*.arb`); run `flutter gen-l10n` after edits.
- `tool/build_cities.py` — rebuilds `assets/cities.tsv` from GeoNames data.

## Data credits

City list: [GeoNames](https://www.geonames.org/), CC BY 4.0.
