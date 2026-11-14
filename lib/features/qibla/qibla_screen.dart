import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/qibla.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../location/city_picker_screen.dart';

/// Compass headings in degrees from north, or null values when the device
/// has no sensor. Tests replace it.
final compassProvider = Provider<Stream<double?> Function()>((ref) {
  return () {
    if (kIsWeb) return Stream<double?>.value(null);
    final events = FlutterCompass.events;
    if (events == null) return Stream<double?>.value(null);
    return events.map((e) => e.heading);
  };
});

/// Within this many degrees the phone counts as facing the qibla.
const _alignedWithin = 3.0;

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key, required this.active});

  /// The compass is only read while the tab is shown, to spare the battery.
  final bool active;

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  StreamSubscription<double?>? _subscription;
  double? _heading;
  bool _noSensor = false;

  @override
  void initState() {
    super.initState();
    if (widget.active) _listen();
  }

  @override
  void didUpdateWidget(QiblaScreen old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _listen();
    if (!widget.active && old.active) _stop();
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  void _listen() {
    _subscription = ref.read(compassProvider)().listen(
      (heading) {
        if (!mounted) return;
        setState(() {
          _heading = heading;
          _noSensor = heading == null;
        });
      },
      onError: (Object _) {
        if (mounted) setState(() => _noSensor = true);
      },
    );
  }

  void _stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final place = ref.watch(settingsProvider.select((s) => s.place));

    Widget body;
    if (place == null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.explore_outlined, size: 56, color: scheme.primary),
              const SizedBox(height: 16),
              Text(
                l.qiblaNeedsPlace,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CityPickerScreen(),
                  ),
                ),
                child: Text(l.chooseCity),
              ),
            ],
          ),
        ),
      );
    } else {
      final bearing = qiblaBearing(place.latitude, place.longitude);
      final heading = _heading;
      final turn = heading == null ? null : angleDifference(heading, bearing);
      final aligned = turn != null && turn.abs() <= _alignedWithin;

      final String status;
      if (turn == null) {
        status = _noSensor ? l.qiblaNoSensor : l.qiblaCalibrate;
      } else if (aligned) {
        status = l.qiblaAligned;
      } else if (turn > 0) {
        status = l.qiblaTurnRight(turn.round().toString());
      } else {
        status = l.qiblaTurnLeft((-turn).round().toString());
      }

      body = ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Text(
            place.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            l.qiblaDirection(bearing.round().toString()),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: _DialPainter(
                    // Without a sensor the dial is drawn north-up, so the
                    // arrow still shows the bearing on a map.
                    heading: heading ?? 0,
                    bearing: bearing,
                    aligned: aligned,
                    scheme: scheme,
                    north: l.localeName == 'ru'
                        ? 'С'
                        : l.localeName == 'ar'
                            ? 'ش'
                            : 'N',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: aligned
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  aligned
                      ? Icons.check_circle
                      : turn == null
                          ? Icons.info_outline
                          : turn > 0
                              ? Icons.rotate_right
                              : Icons.rotate_left,
                  color: aligned ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    status,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: aligned
                          ? scheme.onPrimaryContainer
                          : scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (turn != null) ...[
            const SizedBox(height: 12),
            Text(
              l.qiblaCalibrate,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
            ),
          ],
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.navQibla)),
      body: body,
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.heading,
    required this.bearing,
    required this.aligned,
    required this.scheme,
    required this.north,
  });

  final double heading;
  final double bearing;
  final bool aligned;
  final ColorScheme scheme;
  final String north;

  double _rad(double degrees) => degrees * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = scheme.surfaceContainerHigh,
    );
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = aligned ? scheme.primary : scheme.outlineVariant,
    );

    // The dial turns against the heading so that north stays north.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-_rad(heading));

    final tick = Paint()
      ..color = scheme.outline
      ..strokeCap = StrokeCap.round;
    for (var d = 0; d < 360; d += 10) {
      final major = d % 90 == 0;
      final medium = d % 30 == 0;
      tick.strokeWidth = major ? 3 : 1.5;
      final inner = radius - (major ? 30 : medium ? 24 : 18);
      final a = _rad(d.toDouble()) - math.pi / 2;
      canvas.drawLine(
        Offset(math.cos(a) * inner, math.sin(a) * inner),
        Offset(math.cos(a) * (radius - 12), math.sin(a) * (radius - 12)),
        tick,
      );
    }

    final label = TextPainter(
      text: TextSpan(
        text: north,
        style: TextStyle(
          color: scheme.error,
          fontSize: radius * 0.14,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(
      canvas,
      Offset(-label.width / 2, -radius + 34),
    );

    // Qibla arrow, fixed to the dial at the bearing.
    canvas.rotate(_rad(bearing));
    final arrowColor = aligned ? scheme.primary : scheme.tertiary;
    final tip = -(radius - 40);
    canvas.drawLine(
      Offset.zero,
      Offset(0, tip + 26),
      Paint()
        ..color = arrowColor
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, tip)
        ..lineTo(-15, tip + 32)
        ..lineTo(15, tip + 32)
        ..close(),
      Paint()..color = arrowColor,
    );
    // A small Kaaba mark at the base of the arrowhead.
    final kaaba = Rect.fromCenter(
      center: Offset(0, tip + 52),
      width: 22,
      height: 22,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(kaaba, const Radius.circular(3)),
      Paint()..color = const Color(0xFF1B1B1B),
    );
    canvas.drawRect(
      Rect.fromLTWH(kaaba.left, kaaba.top + 5, kaaba.width, 3),
      Paint()..color = const Color(0xFFD4AF37),
    );
    canvas.restore();

    canvas.drawCircle(center, 7, Paint()..color = arrowColor);

    // Fixed mark at the top: the direction the phone points.
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy - radius + 12)
        ..lineTo(center.dx - 9, center.dy - radius - 4)
        ..lineTo(center.dx + 9, center.dy - radius - 4)
        ..close(),
      Paint()..color = scheme.onSurface,
    );
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.heading != heading ||
      old.bearing != bearing ||
      old.aligned != aligned ||
      old.scheme != scheme;
}
