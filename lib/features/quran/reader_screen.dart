import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../core/content/quran.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../../state/content_providers.dart';
import '../theme.dart';

/// Arabic font sizes for the five text-size steps.
const _arabicSizes = [22.0, 26.0, 30.0, 34.0, 40.0];
const _translationSizes = [14.0, 16.0, 17.0, 19.0, 21.0];

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.surah, this.initialAyah = 1});

  final SurahInfo surah;
  final int initialAyah;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final _positions = ItemPositionsListener.create();
  late int _topAyah = widget.initialAyah;

  /// The list has one header item before the ayahs.
  int get _headerItems => 1;

  @override
  void initState() {
    super.initState();
    _positions.itemPositions.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveLastRead());
  }

  @override
  void dispose() {
    _positions.itemPositions.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final visible = _positions.itemPositions.value
        .where((p) => p.itemTrailingEdge > 0.08);
    if (visible.isEmpty) return;
    final first =
        visible.reduce((a, b) => a.index < b.index ? a : b).index;
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

  void _openTafsir(int ayah, String arabic) {
    final language = Localizations.localeOf(context).languageCode;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _TafsirSheet(
        surah: widget.surah,
        ayah: ayah,
        arabic: arabic,
        language: language,
      ),
    );
  }

  void _openOptions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _ReaderOptions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final surah = widget.surah;
    final text = ref.watch(surahTextProvider(surah.number));
    final showTranslation =
        ref.watch(settingsProvider.select((s) => s.quranShowTranslation));
    final step = ref.watch(settingsProvider.select((s) => s.quranFontStep));
    final marks = {
      for (final b
          in ref.watch(settingsProvider.select((s) => s.bookmarks)))
        b.key,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(surah.localizedName(language)),
        actions: [
          IconButton(
            tooltip: l.textSize,
            icon: const Icon(Icons.text_fields),
            onPressed: _openOptions,
          ),
        ],
      ),
      body: text.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (content) {
          final translation =
              showTranslation ? content.translation(language) : null;
          return ScrollablePositionedList.builder(
            itemCount: content.arabic.length + _headerItems,
            initialScrollIndex: widget.initialAyah <= 1
                ? 0
                : (widget.initialAyah - 1 + _headerItems)
                    .clamp(0, content.arabic.length),
            itemPositionsListener: _positions,
            padding: const EdgeInsets.only(bottom: 32),
            itemBuilder: (context, i) {
              if (i == 0) {
                return _SurahHeader(surah: surah, language: language);
              }
              final ayah = i;
              final ref_ = AyahRef(surah.number, ayah);
              final arabic = content.arabic[ayah - 1];
              final translated = translation != null &&
                      ayah <= translation.length
                  ? translation[ayah - 1]
                  : null;
              final marked = marks.contains(ref_.key);
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: scheme.outlineVariant),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      arabic,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.start,
                      style: quranTextStyle(
                        _arabicSizes[step],
                        scheme.onSurface,
                      ),
                    ),
                    if (translated != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        translated,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: _translationSizes[step],
                          height: 1.55,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${surah.number}:$ayah',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _openTafsir(ayah, arabic),
                          icon: const Icon(Icons.auto_stories_outlined,
                              size: 18),
                          label: Text(l.tafsir),
                        ),
                        IconButton(
                          tooltip: l.copy,
                          icon: const Icon(Icons.copy_outlined, size: 20),
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await Clipboard.setData(ClipboardData(
                              text: [
                                arabic,
                                ?translated,
                                '(${surah.number}:$ayah)',
                              ].join('\n'),
                            ));
                            messenger.showSnackBar(
                              SnackBar(content: Text(l.copied)),
                            );
                          },
                        ),
                        IconButton(
                          tooltip: marked ? l.removeBookmark : l.addBookmark,
                          icon: Icon(
                            marked ? Icons.bookmark : Icons.bookmark_border,
                            color: marked ? scheme.primary : null,
                            size: 22,
                          ),
                          onPressed: () => ref
                              .read(settingsProvider.notifier)
                              .toggleBookmark(ref_),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({required this.surah, required this.language});

  final SurahInfo surah;
  final String language;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: heroGradient(scheme),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Text(
              surah.arabicName,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: quranFont,
                fontSize: 26,
                color: onHero,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              [
                surah.makkan ? l.makkan : l.madinan,
                l.ayahCount(surah.ayahCount),
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(color: onHeroMuted),
            ),
            if (surah.showsBasmalaHeader) ...[
              const SizedBox(height: 12),
              const Text(
                basmala,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: quranFont,
                  fontSize: 24,
                  height: 1.8,
                  color: onHero,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReaderOptions extends ConsumerWidget {
  const _ReaderOptions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final language = Localizations.localeOf(context).languageCode;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // There is no translation to show when the interface is Arabic.
          if (language != 'ar')
            SwitchListTile(
              title: Text(l.showTranslation),
              value: settings.quranShowTranslation,
              onChanged: (v) => controller.setValue('qTrans', v),
            ),
          ListTile(
            title: Text(l.textSize),
            subtitle: Slider(
              value: settings.quranFontStep.toDouble(),
              max: 4,
              divisions: 4,
              onChanged: (v) => controller.setValue('qFont', v.round()),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TafsirSheet extends ConsumerWidget {
  const _TafsirSheet({
    required this.surah,
    required this.ayah,
    required this.arabic,
    required this.language,
  });

  final SurahInfo surah;
  final int ayah;
  final String arabic;
  final String language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tafsir = ref.watch(tafsirProvider((language, surah.number)));
    final rtl = tafsirLanguage(language) == 'ar';
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Text(
            '${l.tafsir} · ${l.surahAyah(surah.localizedName(language), ayah)}',
            style: theme.textTheme.titleMedium,
          ),
          Text(
            l.tafsirSource,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(
            arabic,
            textDirection: TextDirection.rtl,
            style: quranTextStyle(24, scheme.onSurface),
          ),
          const Divider(height: 32),
          tafsir.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Text('$error'),
            data: (entries) => SelectableText(
              ayah <= entries.length ? entries[ayah - 1] : '',
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
