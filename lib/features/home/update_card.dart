import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../../state/update_provider.dart';

/// Offers a newer version when one is out; otherwise takes no room.
class UpdateCard extends ConsumerWidget {
  const UpdateCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(appUpdateProvider).value;
    if (update == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: scheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.updateAvailable(update.version),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l.updateHint,
                style: TextStyle(color: scheme.onSecondaryContainer),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Wrap(
                  spacing: 4,
                  children: [
                    TextButton(
                      onPressed: () => ref
                          .read(settingsProvider.notifier)
                          .setValue('updSkip', update.version),
                      child: Text(l.updateLater),
                    ),
                    FilledButton(
                      onPressed: () => launchUrl(
                        Uri.parse(update.url),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Text(l.updateDownload),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
