import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../labels.dart';
import '../widgets.dart';

/// Prayers to make up. Every prayer counts as prayed until the user marks
/// it as missed, so this list is empty for most people.
class QadaScreen extends ConsumerWidget {
  const QadaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final qada = ref.watch(settingsProvider.select((s) => s.qada));
    final controller = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l.qadaTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          HintText(l.qadaHint),
          for (final entry in qada.entries)
            ListTile(
              title: Text(prayerName(l, entry.key)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: l.qadaMadeUp,
                    icon: const Icon(Icons.remove),
                    onPressed: entry.value == 0
                        ? null
                        : () => controller.changeQada(entry.key, -1),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '${entry.value}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l.qadaAdd,
                    icon: const Icon(Icons.add),
                    onPressed: () => controller.changeQada(entry.key, 1),
                  ),
                ],
              ),
            ),
          HintText(l.qadaButtonsHint),
        ],
      ),
    );
  }
}
