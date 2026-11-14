import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/prayer/prayer_calculator.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../labels.dart';
import '../location/city_picker_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _calculator = PrayerCalculator();

  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final place = settings.place;

    return Scaffold(
      appBar: AppBar(
        title: place == null
            ? Text(l.appTitle)
            : InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CityPickerScreen())),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      place.fromGps ? Icons.my_location : Icons.place_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(place.name, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
        actions: [
          IconButton(
            tooltip: l.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: place == null
            ? _EmptyState(onChoose: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CityPickerScreen())))
            : _Timetable(
                day: _calculator.computeForInstant(
                  place: place.prayerPlace,
                  settings: settings.prayerSettings,
                  now: _now,
                ),
                now: _now,
                calculator: _calculator,
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onChoose});

  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.locationNotSet,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onChoose, child: Text(l.chooseCity)),
          ],
        ),
      ),
    );
  }
}

class _Timetable extends StatelessWidget {
  const _Timetable({
    required this.day,
    required this.now,
    required this.calculator,
  });

  final PrayerDay day;
  final DateTime now;
  final PrayerCalculator calculator;

  String _countdown(Duration d) {
    final total = d.inSeconds < 0 ? 0 : d.inSeconds;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(total ~/ 3600)}:${two(total % 3600 ~/ 60)}:${two(total % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final timeFormat = DateFormat.Hm(locale);
    final dateFormat = DateFormat.yMMMMEEEEd(locale);
    final moment = calculator.momentAt(day, now);
    final numbers = const TextStyle(
      fontFeatures: [FontFeature.tabularFigures()],
    );

    // The times are already in the place's zone; format their wall-clock
    // fields without converting to the phone's zone.
    String clock(DateTime t) =>
        timeFormat.format(DateTime(t.year, t.month, t.day, t.hour, t.minute));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          dateFormat.format(DateTime(day.year, day.month, day.day)),
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: scheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.nextPrayerIn(prayerName(l, moment.next)),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: scheme.onPrimaryContainer),
                ),
                const SizedBox(height: 4),
                // Digits always read left to right, in Arabic too.
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    _countdown(moment.nextTime.difference(now)),
                    style: theme.textTheme.displayMedium
                        ?.merge(numbers)
                        .copyWith(color: scheme.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final slot in PrayerSlot.values)
          _PrayerRow(
            name: prayerName(l, slot),
            time: clock(day[slot]),
            isCurrent: moment.current == slot,
            // After Isha the next prayer is tomorrow's Fajr, not this row.
            isNext: moment.next == slot && moment.nextTime == day[slot],
            muted: slot == PrayerSlot.sunrise,
            nowLabel: l.nowLabel,
            numbers: numbers,
          ),
        const Divider(height: 32),
        _PrayerRow(
          name: l.lastThirdOfNight,
          time: clock(day.lastThirdOfNight),
          isCurrent: false,
          isNext: false,
          muted: true,
          nowLabel: l.nowLabel,
          numbers: numbers,
        ),
      ],
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.name,
    required this.time,
    required this.isCurrent,
    required this.isNext,
    required this.muted,
    required this.nowLabel,
    required this.numbers,
  });

  final String name;
  final String time;
  final bool isCurrent;
  final bool isNext;
  final bool muted;
  final String nowLabel;
  final TextStyle numbers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = muted ? scheme.onSurfaceVariant : scheme.onSurface;
    final weight = isNext ? FontWeight.w700 : FontWeight.w400;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrent ? scheme.secondaryContainer : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: color, fontWeight: weight),
            ),
          ),
          if (isCurrent) ...[
            Text(
              nowLabel,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: scheme.onSecondaryContainer),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            time,
            style: theme.textTheme.titleMedium
                ?.merge(numbers)
                .copyWith(color: color, fontWeight: weight),
          ),
        ],
      ),
    );
  }
}
