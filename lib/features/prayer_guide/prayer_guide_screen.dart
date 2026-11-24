import 'package:material_ui/material_ui.dart';

import '../../core/content/prayer_guide.dart';
import '../../l10n/app_localizations.dart';
import '../theme.dart';

/// How to pray, step by step, in the Hanafi school.
class PrayerGuideScreen extends StatelessWidget {
  const PrayerGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final heading = theme.textTheme.titleMedium?.copyWith(
      color: scheme.primary,
    );
    final body = theme.textTheme.bodyLarge?.copyWith(height: 1.5);

    String slotName(String slot) => switch (slot) {
      'fajr' => l.prayerFajr,
      'dhuhr' => l.prayerDhuhr,
      'asr' => l.prayerAsr,
      'maghrib' => l.prayerMaghrib,
      _ => l.prayerIsha,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l.howToPray)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: heroGradient(scheme),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(20),
            child: Text(
              guideIntro.of(language),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: onHero,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(l.guideRakaats, style: heading),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Table(
                    columnWidths: const {0: FlexColumnWidth(1.5)},
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        children: [
                          const SizedBox(),
                          for (final h in [
                            l.guideSunnahBefore,
                            l.guideFard,
                            l.guideSunnahAfter,
                            l.guideWitr,
                          ])
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                h,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                      for (final row in rakaatTable)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 8,
                                top: 8,
                                bottom: 8,
                              ),
                              child: Text(
                                slotName(row.slot),
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                            for (final n in [
                              row.sunnahBefore,
                              row.fard,
                              row.sunnahAfter,
                              row.witr,
                            ])
                              Text(
                                n == 0 ? '–' : '$n',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: n == 0
                                      ? scheme.outline
                                      : scheme.onSurface,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      rakaatNotes.of(language),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(l.guideBefore, style: heading),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final item in guideBefore)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Icon(
                              Icons.check_circle_outline,
                              size: 18,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(item.of(language), style: body)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(l.guideAdhan, style: heading),
          const SizedBox(height: 8),
          for (final step in guideAdhan) _StepCard(step: step),
          const SizedBox(height: 12),
          Text(l.guideSteps, style: heading),
          const SizedBox(height: 8),
          for (var i = 0; i < guideSteps.length; i++)
            _StepCard(step: guideSteps[i], number: i + 1),
          const SizedBox(height: 12),
          Text(l.guideMore, style: heading),
          const SizedBox(height: 8),
          for (final step in guideMore) _StepCard(step: step),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step, this.number});

  final GuideStep step;
  final int? number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final recital = step.recital;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (number != null) ...[
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$number',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      step.title.of(language),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                step.text.of(language),
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              if (recital != null) ...[
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        recital.arabic,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: quranTextStyle(22, scheme.onSurface),
                      ),
                      // As everywhere: the transliteration is the muted
                      // line, the translation the bright one.
                      if (language != 'ar') ...[
                        const SizedBox(height: 8),
                        Text(
                          recital.transliteration(language),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          recital.meaning.of(language),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
