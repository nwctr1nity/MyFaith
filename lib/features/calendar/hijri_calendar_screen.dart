import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:material_ui/material_ui.dart';

import '../../core/hijri.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../labels.dart';
import '../widgets.dart';

/// A month of the Hijri calendar with the Gregorian days beside it, and
/// the dates of the year that are coming.
class HijriCalendarScreen extends ConsumerStatefulWidget {
  const HijriCalendarScreen({super.key, required this.today});

  /// The Gregorian calendar day at the user's place.
  final DateTime today;

  @override
  ConsumerState<HijriCalendarScreen> createState() =>
      _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends ConsumerState<HijriCalendarScreen> {
  /// The month on screen; null shows the current one.
  int? _year;
  int? _month;

  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _show(int year, int month) {
    setState(() {
      _year = year;
      _month = month;
    });
    if (_scroll.hasClients && _scroll.offset > 0) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final adjustment = ref.watch(settingsProvider).hijriAdjustment;
    final today = DateTime.utc(
      widget.today.year,
      widget.today.month,
      widget.today.day,
    );
    final now = hijriFor(
      today.year,
      today.month,
      today.day,
      adjustment: adjustment,
    );
    final year = _year ?? now.year;
    final month = _month ?? now.month;
    final length = hijriMonthLength(year, month);
    final first = gregorianFor(year, month, 1, adjustment: adjustment);
    final last = first.add(Duration(days: length - 1));
    final rtl = Directionality.of(context) == TextDirection.rtl;

    // The Gregorian months the Hijri month runs through.
    final monthFormat = DateFormat.yMMMM(language);
    final span = first.month == last.month
        ? monthFormat.format(first)
        : '${DateFormat.MMMM(language).format(first)} – '
              '${monthFormat.format(last)}';

    final firstWeekday =
        MaterialLocalizations.of(context).firstDayOfWeekIndex; // 0 = Sunday
    final lead = (first.weekday % 7 - firstWeekday + 7) % 7;
    final weekdayFormat = DateFormat.E(language);
    // 2023-01-01 was a Sunday.
    final weekdayNames = [
      for (var i = 0; i < 7; i++)
        weekdayFormat.format(DateTime.utc(2023, 1, 1 + firstWeekday + i)),
    ];

    void step(int by) {
      var m = month + by;
      var y = year;
      if (m < 1) {
        m = 12;
        y--;
      } else if (m > 12) {
        m = 1;
        y++;
      }
      _show(y, m);
    }

    Widget cell(int day) {
      final date = first.add(Duration(days: day - 1));
      final isToday = date == today;
      final event = hijriEventOn(month, day);
      // The 13th of Dhu al-Hijjah is a day of Tashriq, when fasting is
      // not allowed.
      final white = day >= 13 && day <= 15 && event == null;
      final Color? fill = isToday
          ? scheme.primary
          : event != null
          ? scheme.primaryContainer
          : null;
      final Color ink = isToday
          ? scheme.onPrimary
          : event != null
          ? scheme.onPrimaryContainer
          : scheme.onSurface;
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(12),
            border: white && !isToday
                ? Border.all(color: scheme.outlineVariant)
                : null,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                arabicDigits(language, '$day'),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: ink,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              Text(
                arabicDigits(language, '${date.day}'),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isToday || event != null
                      ? ink.withValues(alpha: 0.8)
                      : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final upcoming = upcomingHijriEvents(
      today.year,
      today.month,
      today.day,
      adjustment: adjustment,
    );
    final dayFormat = DateFormat.yMMMd(language);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.hijriCalendar),
        actions: [
          if (year != now.year || month != now.month)
            TextButton(
              onPressed: () => _show(now.year, now.month),
              child: Text(l.today),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => step(-1),
                        icon: Icon(
                          rtl ? Icons.chevron_right : Icons.chevron_left,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              hijriMonthTitle(language, year, month),
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              span,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => step(1),
                        icon: Icon(
                          rtl ? Icons.chevron_left : Icons.chevron_right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final name in weekdayNames)
                        Expanded(
                          child: Center(
                            child: Text(
                              name,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.9,
                    children: [
                      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
                      for (var day = 1; day <= length; day++) cell(day),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // What the marks of this month mean.
          for (final e in HijriEvent.values)
            if (e.month == month)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 0),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${arabicDigits(language, e.days == 1 ? '${e.day}' : '${e.day}–${e.day + e.days - 1}')}'
                        ' · ${hijriEventName(l, e)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 0),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    border: Border.all(color: scheme.outline),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    arabicDigits(language, l.hijriWhiteDays),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SectionHeader(l.hijriComing),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final u in upcoming)
                  ListTile(
                    title: Text(hijriEventName(l, u.event)),
                    subtitle: Text(
                      '${hijriText(language, u.hijriYear, u.event.month, u.event.day)}'
                      ' · ${dayFormat.format(u.date)}',
                    ),
                    trailing: Text(
                      arabicDigits(language, l.inDays(u.daysLeft)),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                    onTap: () => _show(u.hijriYear, u.event.month),
                  ),
              ],
            ),
          ),
          HintText(l.hijriNote),
        ],
      ),
    );
  }
}
