import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../core/content/quran.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../../state/content_providers.dart';
import '../../state/quran_audio.dart';
import 'reader_common.dart';

/// One surah as a list of ayahs.
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.surah, this.initialAyah = 1});

  final SurahInfo surah;
  final int initialAyah;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final _positions = ItemPositionsListener.create();
  final _scroll = ItemScrollController();
  final _open = OpenTafsirs();
  late int _topAyah = widget.initialAyah;

  /// The list has one header item before the ayahs.
  static const _headerItems = 1;

  @override
  void initState() {
    super.initState();
    _positions.itemPositions.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveLastRead());
  }

  @override
  void dispose() {
    _positions.itemPositions.removeListener(_onScroll);
    _open.dispose();
    super.dispose();
  }

  void _onScroll() {
    final visible = _positions.itemPositions.value.where(
      (p) => p.itemTrailingEdge > 0.08,
    );
    if (visible.isEmpty) return;
    final first = visible.reduce((a, b) => a.index < b.index ? a : b).index;
    final ayah = (first - _headerItems + 1).clamp(1, widget.surah.ayahCount);
    if (ayah != _topAyah) {
      _topAyah = ayah;
      _saveLastRead();
    }
  }

  void _saveLastRead() {
    if (!mounted) return;
    ref
        .read(settingsProvider.notifier)
        .setLastRead(AyahRef(widget.surah.number, _topAyah));
  }

  /// Keeps the ayah being recited on screen.
  void _follow(Verse? verse) {
    if (verse == null || verse.$1 != widget.surah.number) return;
    if (!_scroll.isAttached) return;
    final shown = _positions.itemPositions.value.any(
      (p) =>
          p.index == verse.$2 &&
          p.itemLeadingEdge >= 0 &&
          p.itemTrailingEdge <= 1,
    );
    if (shown) return;
    _scroll.scrollTo(
      index: verse.$2,
      duration: const Duration(milliseconds: 350),
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final language = Localizations.localeOf(context).languageCode;
    final surah = widget.surah;
    final text = ref.watch(surahTextProvider(surah.number));
    final layout = ref.watch(mushafLayoutProvider).value;
    ref.listen(quranAudioProvider.select((s) => s.verse), (_, v) => _follow(v));

    return Scaffold(
      appBar: AppBar(
        title: Text(surah.titleWithMeaning(language)),
        actions: [
          IconButton(
            tooltip: l.listen,
            icon: const Icon(Icons.play_circle_outline),
            onPressed: () => ref.read(quranAudioProvider.notifier).play((
              surah.number,
              _topAyah,
            )),
          ),
          IconButton(
            tooltip: l.readerOptions,
            icon: const Icon(Icons.tune),
            onPressed: () => showReaderOptions(context),
          ),
        ],
      ),
      bottomNavigationBar: const QuranPlayerBar(),
      body: text.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (content) => ScrollablePositionedList.builder(
          itemCount: content.arabic.length + _headerItems,
          initialScrollIndex: widget.initialAyah <= 1
              ? 0
              : (widget.initialAyah - 1 + _headerItems).clamp(
                  0,
                  content.arabic.length,
                ),
          itemPositionsListener: _positions,
          itemScrollController: _scroll,
          padding: const EdgeInsets.only(bottom: 32),
          itemBuilder: (context, i) => i == 0
              ? SurahBanner(surah: surah)
              : AyahView(
                  surah: surah,
                  ayah: i,
                  content: content,
                  open: _open,
                  layout: layout,
                ),
        ),
      ),
    );
  }
}
