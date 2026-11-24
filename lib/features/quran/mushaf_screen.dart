import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/content/quran.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../../state/content_providers.dart';
import '../../state/quran_audio.dart';
import 'reader_common.dart';

/// The Quran page by page, as in the Madinah mushaf. Each page scrolls
/// down ayah by ayah; pages turn sideways from right to left, as the
/// printed book does.
class MushafScreen extends ConsumerStatefulWidget {
  const MushafScreen({super.key, required this.initialPage, this.focus});

  final int initialPage;

  /// The verse to scroll to on the first page, if any.
  final Verse? focus;

  @override
  ConsumerState<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends ConsumerState<MushafScreen> {
  late final _pages = PageController(initialPage: widget.initialPage - 1);
  final _open = OpenTafsirs();
  late int _page = widget.initialPage;

  /// How far down each visited page has been scrolled, from 0 to 1.
  final _scrolled = <int, double>{};
  final _fraction = ValueNotifier<double>(0);

  void _onScroll(int page, double fraction) {
    _scrolled[page] = fraction;
    if (page == _page) _fraction.value = fraction;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _save());
  }

  @override
  void dispose() {
    _pages.dispose();
    _open.dispose();
    _fraction.dispose();
    super.dispose();
  }

  void _save() {
    if (!mounted) return;
    final layout = ref.read(mushafLayoutProvider).value;
    final controller = ref.read(settingsProvider.notifier);
    controller.setValue('qPage', _page);
    if (layout != null) {
      final first = layout.pageStarts[_page - 1];
      controller.setLastRead(AyahRef(first.$1, first.$2));
    }
  }

  /// Turns to the page of the ayah being recited.
  void _follow(Verse? verse) {
    final layout = ref.read(mushafLayoutProvider).value;
    if (verse == null || layout == null || !_pages.hasClients) return;
    final page = layout.pageOf(verse);
    if (page == _page) return;
    _pages.animateToPage(
      page - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final layout = ref.watch(mushafLayoutProvider);
    final surahs = ref.watch(surahIndexProvider).value;
    ref.listen(quranAudioProvider.select((s) => s.verse), (_, v) => _follow(v));

    return layout.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('$error'))),
      data: (layout) {
        final first = layout.pageStarts[_page - 1];
        final juz = layout.juzOfPage(_page);
        final title = surahs == null
            ? l.mushaf
            : surahs[first.$1 - 1].localizedName(language);
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                tooltip: l.listen,
                icon: const Icon(Icons.play_circle_outline),
                onPressed: () =>
                    ref.read(quranAudioProvider.notifier).play(first),
              ),
              IconButton(
                tooltip: l.readerOptions,
                icon: const Icon(Icons.tune),
                onPressed: () => showReaderOptions(context),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(46),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: ValueListenableBuilder<double>(
                  valueListenable: _fraction,
                  builder: (context, fraction, _) {
                    // The page bar fills as the page is read from its
                    // first ayah to its last; the juz bar counts the
                    // pages of the juz, this one included as far as read.
                    final juzFirst = layout.pageOfJuz(juz);
                    final juzEnd = juz < layout.juzCount
                        ? layout.pageOfJuz(juz + 1)
                        : layout.pageCount + 1;
                    final juzPages = math.max(1, juzEnd - juzFirst);
                    return Row(
                      children: [
                        Expanded(
                          child: _Progress(
                            label: l.pageOf(_page, layout.pageCount),
                            value: fraction,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _Progress(
                            label: l.juzOf(juz, layout.juzCount),
                            value: ((_page - juzFirst + fraction) / juzPages)
                                .clamp(0.0, 1.0),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          bottomNavigationBar: const QuranPlayerBar(),
          // Right to left in every language: the next page is to the left.
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: PageView.builder(
              controller: _pages,
              itemCount: layout.pageCount,
              onPageChanged: (i) {
                setState(() => _page = i + 1);
                _fraction.value = _scrolled[i + 1] ?? 0;
                _save();
              },
              itemBuilder: (context, i) => Directionality(
                textDirection: Directionality.of(this.context),
                child: _MushafPage(
                  key: ValueKey(i),
                  page: i + 1,
                  layout: layout,
                  surahs: surahs,
                  open: _open,
                  focus: i + 1 == widget.initialPage ? widget.focus : null,
                  background: scheme.surface,
                  onScroll: (f) => _onScroll(i + 1, f),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(value: value, minHeight: 6),
        ),
      ],
    );
  }
}

class _MushafPage extends ConsumerStatefulWidget {
  const _MushafPage({
    super.key,
    required this.page,
    required this.layout,
    required this.surahs,
    required this.open,
    required this.background,
    required this.onScroll,
    this.focus,
  });

  /// Reports how far down the page is scrolled, from 0 to 1.
  final ValueChanged<double> onScroll;

  final int page;
  final MushafLayout layout;
  final List<SurahInfo>? surahs;
  final OpenTafsirs open;
  final Color background;
  final Verse? focus;

  @override
  ConsumerState<_MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends ConsumerState<_MushafPage> {
  final _focusKey = GlobalKey();
  bool _focused = false;

  void _showFocus() {
    if (_focused) return;
    final context = _focusKey.currentContext;
    if (context == null) return;
    _focused = true;
    Scrollable.ensureVisible(context, alignment: 0.05);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surahs = widget.surahs;
    final verses = widget.layout.versesOn(widget.page);
    final texts = <int, SurahText>{};
    for (final n in {for (final v in verses) v.$1}) {
      final text = ref.watch(surahTextProvider(n)).value;
      if (text != null) texts[n] = text;
    }
    final ready =
        surahs != null &&
        verses.every(
          (v) => texts.containsKey(v.$1) && v.$2 <= texts[v.$1]!.arabic.length,
        );
    if (!ready) return const Center(child: CircularProgressIndicator());
    if (widget.focus != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showFocus());
    }

    // A page is short, so it is built whole: that lets it scroll straight
    // to any of its ayahs.
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (n) => _report(n.metrics),
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (n) => _report(n.metrics),
        child: _content(l, theme, surahs, verses, texts),
      ),
    );
  }

  bool _report(ScrollMetrics m) {
    if (m.axis != Axis.vertical) return false;
    final max = m.maxScrollExtent;
    // A page that fits on the screen is read as soon as it is open.
    final f = max <= 0 ? 1.0 : (m.pixels / max).clamp(0.0, 1.0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onScroll(f);
    });
    return false;
  }

  Widget _content(
    AppLocalizations l,
    ThemeData theme,
    List<SurahInfo> surahs,
    List<Verse> verses,
    Map<int, SurahText> texts,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final v in verses) ...[
            // A surah that begins on this page is announced by its banner,
            // wherever on the page it begins.
            if (v.$2 == 1) SurahBanner(surah: surahs[v.$1 - 1]),
            AyahView(
              key: v == widget.focus ? _focusKey : null,
              surah: surahs[v.$1 - 1],
              ayah: v.$2,
              content: texts[v.$1]!,
              open: widget.open,
              layout: widget.layout,
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              l.pageNumber(widget.page),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
