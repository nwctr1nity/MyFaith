import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// What to show for one scheduled notification, already localized.
class NotificationRequest {
  const NotificationRequest({
    required this.id,
    required this.time,
    required this.channel,
    required this.title,
    this.body,
  });

  final int id;
  final tz.TZDateTime time;
  final NotificationChannel channel;
  final String title;
  final String? body;
}

enum NotificationChannel { adhan, adhanFajr, reminder, alarm, hadith }

/// Names of the channels as the user sees them in Android settings.
class ChannelNames {
  const ChannelNames({
    required this.adhan,
    required this.adhanFajr,
    required this.reminder,
    required this.alarm,
    required this.hadith,
  });

  final String adhan;
  final String adhanFajr;
  final String reminder;
  final String alarm;
  final String hadith;
}

class NotificationPermissions {
  const NotificationPermissions({
    required this.notifications,
    required this.exactAlarms,
  });

  final bool notifications;
  final bool exactAlarms;
}

/// The seam between the app and the notification plugin, so tests can
/// replace it.
abstract class NotificationService {
  Future<void> init();
  Future<NotificationPermissions> permissions();
  Future<void> requestNotifications();
  Future<void> requestExactAlarms();

  /// Replaces everything scheduled with [requests].
  Future<void> replaceAll(List<NotificationRequest> requests, ChannelNames names);

  /// Shows one notification right away, without touching the others.
  Future<void> showNow(NotificationRequest request, ChannelNames names);

  /// How many notifications are waiting to fire.
  Future<int> pendingCount();
}

class LocalNotificationService implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<void> init() async {
    if (_ready) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
      ),
    );
    _ready = true;
  }

  @override
  Future<NotificationPermissions> permissions() async {
    await init();
    final android = _android;
    if (android == null) {
      return const NotificationPermissions(
        notifications: false,
        exactAlarms: false,
      );
    }
    return NotificationPermissions(
      notifications: await android.areNotificationsEnabled() ?? false,
      exactAlarms: await android.canScheduleExactNotifications() ?? false,
    );
  }

  @override
  Future<void> requestNotifications() async {
    await init();
    await _android?.requestNotificationsPermission();
  }

  @override
  Future<void> requestExactAlarms() async {
    await init();
    await _android?.requestExactAlarmsPermission();
  }

  AndroidNotificationDetails _details(
    NotificationChannel channel,
    ChannelNames names,
    String? body,
  ) {
    final style = body == null ? null : BigTextStyleInformation(body);
    switch (channel) {
      case NotificationChannel.adhan:
      case NotificationChannel.adhanFajr:
        // Alarm usage plays at alarm volume, so a muted ringer does not
        // silence the adhan. The channel id carries a version: Android
        // fixes a channel's sound when the channel is first created.
        final fajr = channel == NotificationChannel.adhanFajr;
        return AndroidNotificationDetails(
          fajr ? 'adhan_fajr_v2' : 'adhan_v2',
          fajr ? names.adhanFajr : names.adhan,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          sound: RawResourceAndroidNotificationSound(
            fajr ? 'azan_fajr' : 'azan_main',
          ),
          visibility: NotificationVisibility.public,
          styleInformation: style,
        );
      case NotificationChannel.reminder:
        return AndroidNotificationDetails(
          'reminder_v1',
          names.reminder,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          styleInformation: style,
        );
      case NotificationChannel.alarm:
        return AndroidNotificationDetails(
          'alarm_v1',
          names.alarm,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          sound: const UriAndroidNotificationSound(
            'content://settings/system/alarm_alert',
          ),
          fullScreenIntent: true,
          visibility: NotificationVisibility.public,
          // FLAG_INSISTENT: the sound repeats until the notification is
          // opened or dismissed, like an alarm clock.
          additionalFlags: Int32List.fromList(const [4]),
          styleInformation: style,
        );
      case NotificationChannel.hadith:
        return AndroidNotificationDetails(
          'hadith_v1',
          names.hadith,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: style,
        );
    }
  }

  @override
  Future<void> replaceAll(
    List<NotificationRequest> requests,
    ChannelNames names,
  ) async {
    await init();
    final android = _android;
    if (android == null) return;
    // Channels of earlier builds, which had no adhan recording.
    await android.deleteNotificationChannel(channelId: 'adhan_v1');
    await _plugin.cancelAllPendingNotifications();
    final exact = await android.canScheduleExactNotifications() ?? false;
    for (final r in requests) {
      await _schedule(r, names, exact);
    }
  }

  @override
  Future<void> showNow(NotificationRequest request, ChannelNames names) async {
    await init();
    await _plugin.show(
      id: request.id,
      title: request.title,
      body: request.body,
      notificationDetails: NotificationDetails(
        android: _details(request.channel, names, request.body),
      ),
    );
  }

  @override
  Future<int> pendingCount() async {
    await init();
    return (await _plugin.pendingNotificationRequests()).length;
  }

  Future<void> _schedule(
    NotificationRequest r,
    ChannelNames names,
    bool exact,
  ) async {
    final AndroidScheduleMode mode;
    if (!exact) {
      mode = AndroidScheduleMode.inexactAllowWhileIdle;
    } else if (r.channel == NotificationChannel.alarm) {
      mode = AndroidScheduleMode.alarmClock;
    } else {
      mode = AndroidScheduleMode.exactAllowWhileIdle;
    }
    await _plugin.zonedSchedule(
      id: r.id,
      title: r.title,
      body: r.body,
      scheduledDate: r.time,
      notificationDetails:
          NotificationDetails(android: _details(r.channel, names, r.body)),
      androidScheduleMode: mode,
    );
  }
}
