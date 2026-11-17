import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/content/hadith.dart';
import '../../l10n/app_localizations.dart';
import '../../services/share.dart';
import '../../state/app_settings.dart';
import '../../state/content_providers.dart';
import '../widgets.dart';

/// The hadith of a day, with the Arabic original and the translation.
/// Arrows step to the hadith of the previous and next days. With [number]
/// it shows that one hadith instead, for the list of favourites.
class HadithScreen extends ConsumerStatefulWidget {
  const HadithScreen({super.key, required this.initialDay, this.number});

  /// Day number as returned by [dayNumber].
  final int initialDay;

  /// The number of a hadith in Sahih al-Bukhari.
  final int? number;

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
    final favorites = ref.watch(
      settingsProvider.select((s) => s.hadithFavorites),
    );
    final single = widget.number != null;

    final hadiths = pool.value ?? const <Hadith>[];
    final Hadith? hadith = hadiths.isEmpty
        ? null
        : single
        ? hadiths.where((h) => h.number == widget.number).firstOrNull
        : hadiths[dailyHadithIndex(_day, hadiths.length)];
    final favorite = hadith != null && favorites.contains(hadith.number);

    return Scaffold(
      appBar: AppBar(
        title: Text(single ? l.favoriteHadiths : l.hadithOfDay),
        actions: [
          if (hadith != null)
            IconButton(
              tooltip: favorite ? l.favoriteRemove : l.favoriteAdd,
              icon: Icon(
                favorite ? Icons.star : Icons.star_border,
                color: favorite ? scheme.primary : null,
              ),
              onPressed: () => ref
                  .read(settingsProvider.notifier)
                  .toggleHadithFavorite(hadith.number),
            ),
          if (!single)
            IconButton(
              tooltip: l.favoriteHadiths,
              icon: const Icon(Icons.format_list_bulleted),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FavoriteHadithsScreen(),
                ),
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: pool.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (_) {
          if (hadith == null) return const SizedBox.shrink();
          final translation = language == 'ar'
              ? null
              : hadith.translation(language);
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
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
                      if (!single)
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
                          await Clipboard.setData(
                            ClipboardData(
                              text: [
                                hadith.arabic,
                                ?translation,
                                reference,
                              ].join('\n\n'),
                            ),
                          );
                          messenger.showSnackBar(
                            SnackBar(content: Text(l.copied)),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: l.share,
                        icon: const ShareIcon(),
                        onPressed: () => shareOut(
                          shareText([hadith.arabic, translation, reference]),
                        ),
                      ),
                      const Spacer(),
                      // Later days are not shown ahead of time.
                      if (!single)
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

/// The hadiths the user marked with the star, the latest first.
class FavoriteHadithsScreen extends ConsumerWidget {
  const FavoriteHadithsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final pool = ref.watch(hadithPoolProvider).value ?? const <Hadith>[];
    final byNumber = {for (final h in pool) h.number: h};
    final favorites = [
      for (final n in ref.watch(
        settingsProvider.select((s) => s.hadithFavorites),
      ))
        ?byNumber[n],
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.favoriteHadiths)),
      body: favorites.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l.noFavoriteHadiths,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: favorites.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final h = favorites[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            HadithScreen(initialDay: 0, number: h.number),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        18,
                        14,
                        6,
                        14,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h.translation(language),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: language == 'ar'
                                      ? TextDirection.rtl
                                      : null,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l.bukhariRef(h.number),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: l.favoriteRemove,
                            icon: Icon(Icons.star, color: scheme.primary),
                            onPressed: () => ref
                                .read(settingsProvider.notifier)
                                .toggleHadithFavorite(h.number),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
