import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/content/quran.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../../state/content_providers.dart';
import '../theme.dart';
import 'bookmarks_screen.dart';
import 'mushaf_screen.dart';
import 'reader_screen.dart';
import 'search_screen.dart';

void openReader(BuildContext context, SurahInfo surah, {int ayah = 1}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ReaderScreen(surah: surah, initialAyah: ayah),
    ),
  );
}

void openMushaf(BuildContext context, int page, {Verse? focus}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MushafScreen(initialPage: page, focus: focus),
    ),
  );
}

class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    void open(Widget screen) =>
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => screen));
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.navQuran),
          actions: [
            IconButton(
              tooltip: l.searchQuran,
              icon: const Icon(Icons.search),
              onPressed: () => open(const QuranSearchScreen()),
            ),
            IconButton(
              tooltip: l.bookmarks,
              icon: const Icon(Icons.bookmarks_outlined),
              onPressed: () => open(const BookmarksScreen()),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l.surahs),
              Tab(text: l.mushaf),
            ],
          ),
        ),
        body: const TabBarView(children: [_SurahsTab(), _MushafTab()]),
      ),
    );
  }
}

class _SurahsTab extends ConsumerStatefulWidget {
  const _SurahsTab();

  @override
  ConsumerState<_SurahsTab> createState() => _SurahsTabState();
}

class _SurahsTabState extends ConsumerState<_SurahsTab>
    with AutomaticKeepAliveClientMixin {
  String _query = '';

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final index = ref.watch(surahIndexProvider);
    final lastRead = ref.watch(settingsProvider.select((s) => s.lastRead));

    return index.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('$error')),
      data: (surahs) {
        final searching = _query.trim().isNotEmpty;
        final shown = searching
            ? [
                for (final s in surahs)
                  if (s.matches(_query)) s,
              ]
            : surahs;
        final last = lastRead == null || lastRead.surah > surahs.length
            ? null
            : surahs[lastRead.surah - 1];
        return CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              sliver: SliverList.list(
                children: [
                  if (last != null && !searching) ...[
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
                    backgroundColor: WidgetStatePropertyAll(
                      scheme.surfaceContainerHigh,
                    ),
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
                  title: Text(s.titleWithMeaning(language)),
                  subtitle: Text(
                    [
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
    );
  }
}

class _MushafTab extends ConsumerStatefulWidget {
  const _MushafTab();

  @override
  ConsumerState<_MushafTab> createState() => _MushafTabState();
}

class _MushafTabState extends ConsumerState<_MushafTab>
    with AutomaticKeepAliveClientMixin {
  bool _byPage = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final layout = ref.watch(mushafLayoutProvider);
    final surahs = ref.watch(surahIndexProvider).value;
    final page = ref.watch(settingsProvider.select((s) => s.mushafPage));

    return layout.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('$error')),
      data: (layout) {
        String where(Verse v) => surahs == null
            ? ''
            : l.surahAyah(surahs[v.$1 - 1].localizedName(language), v.$2);
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              sliver: SliverList.list(
                children: [
                  _ContinueCard(
                    title: l.continueReading,
                    subtitle: [
                      l.pageNumber(page),
                      l.juzNumber(layout.juzOfPage(page)),
                    ].join(' · '),
                    onTap: () => openMushaf(context, page),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(value: false, label: Text(l.byJuz)),
                      ButtonSegment(value: true, label: Text(l.byPage)),
                    ],
                    selected: {_byPage},
                    onSelectionChanged: (v) =>
                        setState(() => _byPage = v.first),
                  ),
                ],
              ),
            ),
            if (!_byPage)
              SliverList.builder(
                itemCount: layout.juzCount,
                itemBuilder: (context, i) {
                  final start = layout.juzStarts[i];
                  final first = layout.pageOfJuz(i + 1);
                  return ListTile(
                    leading: _NumberBadge(i + 1),
                    title: Text(l.juzNumber(i + 1)),
                    subtitle: Text(where(start)),
                    trailing: Text(
                      l.pageNumber(first),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () => openMushaf(context, first, focus: start),
                  );
                },
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 72,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: layout.pageCount,
                  itemBuilder: (context, i) {
                    final current = i + 1 == page;
                    return Material(
                      color: current
                          ? scheme.primary
                          : scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => openMushaf(context, i + 1),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: current
                                  ? scheme.onPrimary
                                  : scheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        );
      },
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
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: onHeroMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: onHero,
                        ),
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
