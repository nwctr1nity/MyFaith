import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

/// Where a voluntary donation can be sent. Nothing is opened: the details
/// are only shown and copied.
void showSupportDialog(BuildContext context) {
  showDialog<void>(context: context, builder: (_) => const _SupportDialog());
}

class _SupportDialog extends StatelessWidget {
  const _SupportDialog();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(l.supportProject),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.supportText, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            const _Plate(
              name: 'Kaspi',
              lines: ['4400 4303 1024 8544'],
              value: '4400430310248544',
              background: Color(0xFFE5242A),
              foreground: Colors.white,
            ),
            const SizedBox(height: 10),
            _Plate(
              name: l.tbank,
              lines: const ['2200 7010 9115 9639'],
              value: '2200701091159639',
              background: const Color(0xFFFFDD2D),
              foreground: Colors.black,
            ),
            const SizedBox(height: 10),
            // The address is shown on two lines and copied whole.
            const _Plate(
              name: 'USDT TRC-20',
              lines: ['TGaJLFVb1tgCFaNbg', 'gs1r25JGzFeKHENKo'],
              value: 'TGaJLFVb1tgCFaNbggs1r25JGzFeKHENKo',
              background: Color(0xFF0B5D45),
              foreground: Colors.white,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    );
  }
}

class _Plate extends StatelessWidget {
  const _Plate({
    required this.name,
    required this.lines,
    required this.value,
    required this.background,
    required this.foreground,
  });

  final String name;

  /// What is shown, line by line.
  final List<String> lines;

  /// What is copied.
  final String value;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: foreground.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 2),
                // Numbers and the address read left to right in Arabic too.
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      lines.join('\n'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l.copy,
            icon: Icon(Icons.copy_outlined, color: foreground),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await Clipboard.setData(ClipboardData(text: value));
              messenger.showSnackBar(SnackBar(content: Text(l.copied)));
            },
          ),
        ],
      ),
    );
  }
}
