import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/content/dhikr.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../theme.dart';
import '../widgets.dart';

int _goalOf(Dhikr d, AppSettings settings) =>
    settings.dhikrGoal(d.id) ?? d.goal;

/// Dhikr and dua, each with a counter and a goal for the day.
class DhikrScreen extends ConsumerWidget {
  const DhikrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final dhikr = [
      for (final d in dhikrList)
        if (!d.dua) d,
    ];
    final duas = [
      for (final d in dhikrList)
        if (d.dua) d,
    ];
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.navDhikr),
          bottom: TabBar(
            tabs: [
              Tab(text: l.dhikrTab),
              Tab(text: l.duaTab),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DhikrList(items: dhikr),
            _DhikrList(items: duas),
          ],
        ),
      ),
    );
  }
}

class _DhikrList extends ConsumerWidget {
  const _DhikrList({required this.items});

  final List<Dhikr> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final settings = ref.watch(settingsProvider);
    final today = dayKey(DateTime.now());
    final done = items
        .where((d) => settings.dhikrCount(d.id, today) >= _goalOf(d, settings))
        .length;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Container(
            decoration: BoxDecoration(
              gradient: heroGradient(scheme),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.dhikrToday,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onHeroMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.dhikrDone(done, items.length),
                  style: theme.textTheme.titleLarge?.copyWith(color: onHero),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: items.isEmpty ? 0 : done / items.length,
                    minHeight: 8,
                    backgroundColor: const Color(0x33FFFFFF),
                    color: onHero,
                  ),
                ),
              ],
            ),
          );
        }
        final d = items[i - 1];
        final count = settings.dhikrCount(d.id, today);
        final goal = _goalOf(d, settings);
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => DhikrCounterScreen(items: items, index: i - 1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 14, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          d.arabic,
                          textDirection: TextDirection.rtl,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: quranTextStyle(
                            21,
                            scheme.onSurface,
                          ).copyWith(height: 1.7),
                        ),
                        if (language != 'ar') ...[
                          const SizedBox(height: 4),
                          Text(
                            d.transliteration(language),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 58,
                    height: 58,
                    child: CustomPaint(
                      painter: RingPainter(
                        math.min(1, count / goal),
                        scheme,
                        stroke: 5,
                        fill: false,
                      ),
                      child: Center(
                        child: count >= goal
                            ? Icon(Icons.check, color: scheme.primary)
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$count',
                                    style: theme.textTheme.labelLarge,
                                  ),
                                  Text(
                                    '$goal',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The counter of one dhikr; swipe sideways for the next one.
class DhikrCounterScreen extends ConsumerStatefulWidget {
  const DhikrCounterScreen({
    super.key,
    required this.items,
    required this.index,
  });

  final List<Dhikr> items;
  final int index;

  @override
  ConsumerState<DhikrCounterScreen> createState() => _DhikrCounterScreenState();
}

class _DhikrCounterScreenState extends ConsumerState<DhikrCounterScreen> {
  late final _pages = PageController(
    initialPage: widget.index,
    viewportFraction: 0.92,
  );
  late int _index = widget.index;

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
    final today = dayKey(DateTime.now());
    final current = widget.items[_index];
    final count = settings.dhikrCount(current.id, today);
    final goal = _goalOf(current, settings);

    return Scaffold(
      appBar: AppBar(
        title: Text('${_index + 1} / ${widget.items.length}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') {
                controller.resetDhikr(current.id, today);
              } else {
                pickOption<int>(
                  context,
                  title: l.dhikrGoal,
                  selected: goal,
                  options: {
                    for (final g in {
                      current.goal,
                      1,
                      3,
                      7,
                      10,
                      33,
                      100,
                      165,
                      300,
                      500,
                      1000,
                    }.toList()..sort())
                      g: g == current.goal ? l.dhikrGoalDefault(g) : '$g',
                  },
                  onSelected: (g) => controller.setDhikrGoal(
                    current.id,
                    g == current.goal ? null : g,
                  ),
                );
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'goal', child: Text(l.dhikrGoal)),
              PopupMenuItem(value: 'reset', child: Text(l.salawatReset)),
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
              itemCount: widget.items.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final d = widget.items[i];
                final translation = d.translation(language);
                final note = d.note(language);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Card(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text(
                          d.arabic,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: quranTextStyle(24, scheme.onSurface),
                        ),
                        if (language != 'ar') ...[
                          const SizedBox(height: 12),
                          Text(
                            d.transliteration(language),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (translation != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            translation,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Text(
                          [if (note.isNotEmpty) note, d.source].join('\n'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.5,
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 5,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Semantics(
                    button: true,
                    label: l.salawatTap,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // A longer buzz tells the hand the goal is reached.
                        count + 1 == goal
                            ? HapticFeedback.heavyImpact()
                            : HapticFeedback.lightImpact();
                        controller.addDhikr(current.id, today);
                      },
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: math.min(1, count / goal)),
                        duration: const Duration(milliseconds: 250),
                        builder: (context, progress, child) => CustomPaint(
                          painter: RingPainter(progress, scheme),
                          child: child,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$count',
                                style: theme.textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.w300,
                                  color: scheme.onSurface,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              Text(
                                l.ofGoal(goal),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              count >= goal ? l.dhikrGoalReached : l.salawatTap,
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
