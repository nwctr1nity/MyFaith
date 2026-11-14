import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../../state/content_providers.dart';
import 'quran_screen.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final surahs = ref.watch(surahIndexProvider).value ?? const [];
    final bookmarks = [
      for (final b in ref.watch(settingsProvider.select((s) => s.bookmarks)))
        if (b.surah >= 1 && b.surah <= surahs.length) b,
    ]..sort((a, b) =>
        a.surah != b.surah ? a.surah - b.surah : a.ayah - b.ayah);

    return Scaffold(
      appBar: AppBar(title: Text(l.bookmarks)),
      body: bookmarks.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l.noBookmarks,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : ListView(
              children: [
                for (final b in bookmarks)
                  ListTile(
                    leading: Icon(
                      Icons.bookmark,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      l.surahAyah(
                        surahs[b.surah - 1].localizedName(language),
                        b.ayah,
                      ),
                    ),
                    trailing: IconButton(
                      tooltip: l.removeBookmark,
                      icon: const Icon(Icons.close),
                      onPressed: () => ref
                          .read(settingsProvider.notifier)
                          .toggleBookmark(b),
                    ),
                    onTap: () => openReader(
                      context,
                      surahs[b.surah - 1],
                      ayah: b.ayah,
                    ),
                  ),
              ],
            ),
    );
  }
}
