import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:muslim_app/app.dart';
import 'package:muslim_app/core/prayer/prayer_calculator.dart';
import 'package:muslim_app/features/qibla/qibla_screen.dart';
import 'package:muslim_app/services/notification_service.dart';
import 'package:muslim_app/state/app_settings.dart';
import 'package:muslim_app/services/update_service.dart';
import 'package:muslim_app/state/notification_sync.dart';
import 'package:muslim_app/state/update_provider.dart';
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

class FakeNotifications implements NotificationService {
  List<NotificationRequest> scheduled = const [];
  final extra = <NotificationRequest>[];

  @override
  Future<void> init() async {}

  @override
  Future<NotificationPermissions> permissions() async =>
      NotificationPermissions(notifications: granted, exactAlarms: false);

  @override
  Future<void> requestNotifications() async {
    asked++;
  }

  @override
  Future<void> requestExactAlarms() async {}

  @override
  Future<void> replaceAll(
    List<NotificationRequest> requests,
    ChannelNames names, {
    WidgetData widget = const WidgetData(),
  }) async {
    scheduled = requests;
    this.widget = widget;
  }

  WidgetData widget = const WidgetData();

  @override
  Future<void> showNow(NotificationRequest request, ChannelNames names) async {
    extra.add(request);
  }

  @override
  Future<int> pendingCount() async => scheduled.length;

  bool granted = true;
  int asked = 0;
}

class FakeUpdates implements UpdateService {
  FakeUpdates(this.update);

  final AppUpdate? update;

  @override
  Future<String> installedVersion() async => '1.1.0';

  @override
  Future<AppUpdate?> check() async => update;
}

Future<SharedPreferences> _prefs([AppSettings? settings]) async {
  SharedPreferences.setMockInitialValues({
    if (settings != null) 'settings.v1': jsonEncode(settings.toJson()),
  });
  return SharedPreferences.getInstance();
}

Future<void> _pump(
  WidgetTester tester,
  SharedPreferences prefs, {
  FakeNotifications? notifications,
  AppUpdate? update,
}) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      notificationServiceProvider
          .overrideWithValue(notifications ?? FakeNotifications()),
      compassProvider.overrideWithValue(
          () => Stream.value((heading: 40.0, accuracy: 15.0))),
      updateServiceProvider.overrideWithValue(FakeUpdates(update)),
    ],
    child: const MuslimApp(),
  ));
  await tester.pump();
}

