import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/content/quran.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../../state/content_providers.dart';
import '../theme.dart';
import 'bookmarks_screen.dart';
import 'reader_screen.dart';

String _fold(String text) => text
    .toLowerCase()
    .replaceAll('ё', 'е')
    .replaceAll(RegExp(r"[\-'’ ]"), '');

void openReader(BuildContext context, SurahInfo surah, {int ayah = 1}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ReaderScreen(surah: surah, initialAyah: ayah),
    ),
  );
}

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final index = ref.watch(surahIndexProvider);
    final lastRead = ref.watch(settingsProvider.select((s) => s.lastRead));

    return Scaffold(
      appBar: AppBar(
        title: Text(l.navQuran),
        actions: [
          IconButton(
            tooltip: l.bookmarks,
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BookmarksScreen()),
            ),
          ),
        ],
      ),
      body: index.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (surahs) {
          final q = _fold(_query);
          final number = int.tryParse(_query.trim());
          final shown = q.isEmpty
              ? surahs
              : [
                  for (final s in surahs)
                    if (s.number == number ||
                        _fold(s.name).contains(q) ||
                        _fold(s.russianName).contains(q) ||
                        _fold(s.englishMeaning).contains(q) ||
                        s.arabicName.contains(_query.trim()))
                      s,
                ];
          final last = lastRead == null || lastRead.surah > surahs.length
              ? null
              : surahs[lastRead.surah - 1];
          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                sliver: SliverList.list(
                  children: [
                    if (last != null && q.isEmpty) ...[
                      _ContinueCard(
                        title: l.continueReading,
                        subtitle: l.surahAyah(
                          last.localizedName(language),
                          lastRead!.ayah,
                        ),
                        onTap: () =>
                            openReader(context, last, ayah: lastRead.ayah),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SearchBar(
                      hintText: l.searchSurah,
                      leading: const Padding(
                        padding: EdgeInsetsDirectional.only(start: 8),
                        child: Icon(Icons.search),
                      ),
                      elevation: const WidgetStatePropertyAll(0),
                      backgroundColor:
                          WidgetStatePropertyAll(scheme.surfaceContainerHigh),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ],
                ),
              ),
              SliverList.builder(
                itemCount: shown.length,
                itemBuilder: (context, i) {
                  final s = shown[i];
                  return ListTile(
                    leading: _NumberBadge(s.number),
                    title: Text(s.localizedName(language)),
                    subtitle: Text(
                      [
                        if (language == 'en') s.englishMeaning,
                        if (language == 'ru') s.name,
                        s.makkan ? l.makkan : l.madinan,
                        l.ayahCount(s.ayahCount),
                      ].join(' · '),
                    ),
                    trailing: language == 'ar'
                        ? null
                        : Text(
                            s.arabicName.replaceFirst(RegExp(r'^\S+\s'), ''),
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: quranFont,
                              fontSize: 18,
                              color: scheme.primary,
                            ),
                          ),
                    onTap: () => openReader(context, s),
                  );
                },
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
            ],
          );
        },
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(gradient: heroGradient(theme.colorScheme)),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: onHeroMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(color: onHero),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.menu_book, color: onHero, size: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge(this.number);

  final int number;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$number',
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
