import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:material_ui/material_ui.dart';

import '../../core/content/muezzins.dart';
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
    } on Exception catch (error) {
      // Shown under the test buttons: without it a broken setup is silent.
      ref.read(notificationSyncProvider).status.value =
          SyncStatus(error: '$error');
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
            leading: const Icon(Icons.record_voice_over_outlined),
            title: Text(l.muezzin),
            subtitle: Text(
              muezzinById(settings.muezzinId).name(l.localeName),
            ),
            onTap: () => pickOption<String>(
              context,
              title: l.muezzin,
              selected: muezzinById(settings.muezzinId).id,
              options: {for (final m in muezzins) m.id: m.name(l.localeName)},
              onSelected: (id) => controller.setValue('muezzin', id),
            ),
          ),
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
          for (final fajr in const [false, true])
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.volume_up_outlined),
                label: Text(fajr ? l.testAdhanFajr : l.testAdhan),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await ref
                        .read(notificationSyncProvider)
                        .playTest(fajr: fajr);
                    messenger.showSnackBar(
                      SnackBar(content: Text(l.testScheduled)),
                    );
                  } on Exception catch (error) {
                    messenger.showSnackBar(SnackBar(content: Text('$error')));
                  }
                },
              ),
            ),
          ValueListenableBuilder<SyncStatus?>(
            valueListenable: ref.read(notificationSyncProvider).status,
            builder: (context, status, _) {
              if (status == null) return const SizedBox.shrink();
              final error = status.error;
              return HintText(
                error != null
                    ? l.syncError(error)
                    : l.syncPending(status.pending ?? 0),
              );
            },
          ),
          FutureBuilder<LastAdhan?>(
            future: service.lastAdhan(),
            builder: (context, snapshot) {
              final last = snapshot.data;
              if (last == null) return const SizedBox.shrink();
              return HintText(
                l.lastAdhan(
                  last.title,
                  DateFormat.MMMd(l.localeName).add_Hm().format(last.time),
                  last.file,
                ),
              );
            },
          ),
          HintText(l.batteryHint),
        ],
      ),
    );
  }
}
