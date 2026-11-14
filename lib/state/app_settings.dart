import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/alarms/alarm_settings.dart';
import '../core/prayer/prayer_calculator.dart';

/// The place prayer times are shown for.
class SavedPlace {
  const SavedPlace({
    required this.name,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.timeZone,
    required this.fromGps,
  });

  final String name;
  final String countryCode;
  final double latitude;
  final double longitude;
  final String timeZone;

  /// True when the place came from the device location, not a chosen city.
  final bool fromGps;

  PrayerPlace get prayerPlace => PrayerPlace(
        latitude: latitude,
        longitude: longitude,
        timeZone: timeZone,
      );

  Map<String, Object?> toJson() => {
        'name': name,
        'cc': countryCode,
        'lat': latitude,
        'lng': longitude,
        'tz': timeZone,
        'gps': fromGps,
      };

  static SavedPlace? fromJson(Object? json) {
    if (json is! Map) return null;
    final lat = json['lat'];
    final lng = json['lng'];
    final tz = json['tz'];
    if (lat is! num || lng is! num || tz is! String) return null;
    return SavedPlace(
      name: json['name'] as String? ?? '',
      countryCode: json['cc'] as String? ?? '',
      latitude: lat.toDouble(),
      longitude: lng.toDouble(),
      timeZone: tz,
      fromGps: json['gps'] == true,
    );
  }
}

/// A verse reference, used for bookmarks and the reading position.
class AyahRef {
  const AyahRef(this.surah, this.ayah);

  final int surah;
  final int ayah;

  String get key => '$surah:$ayah';

  static AyahRef? parse(Object? value) {
    if (value is! String) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final s = int.tryParse(parts[0]);
    final a = int.tryParse(parts[1]);
    if (s == null || a == null || s < 1 || s > 114 || a < 1) return null;
    return AyahRef(s, a);
  }

  @override
  bool operator ==(Object other) =>
      other is AyahRef && other.surah == surah && other.ayah == ayah;

  @override
  int get hashCode => Object.hash(surah, ayah);
}

/// All user settings. Stored as one JSON object; every getter tolerates a
/// missing or malformed value and falls back to its default, so a settings
/// blob written by an older or newer version never breaks the app.
class AppSettings {
  const AppSettings([this._data = const {}]);

  /// Convenience constructor for the core fields.
  factory AppSettings.of({
    String? languageCode,
    ThemeMode themeMode = ThemeMode.system,
    SavedPlace? place,
    CalcMethod method = CalcMethod.muslimWorldLeague,
    AsrMadhab madhab = AsrMadhab.shafi,
    Map<PrayerSlot, int> adjustments = const {},
  }) {
    return AppSettings({
      'lang': languageCode,
      'theme': themeMode.name,
      'place': place?.toJson(),
      'method': method.name,
      'madhab': madhab.name,
      'adj': {for (final e in adjustments.entries) e.key.name: e.value},
    });
  }

  final Map<String, Object?> _data;

  Map<String, Object?> toJson() => _data;

  static AppSettings fromJson(Map<String, Object?> json) => AppSettings(json);

  AppSettings withValue(String key, Object? value) =>
      AppSettings({..._data, key: value});

  static T? _byName<T extends Enum>(List<T> values, Object? name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }

  bool _bool(String key, bool fallback) {
    final v = _data[key];
    return v is bool ? v : fallback;
  }

  int _int(String key, int fallback, {int? min, int? max}) {
    final v = _data[key];
    if (v is! int) return fallback;
    if (min != null && v < min) return fallback;
    if (max != null && v > max) return fallback;
    return v;
  }

  // Appearance and place.

  /// Null follows the device language.
  String? get languageCode {
    final v = _data['lang'];
    return v is String && const ['ru', 'en', 'ar'].contains(v) ? v : null;
  }

  ThemeMode get themeMode =>
      _byName(ThemeMode.values, _data['theme']) ?? ThemeMode.system;

  SavedPlace? get place => SavedPlace.fromJson(_data['place']);

  // Calculation.

  CalcMethod get method =>
      _byName(CalcMethod.values, _data['method']) ?? CalcMethod.muslimWorldLeague;

