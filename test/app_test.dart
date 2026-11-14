import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:muslim_app/app.dart';
import 'package:muslim_app/core/prayer/prayer_calculator.dart';
import 'package:muslim_app/state/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

const _almaty = SavedPlace(
  name: 'Алматы',
  countryCode: 'KZ',
  latitude: 43.2525,
  longitude: 76.9115,
  timeZone: 'Asia/Almaty',
  fromGps: false,
);

Future<SharedPreferences> _prefs([AppSettings? settings]) async {
  SharedPreferences.setMockInitialValues({
    if (settings != null) 'settings.v1': jsonEncode(settings.toJson()),
  });
  return SharedPreferences.getInstance();
}

Future<void> _pump(WidgetTester tester, SharedPreferences prefs) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const MuslimApp(),
  ));
  await tester.pump();
}

void main() {
  setUpAll(tzdata.initializeTimeZones);

  test('settings survive a save and load', () {
    const original = AppSettings(
      languageCode: 'ar',
      themeMode: ThemeMode.dark,
      place: _almaty,
      method: CalcMethod.russia,
      madhab: AsrMadhab.hanafi,
      adjustments: {PrayerSlot.fajr: -2, PrayerSlot.isha: 4},
    );
    final restored = AppSettings.fromJson(
      jsonDecode(jsonEncode(original.toJson())) as Map<String, Object?>,
    );
    expect(restored.languageCode, 'ar');
    expect(restored.themeMode, ThemeMode.dark);
    expect(restored.place!.name, 'Алматы');
    expect(restored.place!.timeZone, 'Asia/Almaty');
    expect(restored.method, CalcMethod.russia);
    expect(restored.madhab, AsrMadhab.hanafi);
    expect(restored.adjustments,
        {PrayerSlot.fajr: -2, PrayerSlot.isha: 4});
  });

  test('unknown or damaged saved values fall back to defaults', () {
    final restored = AppSettings.fromJson({
      'method': 'noSuchMethod',
      'theme': 7,
      'place': {'lat': 'x'},
      'adj': {'fajr': 'two', 'bogus': 1},
    });
    expect(restored.method, CalcMethod.muslimWorldLeague);
    expect(restored.themeMode, ThemeMode.system);
    expect(restored.place, isNull);
    expect(restored.adjustments, isEmpty);
  });

  test('first place picks the country method, later ones keep the choice',
      () async {
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(await _prefs()),
    ]);
    addTearDown(container.dispose);
    final controller = container.read(settingsProvider.notifier);

    controller.setPlace(const SavedPlace(
      name: 'Kazan',
      countryCode: 'RU',
      latitude: 55.79,
      longitude: 49.12,
      timeZone: 'Europe/Moscow',
      fromGps: false,
    ));
    expect(container.read(settingsProvider).method, CalcMethod.russia);

    controller.setMethod(CalcMethod.karachi);
    controller.setPlace(_almaty);
    expect(container.read(settingsProvider).method, CalcMethod.karachi);
  });

  test('corrections are clamped', () async {
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(await _prefs()),
    ]);
    addTearDown(container.dispose);
    final controller = container.read(settingsProvider.notifier);
    controller.changeAdjustment(PrayerSlot.asr, 100);
    expect(container.read(settingsProvider).adjustments[PrayerSlot.asr], 30);
    controller.changeAdjustment(PrayerSlot.asr, -100);
    expect(container.read(settingsProvider).adjustments[PrayerSlot.asr], -30);
  });

  testWidgets('without a place the app asks to choose a city', (tester) async {
    await _pump(tester, await _prefs(const AppSettings(languageCode: 'ru')));
    expect(find.text('Выбрать город'), findsOneWidget);
    expect(find.text('Фаджр'), findsNothing);
  });

  testWidgets('with a place the timetable shows all prayers in Russian',
      (tester) async {
    await _pump(
      tester,
      await _prefs(const AppSettings(languageCode: 'ru', place: _almaty)),
    );
    expect(find.text('Алматы'), findsOneWidget);
    for (final name in ['Фаджр', 'Восход', 'Зухр', 'Аср', 'Магриб', 'Иша']) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
    expect(find.textContaining(RegExp(r'^\d\d:\d\d:\d\d$')), findsOneWidget);
  });

  testWidgets('Arabic lays the screen out right to left', (tester) async {
    await _pump(
      tester,
      await _prefs(const AppSettings(languageCode: 'ar', place: _almaty)),
    );
    final fajr = find.text('الفجر');
    expect(fajr, findsOneWidget);
    expect(Directionality.of(tester.element(fajr)), TextDirection.rtl);
    // The prayer name sits to the right of its time.
    final nameX = tester.getCenter(fajr).dx;
    final width = tester.getSize(find.byType(MaterialApp)).width;
    expect(nameX, greaterThan(width / 2));
  });

  testWidgets('settings open and switching language updates the screen',
      (tester) async {
    await _pump(
      tester,
      await _prefs(const AppSettings(languageCode: 'en', place: _almaty)),
    );
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(find.text('Настройки'), findsOneWidget);
  });
}
