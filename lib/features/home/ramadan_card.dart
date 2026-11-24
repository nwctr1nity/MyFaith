import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:material_ui/material_ui.dart';

import '../../core/content/ramadan.dart';
import '../../core/hijri.dart';
import '../../core/prayer/prayer_calculator.dart';
import '../../core/ramadan.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../dhikr/dhikr_screen.dart';

/// The fasting countdown: to iftar by day, to the end of suhoor by night.
/// Shows itself in Ramadan, see [ramadanActive].
class RamadanCard extends ConsumerWidget {
  const RamadanCard({super.key, required this.day, required this.now});

  static const _calculator = PrayerCalculator();

  final PrayerDay day;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final place = settings.place;
    if (place == null ||
        !ramadanActive(
          mode: settings.ramadanMode,
          today: day,
          now: now,
          hijriAdjustment: settings.hijriAdjustment,
        )) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final controller = ref.read(settingsProvider.notifier);

    final tomorrow = _calculator.compute(
      place: place.prayerPlace,
      settings: settings.prayerSettings,
      year: day.year,
      month: day.month,
      day: day.day + 1,
    );
    final moment = fastMoment(
      today: day,
      tomorrowFajr: tomorrow[PrayerSlot.fajr],
      now: now,
    );
    final left = moment.until.difference(now);
    final seconds = left.inSeconds < 0 ? 0 : left.inSeconds;
    String two(int n) => n.toString().padLeft(2, '0');
    final countdown =
        '${two(seconds ~/ 3600)}:${two(seconds % 3600 ~/ 60)}:${two(seconds % 60)}';
    final t = moment.until;
    final clock = DateFormat.Hm(
      language,
    ).format(DateTime(t.year, t.month, t.day, t.hour, t.minute));

    // Offered once, in Ramadan itself, to those who have no suhoor alarm.
    final night = !now.isBefore(day[PrayerSlot.maghrib]);
    final offerSuhoor =
        !settings.suhoorEnabled &&
        !settings.suhoorOffered &&
        hijriFor(
          day.year,
          day.month,
          day.day + (night ? 1 : 0),
          adjustment: settings.hijriAdjustment,
        ).isRamadan;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: scheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 14, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          moment.fasting ? l.untilIftar : l.untilSuhoorEnd,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: scheme.onSecondaryContainer,
                          ),
                        ),
                        Text(
                          l.atTime(clock),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSecondaryContainer.withValues(
                              alpha: 0.75,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Digits always read left to right, in Arabic too.
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      countdown,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: scheme.onSecondaryContainer,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              if (offerSuhoor) ...[
                const SizedBox(height: 10),
                Text(
                  l.suhoorOffer,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSecondaryContainer,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        controller.setValue('suhoorAsked', true);
                        controller.setValue('suhoor', true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.suhoorOfferDone)),
                        );
                      },
                      child: Text(l.suhoorOfferYes),
                    ),
                    TextButton(
                      onPressed: () => controller.setValue('suhoorAsked', true),
                      child: Text(l.suhoorOfferNo),
                    ),
                  ],
                ),
              ] else
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const DhikrCounterScreen(
                          items: [iftarDua],
                          index: 0,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.menu_book_outlined, size: 18),
                    label: Text(l.iftarDua),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
