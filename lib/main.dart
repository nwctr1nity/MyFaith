import 'package:material_ui/material_ui.dart';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import 'app.dart';
import 'state/app_settings.dart';
import 'state/notification_sync.dart' show notificationStrings;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  final prefs = await SharedPreferences.getInstance();
  await _startBackgroundAudio(prefs);
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MuslimApp(),
    ),
  );
}

/// Keeps the Quran playing with the screen off or the app in the
/// background, with play and pause on the lock screen.
Future<void> _startBackgroundAudio(SharedPreferences prefs) async {
  String? language;
  try {
    final settings = jsonDecode(prefs.getString('settings.v1') ?? '{}');
    if (settings is Map) language = settings['lang'] as String?;
  } on FormatException {
    // Damaged settings: the device language is used.
  }
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'app.myfaith.quran',
      androidNotificationChannelName:
          notificationStrings(language).channelQuran,
      androidNotificationIcon: 'drawable/ic_notification',
      // The service stays in the foreground between two ayahs, so Android
      // does not stop the app while the next recording loads.
      androidStopForegroundOnPause: false,
    );
  } on Object {
    // Without the service the Quran still plays while the app is open.
  }
}
