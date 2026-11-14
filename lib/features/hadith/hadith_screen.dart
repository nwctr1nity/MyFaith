import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/content/hadith.dart';
import '../../l10n/app_localizations.dart';
import '../../state/content_providers.dart';

/// The hadith of a day, with the Arabic original and the translation.
/// Arrows step to the hadith of the previous and next days.
class HadithScreen extends ConsumerStatefulWidget {
  const HadithScreen({super.key, required this.initialDay});

  /// Day number as returned by [dayNumber].
  final int initialDay;

  @override
  ConsumerState<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends ConsumerState<HadithScreen> {
  late int _day = widget.initialDay;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final pool = ref.watch(hadithPoolProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.hadithOfDay)),
      body: pool.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (hadiths) {
          if (hadiths.isEmpty) return const SizedBox.shrink();
          final hadith = hadiths[dailyHadithIndex(_day, hadiths.length)];
          final translation =
              language == 'ar' ? null : hadith.translation(language);
          final reference = l.bukhariRef(hadith.number);
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: SelectableText(
                        hadith.arabic,
                        textAlign: TextAlign.start,
                        style: theme.textTheme.titleLarge?.copyWith(
                          height: 1.9,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    if (translation != null) ...[
                      const Divider(height: 40),
                      SelectableText(
                        translation,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      reference,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => setState(() => _day--),
                        icon: const Icon(Icons.chevron_left),
                        label: Text(l.previousDay),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: l.copy,
                        icon: const Icon(Icons.copy_outlined),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await Clipboard.setData(ClipboardData(
                            text: [
                              hadith.arabic,
                              ?translation,
                              reference,
                            ].join('\n\n'),
                          ));
                          messenger.showSnackBar(
                            SnackBar(content: Text(l.copied)),
                          );
                        },
                      ),
                      const Spacer(),
                      // Later days are not shown ahead of time.
                      TextButton.icon(
                        onPressed: _day < widget.initialDay
                            ? () => setState(() => _day++)
                            : null,
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.chevron_right),
                        label: Text(l.nextDay),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
