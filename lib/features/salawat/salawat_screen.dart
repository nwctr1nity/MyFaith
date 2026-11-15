import 'dart:math' as math;

import 'package:flutter/services.dart';
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
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Card(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
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
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < salawatList.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page ? scheme.primary : scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
          Expanded(
            flex: 5,
            child: LayoutBuilder(
              builder: (context, box) {
                // As on the dhikr counter: level with the top of the ring,
                // under the right edge of the card above.
                final side = math.max(
                  0.0,
                  math.min(box.maxWidth, box.maxHeight) - 32,
                );
                return Stack(
                  children: [
                    PositionedDirectional(
                      top: (box.maxHeight - side) / 2,
                      end: box.maxWidth * 0.04 + 10,
                      child: IconButton.filledTonal(
                        tooltip: l.salawatReset,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: count == 0
                            ? null
                            : () => controller.resetSalawatToday(today),
                      ),
                    ),
                    Center(
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
                                HapticFeedback.lightImpact();
                                controller.addSalawat(today);
                              },
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(end: math.min(1, count / goal)),
                                duration: const Duration(milliseconds: 250),
                                builder: (context, progress, child) =>
                                    CustomPaint(
                                      painter: _RingPainter(progress, scheme),
                                      child: child,
                                    ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        l.salawatToday,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                            ),
                                      ),
                                      Text(
                                        '$count',
                                        style: theme.textTheme.displayLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w300,
                                              color: scheme.onSurface,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                      ),
                                      Text(
                                        l.ofGoal(goal),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
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
                  ],
                );
              },
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

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.scheme);

  final double progress;
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 8;
    canvas.drawCircle(
      center,
      radius - 8,
      Paint()..color = scheme.surfaceContainerLow,
    );
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(
      center,
      radius,
      ring..color = scheme.surfaceContainerHighest,
    );
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        ring..color = scheme.primary,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.scheme != scheme;
}
