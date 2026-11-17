import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:material_ui/material_ui.dart';

import '../../core/content/hadith.dart';
import '../../core/hijri.dart';
import '../../core/prayer/prayer_calculator.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../../state/content_providers.dart';
import '../calendar/hijri_calendar_screen.dart';
import '../hadith/hadith_screen.dart';
import '../labels.dart';
import '../location/city_picker_screen.dart';
import '../prayer_guide/prayer_guide_screen.dart';
import '../qibla/qibla_screen.dart';
import '../theme.dart';
import 'update_card.dart';

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

  void _openCityPicker() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CityPickerScreen()));
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
                borderRadius: BorderRadius.circular(8),
                onTap: _openCityPicker,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        place.fromGps
                            ? Icons.my_location
                            : Icons.place_outlined,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          place.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const QiblaScreen()),
              ),
              icon: const Icon(Icons.explore_outlined, size: 20),
              label: Text(l.navQibla),
            ),
          ),
        ],
      ),
      body: place == null
          ? _EmptyState(onChoose: _openCityPicker)
          : _Timetable(
              day: _calculator.computeForInstant(
                place: place.prayerPlace,
                settings: settings.prayerSettings,
                now: _now,
              ),
              now: _now,
              settings: settings,
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
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.place_outlined, size: 56, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              l.locationNotSet,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onChoose, child: Text(l.chooseCity)),
          ],
        ),
      ),
    );
  }
}

class _Timetable extends ConsumerWidget {
  const _Timetable({
    required this.day,
    required this.now,
    required this.settings,
  });

