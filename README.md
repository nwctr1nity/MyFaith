# MyFaith

Prayer times, adhan, qibla, Quran with translation and tafsir, daily hadith.
Works offline, no accounts, no subscriptions. Flutter, Android first.

Interface languages: Russian, English, Arabic (right to left).

## What works now

- Prayer times for a chosen city or the device location, computed on the
  device with [adhan_dart](https://pub.dev/packages/adhan_dart). 22
  calculation methods, Shafi or Hanafi Asr, per-prayer corrections in
  minutes, automatic high-latitude rule.
- Offline search over 34,000 cities in English, Russian and Arabic.
- Adhan notification for each prayer (switched per prayer), an optional
  reminder before the prayer, a daily hadith notification.
- Suhoor alarm tied to Fajr (Ramadan, Mondays and Thursdays, the white days
  or every day) with a "stop eating" warning, and a tahajjud alarm at the
  start of the last third of the night or a fixed time before Fajr.
- Quran reader: Uthmani Arabic text, Russian and English translations,
  Al-Mukhtasar tafsir in three languages, bookmarks, reading position.
- Hadith of the day from Sahih al-Bukhari, Arabic with translation.
- Qibla compass, salawat with a daily counter, Hijri date.

Notifications are scheduled ten days ahead and renewed every time the app is
opened. The adhan currently plays the phone's notification sound; to ship a
recorded adhan, put an audio file in `android/app/src/main/res/raw` and point
the adhan channel in `lib/services/notification_service.dart` at it.

## Run

```sh
flutter pub get
flutter test
flutter run
```

## Layout

- `lib/core` — pure Dart: prayer times, notification planner, Hijri dates,
  qibla, city search, content models. No Flutter imports, covered by tests.
- `lib/services` — the notification plugin behind an interface.
- `lib/state` — settings (shared_preferences), content loading, the sync that
  turns settings into scheduled notifications.
- `lib/features` — screens.
- `lib/l10n` — translations (`app_*.arb`); run `flutter gen-l10n` after edits.
- `tool/build_cities.py` — rebuilds `assets/cities.tsv` from GeoNames data.
- `tool/build_content.py` — rebuilds the Quran, tafsir and hadith assets and
  the Arabic font from their sources.

## Data credits

City list: [GeoNames](https://www.geonames.org/), CC BY 4.0.

Quran text: King Fahd Complex Uthmani script, Hafs. Translations: Elmir
Kuliev (Russian), Saheeh International (English). Tafsir: Al-Mukhtasar,
Tafsir Center for Quranic Studies. Hadith: Sahih al-Bukhari, English by Muhsin
Khan, Russian by Abdulla Nirsha. Data taken from the open
[quran-api](https://github.com/fawazahmed0/quran-api),
[hadith-api](https://github.com/fawazahmed0/hadith-api) and
[tafsir_api](https://github.com/spa5k/tafsir_api) projects. The translations
belong to their authors and are bundled for personal, non-commercial reading.
Arabic font: [Amiri Quran](https://github.com/aliftype/amiri), SIL Open Font
License.

## Signing

CI signs the APK with the key from the `KEYSTORE_BASE64` and
`KEYSTORE_PASSWORD` repository secrets (key alias `myfaith`). Without them it
generates a key once and keeps it in the Actions cache, so later builds from
the same branch install over earlier ones.
