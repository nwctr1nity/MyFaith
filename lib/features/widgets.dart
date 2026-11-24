import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// The curved arrow people know as "share": the reply arrow turned the
/// other way.
class ShareIcon extends StatelessWidget {
  const ShareIcon({super.key});

  @override
  Widget build(BuildContext context) =>
      Transform.flip(flipX: true, child: const Icon(Icons.reply));
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// A paragraph of secondary explanatory text inside a settings list.
class HintText extends StatelessWidget {
  const HintText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 8),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
      ),
    );
  }
}

/// Opens a bottom sheet with [options] and returns the picked one through
/// [onSelected].
Future<void> pickOption<T>(
  BuildContext context, {
  required String title,
  required T selected,
  required Map<T, String> options,
  required void Function(T) onSelected,
}) async {
  final entry = await showModalBottomSheet<MapEntry<T, String>>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: options.length > 6 ? 0.8 : 0.5,
      builder: (context, scroll) => ListView(
        controller: scroll,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          for (final e in options.entries)
            ListTile(
              title: Text(e.value),
              trailing: e.key == selected ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop(e),
            ),
        ],
      ),
    ),
  );
  if (entry != null) onSelected(entry.key);
}

/// A ring that fills as a counter nears its goal.
class RingPainter extends CustomPainter {
  RingPainter(this.progress, this.scheme, {this.stroke = 12, this.fill = true});

  final double progress;
  final ColorScheme scheme;
  final double stroke;

  /// Whether the inside of the ring is tinted.
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - stroke / 2 - 2;
    if (fill) {
      canvas.drawCircle(
        center,
        radius - stroke / 2 - 2,
        Paint()..color = scheme.surfaceContainerLow,
      );
    }
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(
      center,
      radius,
      ring..color = scheme.surfaceContainerHighest,
    );
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.5707963267948966,
        6.283185307179586 * progress.clamp(0, 1),
        false,
        ring..color = scheme.primary,
      );
    }
  }

  @override
  bool shouldRepaint(RingPainter old) =>
      old.progress != progress || old.scheme != scheme;
}

/// The card of one wording on a counter screen. When the text is longer
/// than the card, a thin thumb on the edge shows that it scrolls.
class ScrollCard extends StatefulWidget {
  const ScrollCard({super.key, required this.children});

  final List<Widget> children;

  @override
  State<ScrollCard> createState() => _ScrollCardState();
}

class _ScrollCardState extends State<ScrollCard> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: WidgetStatePropertyAll(
              scheme.primary.withValues(alpha: 0.45),
            ),
            thickness: const WidgetStatePropertyAll(3),
            radius: const Radius.circular(2),
            crossAxisMargin: 5,
            mainAxisMargin: 18,
          ),
          child: Scrollbar(
            controller: _scroll,
            thumbVisibility: true,
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(20),
              children: widget.children,
            ),
          ),
        ),
      ),
    );
  }
}

/// The row of dots under a pager: which card is open and how many there are.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == index ? scheme.primary : scheme.outlineVariant,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}

/// The big round counter shared by salawat, dhikr and dua: tap anywhere on
/// it to count, with a small reset button level with its top edge.
class CounterRing extends StatelessWidget {
  const CounterRing({
    super.key,
    required this.count,
    required this.goal,
    required this.caption,
    required this.goalText,
    required this.tapLabel,
    required this.resetLabel,
    required this.onTap,
    required this.onReset,
  });

  final int count;
  final int goal;

  /// The word above the number, "Today".
  final String caption;
  final String goalText;
  final String tapLabel;
  final String resetLabel;
  final VoidCallback onTap;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, box) {
        // The ring is the largest square that fits. Its painted edge sits
        // two pixels inside that square; the button starts on that line,
        // under the right edge of the card above.
        final side = math.max(0.0, math.min(box.maxWidth, box.maxHeight) - 32);
        return Stack(
          children: [
            PositionedDirectional(
              top: (box.maxHeight - side) / 2 + 2,
              end: box.maxWidth * 0.04 + 10,
              child: Tooltip(
                message: resetLabel,
                child: Material(
                  color: scheme.secondaryContainer,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: count == 0 ? null : onReset,
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(
                        Icons.refresh,
                        size: 20,
                        color: count == 0
                            ? scheme.onSurface.withValues(alpha: 0.38)
                            : scheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Semantics(
                    button: true,
                    label: tapLabel,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // A longer buzz tells the hand the goal is reached.
                        count + 1 == goal
                            ? HapticFeedback.heavyImpact()
                            : HapticFeedback.lightImpact();
                        onTap();
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
                                caption,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
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
                                goalText,
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
          ],
        );
      },
    );
  }
}