  static const _calculator = PrayerCalculator();
  static const _numbers = TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
  );

  final PrayerDay day;
  final DateTime now;
  final AppSettings settings;

  String _countdown(Duration d) {
    final total = d.inSeconds < 0 ? 0 : d.inSeconds;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(total ~/ 3600)}:${two(total % 3600 ~/ 60)}:${two(total % 60)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final timeFormat = DateFormat.Hm(language);
    final dateFormat = DateFormat.MMMMEEEEd(language);
    final moment = _calculator.momentAt(day, now);
    final hijri = hijriFor(
      day.year,
      day.month,
      day.day,
      adjustment: settings.hijriAdjustment,
    );

    // The times are already in the place's zone; format their wall-clock
    // fields without converting to the phone's zone.
    String clock(DateTime t) =>
        timeFormat.format(DateTime(t.year, t.month, t.day, t.hour, t.minute));

    final noon = day[PrayerSlot.dhuhr];
    final dayKey =
        '${noon.year}-${noon.month.toString().padLeft(2, '0')}-'
        '${noon.day.toString().padLeft(2, '0')}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        const UpdateCard(),
        Container(
          decoration: BoxDecoration(
            gradient: heroGradient(scheme),
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The date opens the Hijri calendar.
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => HijriCalendarScreen(
                      today: DateTime(day.year, day.month, day.day),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hijriText(
                              language,
                              hijri.year,
                              hijri.month,
                              hijri.day,
                            ),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: onHero,
                            ),
                          ),
                          Text(
                            dateFormat.format(
                              DateTime(day.year, day.month, day.day),
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: onHeroMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: l.hijriCalendar,
                      child: const Icon(
                        Icons.calendar_month_outlined,
                        color: onHeroMuted,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l.nextPrayerIn(prayerName(l, moment.next)),
                style: theme.textTheme.titleMedium?.copyWith(color: onHero),
              ),
              // Digits always read left to right, in Arabic too.
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  _countdown(moment.nextTime.difference(now)),
                  style: theme.textTheme.displayMedium
                      ?.merge(_numbers)
                      .copyWith(color: onHero, fontWeight: FontWeight.w300),
                ),
              ),
              Text(
                l.atTime(clock(moment.nextTime)),
                style: theme.textTheme.bodyMedium?.copyWith(color: onHeroMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                for (final slot in PrayerSlot.values)
                  _PrayerRow(
                    // A prayer whose time has come can be marked as missed
                    // with a long press; nothing else is asked of the user.
                    missedLabel: settings.isMissed(dayKey, slot)
                        ? l.missedLabel
                        : null,
                    onLongPress:
                        slot == PrayerSlot.sunrise || day[slot].isAfter(now)
                        ? null
                        : () {
                            final controller =
                                ref.read(settingsProvider.notifier);
                            final wasMissed = settings.isMissed(dayKey, slot);
                            controller.toggleMissed(dayKey, slot);
                            HapticFeedback.mediumImpact();
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  // With an action a snack bar would stay
                                  // until dismissed; this one is a passing
                                  // note.
                                  persist: false,
                                  duration: const Duration(seconds: 4),
                                  content: Text(
                                    wasMissed
                                        ? l.missedUnmarked(prayerName(l, slot))
                                        : l.missedMarked(prayerName(l, slot)),
                                  ),
                                  action: SnackBarAction(
                                    label: l.undo,
                                    onPressed: () =>
                                        controller.toggleMissed(dayKey, slot),
                                  ),
                                ),
                              );
                          },
                    name: prayerName(l, slot),
                    time: clock(day[slot]),
                    isCurrent: moment.current == slot,
                    // After Isha the next prayer is tomorrow's Fajr, not
                    // this row.
                    isNext: moment.next == slot && moment.nextTime == day[slot],
                    soonLabel:
                        moment.next == slot &&
                            moment.nextTime == day[slot] &&
                            moment.nextTime.difference(now) <
                                const Duration(hours: 1)
                        ? l.soonLabel(
                            math.max(
                              1,
                              (moment.nextTime.difference(now).inSeconds / 60)
                                  .ceil(),
                            ),
                          )
                        : null,
                    muted: slot == PrayerSlot.sunrise,
                    nowLabel: l.nowLabel,
                    adhanOn: settings.adhanSlots.contains(slot),
                    adhanTooltip: settings.adhanSlots.contains(slot)
                        ? l.adhanOn
                        : l.adhanOff,
                    onToggleAdhan: () => ref
                        .read(settingsProvider.notifier)
                        .toggleAdhan(slot, !settings.adhanSlots.contains(slot)),
                  ),
                Divider(height: 17, indent: 20, endIndent: 20),
                _PrayerRow(
                  name: l.lastThirdOfNight,
                  time: clock(day.lastThirdOfNight),
                  isCurrent: false,
                  isNext: false,
                  muted: true,
                  nowLabel: l.nowLabel,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: Icon(Icons.school_outlined, color: scheme.primary),
            title: Text(l.howToPray),
            subtitle: Text(l.howToPrayHint),
            trailing: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              color: scheme.outline,
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PrayerGuideScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _HadithCard(year: day.year, month: day.month, day: day.day),
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
    this.soonLabel,
    this.missedLabel,
    this.onLongPress,
    this.adhanOn,
    this.adhanTooltip,
    this.onToggleAdhan,
  });

  final String name;
  final String time;
  final bool isCurrent;
  final bool isNext;
  final bool muted;
  final String nowLabel;

  /// "In 12 min!" on the next prayer when it is less than an hour away.
  final String? soonLabel;

  /// "Missed" on a prayer the user marked so.
  final String? missedLabel;
  final VoidCallback? onLongPress;
  final bool? adhanOn;
  final String? adhanTooltip;
  final VoidCallback? onToggleAdhan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = muted ? scheme.onSurfaceVariant : scheme.onSurface;
    final weight = isNext ? FontWeight.w700 : FontWeight.w400;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onLongPress,
      child: _row(theme, scheme, color, weight),
    );
  }

  Widget _row(
    ThemeData theme,
    ColorScheme scheme,
    Color color,
    FontWeight weight,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      padding: const EdgeInsetsDirectional.only(start: 12),
      decoration: BoxDecoration(
        color: isCurrent ? scheme.secondaryContainer : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: weight,
                    ),
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      nowLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimary,
                      ),
                    ),
                  ),
                ],
                if (missedLabel != null) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: scheme.error),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      missedLabel!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.error,
                      ),
                    ),
                  ),
                ],
                if (soonLabel != null) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8730C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      soonLabel!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            time,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: weight,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (onToggleAdhan != null)
            IconButton(
              tooltip: adhanTooltip,
              onPressed: onToggleAdhan,
              icon: Icon(
                adhanOn == true
                    ? Icons.notifications_active
                    : Icons.notifications_off_outlined,
                color: adhanOn == true ? scheme.primary : scheme.outline,
                size: 22,
              ),
            )
          else
            const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }
}

class _HadithCard extends ConsumerWidget {
  const _HadithCard({
    required this.year,
    required this.month,
    required this.day,
  });

  final int year;
  final int month;
  final int day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final pool = ref.watch(hadithPoolProvider).value;
    if (pool == null || pool.isEmpty) return const SizedBox.shrink();
    final today = dayNumber(year, month, day);
    final hadith = pool[dailyHadithIndex(today, pool.length)];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => HadithScreen(initialDay: today),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.format_quote, color: scheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l.hadithOfDay,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                hadith.translation(language),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                l.bukhariRef(hadith.number),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