  AsrMadhab get madhab =>
      _byName(AsrMadhab.values, _data['madhab']) ?? AsrMadhab.shafi;

  Map<PrayerSlot, int> get adjustments {
    final result = <PrayerSlot, int>{};
    final raw = _data['adj'];
    if (raw is Map) {
      for (final e in raw.entries) {
        final slot = _byName(PrayerSlot.values, e.key);
        final value = e.value;
        if (slot != null && value is int && value != 0) result[slot] = value;
      }
    }
    return result;
  }

  PrayerSettings get prayerSettings => PrayerSettings(
        method: method,
        madhab: madhab,
        adjustments: adjustments,
      );

  /// Shift of the Hijri date in days, to follow the local moon sighting.
  int get hijriAdjustment => _int('hijriAdj', 0, min: -2, max: 2);

  // Notifications and alarms.

  /// Prayers that get an adhan notification. Sunrise is off by default.
  Set<PrayerSlot> get adhanSlots {
    final raw = _data['adhan'];
    if (raw is! List) {
      return {
        for (final s in PrayerSlot.values)
          if (s != PrayerSlot.sunrise) s,
      };
    }
    return {
      for (final name in raw)
        ?_byName(PrayerSlot.values, name),
    };
  }

  /// Minutes before each prayer for an extra reminder; 0 turns it off.
  int get reminderMinutes => _int('remind', 0, min: 0, max: 60);

  bool get hadithNotification => _bool('hadithNotify', true);

  /// Local hour of the daily hadith notification.
  int get hadithHour => _int('hadithHour', 9, min: 0, max: 23);

  bool get suhoorEnabled => _bool('suhoor', false);
  int get suhoorMinutesBeforeFajr => _int('suhoorMin', 60, min: 10, max: 180);
  bool get suhoorInRamadan => _bool('suhoorRamadan', true);
  bool get suhoorMonThu => _bool('suhoorMonThu', false);
  bool get suhoorWhiteDays => _bool('suhoorWhite', false);
  bool get suhoorEveryDay => _bool('suhoorDaily', false);

  /// Minutes before Fajr for the "stop eating" warning; 0 turns it off.
  int get suhoorStopWarningMinutes => _int('suhoorStop', 10, min: 0, max: 30);

  bool get tahajjudEnabled => _bool('tahajjud', false);

  /// True wakes at the start of the last third of the night; false wakes a
  /// fixed number of minutes before Fajr.
  bool get tahajjudAtLastThird => _bool('tahajjudThird', true);
  int get tahajjudMinutesBeforeFajr => _int('tahajjudMin', 45, min: 10, max: 180);

  /// ISO weekdays (1 = Monday) of the night's morning the alarm rings on.
  Set<int> get tahajjudWeekdays {
    final raw = _data['tahajjudDays'];
    if (raw is! List) return {1, 2, 3, 4, 5, 6, 7};
    return {
      for (final d in raw)
        if (d is int && d >= 1 && d <= 7) d,
    };
  }

  AlarmSettings get alarmSettings => AlarmSettings(
        adhanSlots: adhanSlots,
        reminderMinutes: reminderMinutes,
        hadithNotification: hadithNotification,
        hadithHour: hadithHour,
        suhoorEnabled: suhoorEnabled,
        suhoorMinutesBeforeFajr: suhoorMinutesBeforeFajr,
        suhoorInRamadan: suhoorInRamadan,
        suhoorMonThu: suhoorMonThu,
        suhoorWhiteDays: suhoorWhiteDays,
        suhoorEveryDay: suhoorEveryDay,
        suhoorStopWarningMinutes: suhoorStopWarningMinutes,
        tahajjudEnabled: tahajjudEnabled,
        tahajjudAtLastThird: tahajjudAtLastThird,
        tahajjudMinutesBeforeFajr: tahajjudMinutesBeforeFajr,
        tahajjudWeekdays: tahajjudWeekdays,
        hijriAdjustment: hijriAdjustment,
      );

  // Quran reader.

  bool get quranShowTranslation => _bool('qTrans', true);

