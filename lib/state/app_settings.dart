import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class AppSettings {
  const AppSettings({
    this.languageCode,
    this.themeMode = ThemeMode.system,
    this.place,
    this.method = CalcMethod.muslimWorldLeague,
    this.madhab = AsrMadhab.shafi,
    this.adjustments = const {},
  });

  /// Null follows the device language.
  final String? languageCode;
  final ThemeMode themeMode;
  final SavedPlace? place;
  final CalcMethod method;
  final AsrMadhab madhab;
  final Map<PrayerSlot, int> adjustments;

  PrayerSettings get prayerSettings => PrayerSettings(
        method: method,
        madhab: madhab,
        adjustments: adjustments,
      );

  Map<String, Object?> toJson() => {
        'lang': languageCode,
        'theme': themeMode.name,
        'place': place?.toJson(),
        'method': method.name,
        'madhab': madhab.name,
        'adj': {
          for (final e in adjustments.entries)
            if (e.value != 0) e.key.name: e.value,
        },
      };

  static AppSettings fromJson(Map<String, Object?> json) {
    T? byName<T extends Enum>(List<T> values, Object? name) {
      for (final v in values) {
        if (v.name == name) return v;
      }
      return null;
    }

    final adjustments = <PrayerSlot, int>{};
    final rawAdj = json['adj'];
    if (rawAdj is Map) {
      for (final e in rawAdj.entries) {
        final slot = byName(PrayerSlot.values, e.key);
        final value = e.value;
        if (slot != null && value is int) adjustments[slot] = value;
      }
    }
    return AppSettings(
      languageCode: json['lang'] as String?,
      themeMode: byName(ThemeMode.values, json['theme']) ?? ThemeMode.system,
      place: SavedPlace.fromJson(json['place']),
      method:
          byName(CalcMethod.values, json['method']) ?? CalcMethod.muslimWorldLeague,
      madhab: byName(AsrMadhab.values, json['madhab']) ?? AsrMadhab.shafi,
      adjustments: adjustments,
    );
  }
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

  AppSettings _copy({
    String? Function()? languageCode,
    ThemeMode? themeMode,
    SavedPlace? place,
    CalcMethod? method,
    AsrMadhab? madhab,
    Map<PrayerSlot, int>? adjustments,
  }) {
    return AppSettings(
      languageCode: languageCode != null ? languageCode() : state.languageCode,
      themeMode: themeMode ?? state.themeMode,
      place: place ?? state.place,
      method: method ?? state.method,
      madhab: madhab ?? state.madhab,
      adjustments: adjustments ?? state.adjustments,
    );
  }

  void setLanguage(String? code) => _set(_copy(languageCode: () => code));

  void setThemeMode(ThemeMode mode) => _set(_copy(themeMode: mode));

  void setMethod(CalcMethod method) => _set(_copy(method: method));

  void setMadhab(AsrMadhab madhab) => _set(_copy(madhab: madhab));

  /// Saves the place. The first place ever chosen also picks the calculation
  /// method usual for its country; later changes leave the method alone.
  void setPlace(SavedPlace place) {
    final isFirst = state.place == null;
    _set(_copy(
      place: place,
      method: isFirst ? defaultMethodForCountry(place.countryCode) : null,
    ));
  }

  void changeAdjustment(PrayerSlot slot, int delta) {
    final current = state.adjustments[slot] ?? 0;
    final next = (current + delta)
        .clamp(-maxAdjustmentMinutes, maxAdjustmentMinutes)
        .toInt();
    _set(_copy(adjustments: {...state.adjustments, slot: next}));
  }
}