void main() {
  setUpAll(tzdata.initializeTimeZones);

  test('settings survive a save and load', () {
    final original = AppSettings.of(
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
    await _pump(tester, await _prefs(AppSettings.of(languageCode: 'ru')));
    expect(find.text('Выбрать город'), findsOneWidget);
    expect(find.text('Фаджр'), findsNothing);
  });

  testWidgets('with a place the timetable shows all prayers in Russian',
      (tester) async {
    await _pump(
      tester,
      await _prefs(AppSettings.of(languageCode: 'ru', place: _almaty)),
    );
    expect(find.text('Алматы'), findsOneWidget);
    for (final name in ['Фаджр', 'Восход', 'Зухр', 'Аср', 'Магриб', 'Иша']) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
    expect(find.textContaining(RegExp(r'^\d\d:\d\d:\d\d$')), findsOneWidget);
  });

  testWidgets('a newer version is offered and can be skipped', (tester) async {
    final prefs =
        await _prefs(AppSettings.of(languageCode: 'ru', place: _almaty));
    await _pump(
      tester,
      prefs,
      update: const AppUpdate(version: '1.2.0', url: 'https://example.com/a'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Вышла версия 1.2.0'), findsOneWidget);

    await tester.tap(find.text('Пропустить'));
    await tester.pumpAndSettle();
    expect(find.text('Вышла версия 1.2.0'), findsNothing);
  });

  test('versions compare by number, and a release yields its APK', () {
    expect(compareVersions('v1.10.0', '1.9.3'), greaterThan(0));
    expect(compareVersions('1.1.0', '1.1.0+2'), 0);
    expect(compareVersions('v1.0.9', '1.1.0'), lessThan(0));
    final release = {
      'tag_name': 'v1.2.0',
      'html_url': 'https://github.com/x/releases/tag/v1.2.0',
      'assets': [
        {'name': 'notes.txt', 'browser_download_url': 'https://x/notes.txt'},
        {'name': 'myfaith.apk', 'browser_download_url': 'https://x/myfaith.apk'},
      ],
    };
    expect(updateFromRelease(release, '1.1.0')!.url, 'https://x/myfaith.apk');
    expect(updateFromRelease(release, '1.1.0')!.version, '1.2.0');
    expect(updateFromRelease(release, '1.2.0'), isNull);
  });

  testWidgets('Arabic lays the screen out right to left', (tester) async {
    await _pump(
      tester,
      await _prefs(AppSettings.of(languageCode: 'ar', place: _almaty)),
    );
    final fajr = find.text('الفجر');
    expect(fajr, findsOneWidget);
    expect(Directionality.of(tester.element(fajr)), TextDirection.rtl);
    // The prayer name sits to the right of its time.
    final nameX = tester.getCenter(fajr).dx;
    final width = tester.getSize(find.byType(MaterialApp)).width;
    expect(nameX, greaterThan(width / 2));
  });

  testWidgets('settings open from More and switching language applies',
      (tester) async {
    await _pump(
      tester,
      await _prefs(AppSettings.of(languageCode: 'en', place: _almaty)),
    );
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(find.text('Настройки'), findsOneWidget);
  });

  testWidgets('the app asks for notifications on launch when not granted',
      (tester) async {
    final denied = FakeNotifications()..granted = false;
    await _pump(tester, await _prefs(), notifications: denied);
    await tester.pump();
    expect(denied.asked, 1);

    final allowed = FakeNotifications();
    await _pump(tester, await _prefs(), notifications: allowed);
    await tester.pump();
    expect(allowed.asked, 0);
  });

  test('Asr follows the Hanafi school unless another is chosen', () {
    expect(const AppSettings().madhab, AsrMadhab.hanafi);
    expect(
      const AppSettings().withValue('madhab', 'shafi').madhab,
      AsrMadhab.shafi,
    );
  });

  testWidgets('the bell on a prayer row turns its adhan off', (tester) async {
    final prefs =
        await _prefs(AppSettings.of(languageCode: 'en', place: _almaty));
    await _pump(tester, prefs);
    expect(find.byIcon(Icons.notifications_active), findsNWidgets(5));
    await tester.tap(find.byIcon(Icons.notifications_active).first);
    await tester.pump();
    expect(find.byIcon(Icons.notifications_active), findsNWidgets(4));
    final saved = AppSettings.fromJson(
      jsonDecode(prefs.getString('settings.v1')!) as Map<String, Object?>,
    );
    expect(saved.adhanSlots.contains(PrayerSlot.fajr), isFalse);
    expect(saved.adhanSlots.contains(PrayerSlot.isha), isTrue);
  });

  testWidgets('qibla tab shows the bearing and a turn hint', (tester) async {
    await _pump(
      tester,
      await _prefs(AppSettings.of(languageCode: 'en', place: _almaty)),
    );
    await tester.tap(find.text('Qibla'));
    await tester.pumpAndSettle();
    // Almaty is north-east of Mecca, so the qibla is to the south-west.
    final direction = tester.widget<Text>(find.textContaining('° from north'));
    final degrees = int.parse(RegExp(r'\d+').firstMatch(direction.data!)![0]!);
    expect(degrees, inInclusiveRange(235, 255));
    // The fake compass points at 40°, so the shorter way round is to the left.
    expect(find.textContaining('Turn left by 15'), findsOneWidget);
  });

  testWidgets('tapping the salawat counter counts and saves', (tester) async {
    final prefs =
        await _prefs(AppSettings.of(languageCode: 'en', place: _almaty));
    await _pump(tester, prefs);
    await tester.tap(find.text('Salawat'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.text('0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    final saved = AppSettings.fromJson(
      jsonDecode(prefs.getString('settings.v1')!) as Map<String, Object?>,
    );
    expect(saved.salawatTotal, 2);
  });

  testWidgets('alarms screen offers suhoor and tahajjud', (tester) async {
    await _pump(
      tester,
      await _prefs(AppSettings.of(languageCode: 'en', place: _almaty)),
    );
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suhoor and tahajjud alarms'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Next alarm'), findsOneWidget);
    expect(find.byType(FilterChip), findsNWidgets(7));
  });

  test('sync schedules adhans for the place and a test notification',
      () async {
    final fake = FakeNotifications();
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(
        await _prefs(AppSettings.of(languageCode: 'ru', place: _almaty)
            .withValue('hadithNotify', false)),
      ),
      notificationServiceProvider.overrideWithValue(fake),
    ]);
    addTearDown(container.dispose);
    final sync = container.read(notificationSyncProvider);
    await sync.syncNow(now: DateTime.utc(2026, 11, 14, 0));
    // Five prayers a day for ten days, plus the reminder to open the app.
    expect(fake.scheduled, hasLength(51));
    expect(fake.scheduled.first.title, contains('Фаджр'));
    expect(fake.scheduled.first.body, contains('Алматы'));
    final ids = {for (final r in fake.scheduled) r.id};
    expect(ids, hasLength(fake.scheduled.length));

    // Fajr has its own recording, the other prayers share one.
    final channels = {
      for (final r in fake.scheduled.take(5)) r.channel,
    };
    expect(channels,
        {NotificationChannel.adhanFajr, NotificationChannel.adhan});
    expect(
      fake.scheduled.where((r) => r.channel == NotificationChannel.adhanFajr),
      hasLength(10),
    );
    expect(sync.status.value!.pending, 51);

    // The widgets get every prayer of the next ten days, in order.
    final prayers = fake.widget.prayers;
    expect(fake.widget.city, 'Алматы');
    expect(prayers, hasLength(60));
    expect(prayers.first.name, 'Фаджр');
    expect(prayers.first.clock, matches(RegExp(r'^0\d:\d\d$')));
    expect(prayers.take(6).map((p) => p.slot), [0, 1, 2, 3, 4, 5]);
    expect({for (final p in prayers.take(6)) p.day}, hasLength(1));
    for (var i = 1; i < prayers.length; i++) {
      expect(prayers[i].time.isAfter(prayers[i - 1].time), isTrue);
    }

    await sync.playTest(fajr: true);
    expect(fake.extra.single.channel, NotificationChannel.adhanFajr);
  });
}