  /// Arabic text size step, 0 to 4.
  int get quranFontStep => _int('qFont', 1, min: 0, max: 4);

  AyahRef? get lastRead => AyahRef.parse(_data['qLast']);

  List<AyahRef> get bookmarks {
    final raw = _data['qMarks'];
    if (raw is! List) return const [];
    return [
      for (final v in raw)
        ?AyahRef.parse(v),
    ];
  }

  // Salawat.

  /// Lifetime count of salawat.
  int get salawatTotal => _int('salTotal', 0, min: 0);

  /// Count for the day [salawatDay] (yyyy-mm-dd).
  int get salawatToday => _int('salToday', 0, min: 0);

  String get salawatDay {
    final v = _data['salDay'];
    return v is String ? v : '';
  }

  /// Daily goal for the counter.
  int get salawatGoal => _int('salGoal', 100, min: 1, max: 100000);
}

/// Overridden in `main` with the instance loaded before the first frame.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  static const _key = 'settings.v1';

  /// Corrections outside this range are almost certainly a mistake.
  static const maxAdjustmentMinutes = 30;

  @override
  AppSettings build() {
    final raw = ref.read(sharedPreferencesProvider).getString(_key);
    if (raw == null) return const AppSettings();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, Object?>) return AppSettings.fromJson(decoded);
    } on FormatException {
      // A damaged settings blob falls back to defaults.
    }
    return const AppSettings();
  }

  void _set(AppSettings next) {
    state = next;
    ref.read(sharedPreferencesProvider).setString(_key, jsonEncode(next.toJson()));
  }

  /// Sets one raw value. Keys are the ones the [AppSettings] getters read.
  void setValue(String key, Object? value) => _set(state.withValue(key, value));

  void setLanguage(String? code) => setValue('lang', code);

  void setThemeMode(ThemeMode mode) => setValue('theme', mode.name);

  void setMethod(CalcMethod method) => setValue('method', method.name);

  void setMadhab(AsrMadhab madhab) => setValue('madhab', madhab.name);

  /// Saves the place. The first place ever chosen also picks the calculation
  /// method usual for its country; later changes leave the method alone.
  void setPlace(SavedPlace place) {
    final isFirst = state.place == null;
    var next = state.withValue('place', place.toJson());
    if (isFirst) {
      next = next.withValue(
        'method',
        defaultMethodForCountry(place.countryCode).name,
      );
    }
    _set(next);
  }

  void changeAdjustment(PrayerSlot slot, int delta) {
    final current = state.adjustments[slot] ?? 0;
    final next = (current + delta)
        .clamp(-maxAdjustmentMinutes, maxAdjustmentMinutes)
        .toInt();
    setValue('adj', {
      for (final e in {...state.adjustments, slot: next}.entries)
        e.key.name: e.value,
    });
  }

  void toggleAdhan(PrayerSlot slot, bool enabled) {
    final slots = {...state.adhanSlots};
    enabled ? slots.add(slot) : slots.remove(slot);
    setValue('adhan', [for (final s in slots) s.name]);
  }

  void toggleTahajjudWeekday(int weekday, bool enabled) {
    final days = {...state.tahajjudWeekdays};
    enabled ? days.add(weekday) : days.remove(weekday);
    setValue('tahajjudDays', days.toList()..sort());
  }

  void setLastRead(AyahRef ref) => setValue('qLast', ref.key);

  void toggleBookmark(AyahRef ref) {
    final marks = [...state.bookmarks];
    marks.contains(ref) ? marks.remove(ref) : marks.insert(0, ref);
    setValue('qMarks', [for (final m in marks) m.key]);
  }

  /// Adds one salawat to today's and the lifetime count. [today] is the
  /// local date as yyyy-mm-dd; a new day starts today's count from zero.
  void addSalawat(String today) {
    final sameDay = state.salawatDay == today;
    _set(state
        .withValue('salDay', today)
        .withValue('salToday', (sameDay ? state.salawatToday : 0) + 1)
        .withValue('salTotal', state.salawatTotal + 1));
  }

  void resetSalawatToday(String today) {
    _set(state.withValue('salDay', today).withValue('salToday', 0));
  }
}
