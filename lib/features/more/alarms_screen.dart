import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:material_ui/material_ui.dart';

import '../../core/alarms/notification_planner.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../widgets.dart';

class AlarmsScreen extends ConsumerWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final language = Localizations.localeOf(context).languageCode;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final place = settings.place;

    // The next time each alarm will ring, from the same plan that is
    // scheduled.
    String upcoming(PlannedKind kind) {
      if (place == null) return l.locationNotSet;
      final plan = planNotifications(
        place: place.prayerPlace,
        prayerSettings: settings.prayerSettings,
        alarms: settings.alarmSettings,
        now: DateTime.now(),
      );
      for (final p in plan) {
        if (p.kind == kind) {
          final t = p.time;
          final when = DateFormat(
            'EEEE, d MMMM, HH:mm',
            language,
          ).format(DateTime(t.year, t.month, t.day, t.hour, t.minute));
          return l.nextSuhoor(when);
        }
      }
      return l.noUpcomingAlarm;
    }

    Map<int, String> minuteOptions(List<int> values) => {
      for (final m in values) m: l.minutesBefore(m),
    };

    final stopOptions = {
      0: l.off,
      10: l.minutesBefore(10),
      30: l.minutesBefore(30),
      60: l.oneHourBefore,
    };

    final weekdayNames = DateFormat.E(language)
        .dateSymbols
        .STANDALONESHORTWEEKDAYS;

    return Scaffold(
      appBar: AppBar(title: Text(l.alarmsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.restaurant_outlined),
            title: Text(l.suhoorAlarm),
            subtitle: settings.suhoorEnabled
                ? Text(upcoming(PlannedKind.suhoor))
                : null,
            value: settings.suhoorEnabled,
            onChanged: (v) => controller.setValue('suhoor', v),
          ),
          if (settings.suhoorEnabled) ...[
            ListTile(
              title: Text(l.suhoorBefore),
              subtitle: Text(l.minutesBefore(settings.suhoorMinutesBeforeFajr)),
              onTap: () => pickOption<int>(
                context,
                title: l.suhoorBefore,
                selected: settings.suhoorMinutesBeforeFajr,
                options: minuteOptions(const [20, 30, 45, 60, 75, 90, 120]),
                onSelected: (m) => controller.setValue('suhoorMin', m),
              ),
            ),
            SectionHeader(l.suhoorDays),
            SwitchListTile(
              title: Text(l.suhoorDaily),
              value: settings.suhoorEveryDay,
              onChanged: (v) => controller.setValue('suhoorDaily', v),
            ),
            if (!settings.suhoorEveryDay) ...[
              SwitchListTile(
                title: Text(l.suhoorRamadan),
                value: settings.suhoorInRamadan,
                onChanged: (v) => controller.setValue('suhoorRamadan', v),
              ),
              SwitchListTile(
                title: Text(l.suhoorMonThu),
                value: settings.suhoorMonThu,
                onChanged: (v) => controller.setValue('suhoorMonThu', v),
              ),
              SwitchListTile(
                title: Text(l.suhoorWhite),
                value: settings.suhoorWhiteDays,
                onChanged: (v) => controller.setValue('suhoorWhite', v),
              ),
            ],
            ListTile(
              title: Text(l.suhoorStop),
              subtitle: Text(
                stopOptions[settings.suhoorStopWarningMinutes] ??
                    l.minutesBefore(settings.suhoorStopWarningMinutes),
              ),
              onTap: () => pickOption<int>(
                context,
                title: l.suhoorStop,
                selected: settings.suhoorStopWarningMinutes,
                options: stopOptions,
                onSelected: (m) => controller.setValue('suhoorStop', m),
              ),
            ),
          ],
          const Divider(height: 32),
          SwitchListTile(
            secondary: const Icon(Icons.nights_stay_outlined),
            title: Text(l.tahajjudAlarm),
            subtitle: settings.tahajjudEnabled
                ? Text(upcoming(PlannedKind.tahajjud))
                : null,
            value: settings.tahajjudEnabled,
            onChanged: (v) => controller.setValue('tahajjud', v),
          ),
          if (settings.tahajjudEnabled) ...[
            SectionHeader(l.tahajjudWhen),
            RadioGroup<bool>(
              groupValue: settings.tahajjudAtLastThird,
              onChanged: (v) => controller.setValue('tahajjudThird', v),
              child: Column(
                children: [
                  RadioListTile<bool>(
                    value: true,
                    title: Text(l.tahajjudLastThird),
                  ),
                  RadioListTile<bool>(
                    value: false,
                    title: Text(l.tahajjudBeforeFajr),
                    subtitle: settings.tahajjudAtLastThird
                        ? null
                        : Text(
                            l.minutesBefore(settings.tahajjudMinutesBeforeFajr),
                          ),
                  ),
                ],
              ),
            ),
            if (!settings.tahajjudAtLastThird)
              ListTile(
                title: Text(l.suhoorBefore),
                subtitle: Text(
                  l.minutesBefore(settings.tahajjudMinutesBeforeFajr),
                ),
                onTap: () => pickOption<int>(
                  context,
                  title: l.suhoorBefore,
                  selected: settings.tahajjudMinutesBeforeFajr,
                  options: minuteOptions(const [20, 30, 45, 60, 90, 120]),
                  onSelected: (m) => controller.setValue('tahajjudMin', m),
                ),
              ),
            SectionHeader(l.weekdays),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (var day = 1; day <= 7; day++)
                    FilterChip(
                      // DateFormat lists weekdays from Sunday; ISO weekday
                      // 7 is Sunday.
                      label: Text(weekdayNames[day % 7]),
                      selected: settings.tahajjudWeekdays.contains(day),
                      onSelected: (v) =>
                          controller.toggleTahajjudWeekday(day, v),
                    ),
                ],
              ),
            ),
          ],
          HintText(l.batteryHint),
        ],
      ),
    );
  }
}
