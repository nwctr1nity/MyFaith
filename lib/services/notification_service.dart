import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';

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
    this.sound,
  });

  final int id;
  final tz.TZDateTime time;
  final NotificationChannel channel;
  final String title;
  final String? body;

  /// For an adhan: the recording to play, a file name in `res/raw`.
  final String? sound;
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

/// What the adhan service played last.
class LastAdhan {
  const LastAdhan({required this.time, required this.title, required this.file});

  final DateTime time;
  final String title;

  /// The recording, a file name in `res/raw`.
  final String file;
}

/// One prayer time as the home-screen widgets show it.
class WidgetPrayer {
  const WidgetPrayer({
    required this.time,
    required this.day,
    required this.slot,
    required this.name,
    required this.clock,
  });

  final DateTime time;

  /// Calendar day in the place's zone, the same for all prayers of a day.
  final String day;

  /// Index of the prayer in the day, 0 for Fajr to 5 for Isha.
  final int slot;
  final String name;
  final String clock;

  Map<String, Object?> toJson() => {
        't': time.millisecondsSinceEpoch,
        'day': day,
        'slot': slot,
        'name': name,
        'clock': clock,
      };
}

/// Everything the widgets and the adhan player need besides the schedule.
class WidgetData {
  const WidgetData({
    this.city = '',
    this.prayers = const [],
    this.stopLabel = 'Stop',
    this.openHint = '',
  });

  final String city;
  final List<WidgetPrayer> prayers;
  final String stopLabel;
  final String openHint;
}

/// The seam between the app and the notification plugin, so tests can
/// replace it.
abstract class NotificationService {
  Future<void> init();
  Future<NotificationPermissions> permissions();
  Future<void> requestNotifications();
  Future<void> requestExactAlarms();

  /// Replaces everything scheduled with [requests] and hands [widget] to
  /// the home-screen widgets.
  Future<void> replaceAll(
    List<NotificationRequest> requests,
    ChannelNames names, {
    WidgetData widget = const WidgetData(),
  });

  /// Shows one notification right away, without touching the others.
  Future<void> showNow(NotificationRequest request, ChannelNames names);

  /// How many notifications are waiting to fire.
  Future<int> pendingCount();

  /// The adhan that played last: its title, time and recording.
  Future<LastAdhan?> lastAdhan();
}

bool _isAdhan(NotificationRequest r) =>
    r.channel == NotificationChannel.adhan ||
    r.channel == NotificationChannel.adhanFajr;

class LocalNotificationService implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  /// The app's own Android code: it plays the adhan recording in a service
  /// and draws the widgets. The plugin handles every other notification.
  static const _native = MethodChannel('app.myfaith/native');
  bool _ready = false;
  int _nativeScheduled = 0;

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
        throw StateError('the adhan is played by the native service');
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
    ChannelNames names, {
    WidgetData widget = const WidgetData(),
  }) async {
    await init();
    final android = _android;
    if (android == null) return;
    // Channels of earlier builds, which played the adhan as a notification
    // sound.
    for (final old in const ['adhan_v1', 'adhan_v2', 'adhan_fajr_v2']) {
      await android.deleteNotificationChannel(channelId: old);
    }
    await _plugin.cancelAllPendingNotifications();
    final exact = await android.canScheduleExactNotifications() ?? false;
    for (final r in requests) {
      if (!_isAdhan(r)) await _schedule(r, names, exact);
    }
    _nativeScheduled = await _native.invokeMethod<int>('sync', {
          'adhans': jsonEncode([
            for (final r in requests)
              if (_isAdhan(r))
                {
                  'id': r.id,
                  't': r.time.millisecondsSinceEpoch,
                  'title': r.title,
                  'body': r.body ?? '',
                  'fajr': r.channel == NotificationChannel.adhanFajr,
                  'sound': r.sound ?? '',
                },
          ]),
          'prayers': jsonEncode([for (final p in widget.prayers) p.toJson()]),
          'city': widget.city,
          'stopLabel': widget.stopLabel,
          'channelName': names.adhan,
          'openHint': widget.openHint,
        }) ??
        0;
  }

  @override
  Future<void> showNow(NotificationRequest request, ChannelNames names) async {
    if (_isAdhan(request)) {
      await _native.invokeMethod<void>('play', {
        'title': request.title,
        'body': request.body ?? '',
        'fajr': request.channel == NotificationChannel.adhanFajr,
        'sound': request.sound ?? '',
      });
      return;
    }
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
  Future<LastAdhan?> lastAdhan() async {
    try {
      final raw = await _native.invokeMethod<String>('lastAdhan');
      if (raw == null) return null;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return LastAdhan(
        time: DateTime.fromMillisecondsSinceEpoch(data['t'] as int),
        title: data['title'] as String? ?? '',
        file: data['file'] as String? ?? '',
      );
    } on Exception {
      return null;
    }
  }

  @override
  Future<int> pendingCount() async {
    await init();
    return (await _plugin.pendingNotificationRequests()).length +
        _nativeScheduled;
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
