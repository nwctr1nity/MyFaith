import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/prayer/prayer_calculator.dart';
import '../../l10n/app_localizations.dart';
import '../../services/notification_service.dart';
import '../../state/app_settings.dart';
import '../../state/notification_sync.dart';
import '../labels.dart';
import '../widgets.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with WidgetsBindingObserver {
  NotificationPermissions? _permissions;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The exact-alarm permission is granted on a system screen.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    try {
      final p = await ref.read(notificationServiceProvider).permissions();
      if (mounted) setState(() => _permissions = p);
    } on Exception {
      // Leaves the rows in their "not granted" state.
    }
  }

  Future<void> _request(Future<void> Function() ask) async {
    try {
      await ask();
    } on Exception {
      // The row keeps showing that the permission is missing.
    }
    await _refresh();
    ref.read(notificationSyncProvider).schedule();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final service = ref.read(notificationServiceProvider);
    final permissions = _permissions;

    String reminderLabel(int minutes) =>
        minutes == 0 ? l.off : l.minutesBefore(minutes);
    String hour(int h) => '${h.toString().padLeft(2, '0')}:00';

    Widget permissionRow({
      required bool granted,
      required String title,
      required String hint,
      required Future<void> Function() ask,
    }) =>
        ListTile(
          leading: Icon(
            granted ? Icons.check_circle : Icons.error_outline,
            color: granted ? scheme.primary : scheme.error,
          ),
          title: Text(title),
          subtitle: Text(granted ? l.permissionGranted : hint),
          onTap: granted ? null : () => _request(ask),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.notifications)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (permissions != null) ...[
            permissionRow(
              granted: permissions.notifications,
              title: l.permissionNotifications,
              hint: l.permissionNotificationsHint,
              ask: service.requestNotifications,
            ),
            permissionRow(
              granted: permissions.exactAlarms,
              title: l.permissionExact,
              hint: l.permissionExactHint,
              ask: service.requestExactAlarms,
            ),
          ],
          SectionHeader(l.notificationsHint),
          for (final slot in PrayerSlot.values)
            SwitchListTile(
              title: Text(prayerName(l, slot)),
              value: settings.adhanSlots.contains(slot),
              onChanged: (v) => controller.toggleAdhan(slot, v),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(l.reminderBefore),
            subtitle: Text(reminderLabel(settings.reminderMinutes)),
            onTap: () => pickOption<int>(
              context,
              title: l.reminderBefore,
              selected: settings.reminderMinutes,
              options: {
                for (final m in const [0, 5, 10, 15, 20, 30])
                  m: reminderLabel(m),
              },
              onSelected: (m) => controller.setValue('remind', m),
            ),
          ),
          SectionHeader(l.hadithOfDay),
          SwitchListTile(
            title: Text(l.hadithNotification),
            value: settings.hadithNotification,
            onChanged: (v) => controller.setValue('hadithNotify', v),
          ),
          ListTile(
            enabled: settings.hadithNotification,
            title: Text(l.hadithTime),
            subtitle: Text(hour(settings.hadithHour)),
            onTap: () => pickOption<int>(
              context,
              title: l.hadithTime,
              selected: settings.hadithHour,
              options: {for (var h = 5; h <= 22; h++) h: hour(h)},
              onSelected: (h) => controller.setValue('hadithHour', h),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.volume_up_outlined),
              label: Text(l.testAdhan),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await ref.read(notificationSyncProvider).scheduleTest();
                  messenger.showSnackBar(
                    SnackBar(content: Text(l.testScheduled)),
                  );
                } on Exception catch (error) {
                  messenger.showSnackBar(SnackBar(content: Text('$error')));
                }
              },
            ),
          ),
          HintText(l.batteryHint),
        ],
      ),
    );
  }
}
