import 'dart:async';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/foundation.dart' show ValueNotifier;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:timezone/timezone.dart' as tz;

import '../core/alarms/notification_planner.dart';
import '../core/content/hadith.dart';
import '../core/prayer/prayer_calculator.dart';
import '../features/labels.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import 'app_settings.dart';
import 'content_providers.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => LocalNotificationService(),
);

/// The language notifications are written in: the chosen one, else the
/// device language when supported, else English.
AppLocalizations notificationStrings(String? languageCode) {
  var code = languageCode ?? PlatformDispatcher.instance.locale.languageCode;
  if (!const ['ru', 'en', 'ar'].contains(code)) code = 'en';
  return lookupAppLocalizations(Locale(code));
}

String _clip(String text, int max) =>
    text.length <= max ? text : '${text.substring(0, max - 1).trimRight()}…';

/// Turns a plan into localized notification requests.
List<NotificationRequest> buildRequests({
  required List<PlannedNotification> plan,
  required AppLocalizations l,
  required String cityName,
  required List<Hadith> hadiths,
}) {
  final clock = DateFormat.Hm(l.localeName);
  String at(DateTime t) =>
      clock.format(DateTime(t.year, t.month, t.day, t.hour, t.minute));

  final requests = <NotificationRequest>[];
  for (final p in plan) {
    switch (p.kind) {
      case PlannedKind.adhan:
        final slot = p.slot!;
        requests.add(NotificationRequest(
          id: p.id,
          time: p.time,
          channel: switch (slot) {
            PrayerSlot.sunrise => NotificationChannel.reminder,
            PrayerSlot.fajr => NotificationChannel.adhanFajr,
            _ => NotificationChannel.adhan,
          },
          title: slot == PrayerSlot.sunrise
              ? l.notifSunriseTitle
              : l.notifAdhanTitle(prayerName(l, slot)),
          body: l.notifAdhanBody(at(p.time), cityName),
        ));
      case PlannedKind.reminder:
        final minutes = p.prayerTime!.difference(p.time).inMinutes;
        requests.add(NotificationRequest(
          id: p.id,
          time: p.time,
          channel: NotificationChannel.reminder,
          title: l.notifReminderTitle(prayerName(l, p.slot!), minutes),
          body: l.notifAdhanBody(at(p.prayerTime!), cityName),
        ));
      case PlannedKind.hadith:
        if (hadiths.isEmpty) continue;
        final day = dayNumber(p.time.year, p.time.month, p.time.day);
        final hadith = hadiths[dailyHadithIndex(day, hadiths.length)];
        requests.add(NotificationRequest(
          id: p.id,
          time: p.time,
          channel: NotificationChannel.hadith,
          title: l.hadithOfDay,
          body: _clip(hadith.translation(l.localeName), 400),
        ));
      case PlannedKind.suhoor:
        requests.add(NotificationRequest(
          id: p.id,
          time: p.time,
          channel: NotificationChannel.alarm,
          title: l.notifSuhoorTitle,
          body: l.notifSuhoorBody(at(p.prayerTime!)),
        ));
      case PlannedKind.suhoorStop:
        requests.add(NotificationRequest(
          id: p.id,
          time: p.time,
          channel: NotificationChannel.reminder,
          title: l.notifSuhoorStopTitle,
          body: l.notifSuhoorBody(at(p.prayerTime!)),
        ));
      case PlannedKind.tahajjud:
        requests.add(NotificationRequest(
          id: p.id,
          time: p.time,
          channel: NotificationChannel.alarm,
          title: l.notifTahajjudTitle,
          body: l.notifSuhoorBody(at(p.prayerTime!)),
        ));
      case PlannedKind.refresh:
        requests.add(NotificationRequest(
          id: p.id,
          time: p.time,
          channel: NotificationChannel.reminder,
          title: l.notifRefreshTitle,
          body: l.notifRefreshBody,
        ));
    }
  }
  return requests;
}

/// Keeps the scheduled notifications in step with the settings. Watching
/// this provider is enough: it replans shortly after any settings change.
final notificationSyncProvider = Provider<NotificationSync>((ref) {
  final sync = NotificationSync(ref);
  ref.listen(settingsProvider, (_, _) => sync.schedule());
  ref.onDispose(sync.dispose);
  return sync;
});

class SyncStatus {
  const SyncStatus({this.pending, this.error});

  final int? pending;
  final String? error;
}

/// Outside every range the planner uses.
const testNotificationId = 9900;

class NotificationSync {
  NotificationSync(this._ref);

  final Ref _ref;
  Timer? _debounce;

  /// Replans after a short pause, so a burst of setting changes (holding a
  /// stepper button) causes one replanning.
  void schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      unawaited(syncNow());
    });
  }

  void dispose() {
    _debounce?.cancel();
    status.dispose();
  }

  ChannelNames _names(AppLocalizations l) => ChannelNames(
        adhan: l.channelAdhan,
        adhanFajr: l.channelAdhanFajr,
        reminder: l.channelReminder,
        alarm: l.channelAlarm,
        hadith: l.channelHadith,
      );

  /// Plays a sample adhan notification right away, so the sound and the
  /// permissions can be checked without waiting for a prayer.
  Future<void> playTest({bool fajr = false}) async {
    final settings = _ref.read(settingsProvider);
    final l = notificationStrings(settings.languageCode);
    final now = DateTime.now();
    await _ref.read(notificationServiceProvider).showNow(
          NotificationRequest(
            id: testNotificationId,
            time: tz.TZDateTime.from(now, tz.UTC),
            channel: fajr
                ? NotificationChannel.adhanFajr
                : NotificationChannel.adhan,
            title: l.notifAdhanTitle(fajr ? l.prayerFajr : l.prayerDhuhr),
            body: l.notifAdhanBody(
              DateFormat.Hm(l.localeName).format(now),
              settings.place?.name ?? l.appTitle,
            ),
          ),
          _names(l),
        );
  }

  /// What happened on the last replanning, for the notifications screen:
  /// the number of notifications waiting, or the error text.
  final status = ValueNotifier<SyncStatus?>(null);

  Future<void> syncNow({DateTime? now}) async {
    final settings = _ref.read(settingsProvider);
    final place = settings.place;
    final service = _ref.read(notificationServiceProvider);
    final l = notificationStrings(settings.languageCode);
    final names = _names(l);
    try {
      if (place == null) {
        await service.replaceAll(const [], names);
        status.value = const SyncStatus(pending: 0);
        return;
      }
      final hadiths = settings.hadithNotification
          ? await _ref.read(hadithPoolProvider.future)
          : const <Hadith>[];
      final plan = planNotifications(
        place: place.prayerPlace,
        prayerSettings: settings.prayerSettings,
        alarms: settings.alarmSettings,
        now: now ?? DateTime.now(),
      );
      await service.replaceAll(
        buildRequests(
          plan: plan,
          l: l,
          cityName: place.name,
          hadiths: hadiths,
        ),
        names,
      );
      status.value = SyncStatus(pending: await service.pendingCount());
    } on Exception catch (error) {
      // Scheduling is best effort: a platform failure must not break the UI.
      // The next launch or settings change tries again, and the
      // notifications screen shows what went wrong.
      status.value = SyncStatus(error: '$error');
    }
  }
}
