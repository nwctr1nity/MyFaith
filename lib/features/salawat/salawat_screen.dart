import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/content/salawat.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../theme.dart';
import '../widgets.dart';

String _dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

class SalawatScreen extends ConsumerStatefulWidget {
  const SalawatScreen({super.key});

  @override
  ConsumerState<SalawatScreen> createState() => _SalawatScreenState();
}

class _SalawatScreenState extends ConsumerState<SalawatScreen> {
  final _pages = PageController(viewportFraction: 0.92);
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final today = _dayKey(DateTime.now());
    final count = settings.salawatDay == today ? settings.salawatToday : 0;
    final goal = settings.salawatGoal;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.navSalawat),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'translit') {
                controller.setValue(
                  'salTranslit',
                  !settings.salawatShowTransliteration,
                );
              } else {
                pickOption<int>(
                  context,
                  title: l.salawatGoal,
                  selected: goal,
                  options: {
                    for (final g in const [10, 33, 100, 300, 500, 1000])
                      g: '$g',
                  },
                  onSelected: (g) => controller.setValue('salGoal', g),
                );
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'goal', child: Text(l.salawatGoal)),
              if (language != 'ar')
                CheckedPopupMenuItem(
                  value: 'translit',
                  checked: settings.salawatShowTransliteration,
                  child: Text(l.showTransliterationItem),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: PageView.builder(
              controller: _pages,
              itemCount: salawatList.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                final s = salawatList[i];
                final translation = s.translation(language);
                return ScrollCard(
                  children: [
                    Text(
                      s.arabic,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: quranTextStyle(24, scheme.onSurface),
                    ),
                    if (language != 'ar' &&
                        settings.salawatShowTransliteration) ...[
                      const SizedBox(height: 14),
                      Text(
                        s.transliteration(language),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (translation != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        translation,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                    if (s.bukhariNumber != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        l.bukhariRef(s.bukhariNumber!),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          PageDots(count: salawatList.length, index: _page),
          Expanded(
            flex: 5,
            child: CounterRing(
              count: count,
              goal: goal,
              caption: l.salawatToday,
              goalText: l.ofGoal(goal),
              tapLabel: l.salawatTap,
              resetLabel: l.salawatReset,
              onTap: () => controller.addSalawat(today),
              onReset: () => controller.resetSalawatToday(today),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              count == 0 ? l.salawatTap : l.salawatTotal(settings.salawatTotal),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
