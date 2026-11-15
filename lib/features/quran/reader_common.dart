import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/content/quran.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../../state/content_providers.dart';
import '../../state/quran_audio.dart';
import '../theme.dart';
import '../widgets.dart';

/// Arabic font sizes for the five text-size steps.
const arabicSizes = [22.0, 26.0, 30.0, 34.0, 40.0];
const translationSizes = [14.0, 16.0, 17.0, 19.0, 21.0];

/// The colour of a tajweed rule, readable on the light and the dark theme.
Color tajweedColor(TajweedKind kind, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  switch (kind) {
    case TajweedKind.ghunnah:
      return dark ? const Color(0xFF4CCB5A) : const Color(0xFF168A16);
    case TajweedKind.qalqalah:
      return dark ? const Color(0xFF4FC3F7) : const Color(0xFF1689B5);
    case TajweedKind.maddNatural:
      return dark ? const Color(0xFFE0BE4A) : const Color(0xFFB08A12);
    case TajweedKind.maddArid:
      return dark ? const Color(0xFFFF9A3C) : const Color(0xFFE07A10);
    case TajweedKind.maddWajib:
      return dark ? const Color(0xFFFF5CC6) : const Color(0xFFE0149A);
    case TajweedKind.maddLazim:
      return dark ? const Color(0xFFF2545B) : const Color(0xFFB00010);
    case TajweedKind.tafkhim:
      return dark ? const Color(0xFF7C9BFF) : const Color(0xFF123A8C);
    case TajweedKind.silent:
      return dark ? const Color(0xFF8A8F98) : const Color(0xFF8A8A8A);
  }
}

/// The name of a tajweed colour and the rules it stands for.
(String, String) tajweedLabel(TajweedKind kind, AppLocalizations l) {
  switch (kind) {
    case TajweedKind.ghunnah:
      return (l.tajweedGhunnah, l.tajweedGhunnahHint);
    case TajweedKind.qalqalah:
      return (l.tajweedQalqalah, l.tajweedQalqalahHint);
    case TajweedKind.maddNatural:
      return (l.tajweedMaddNatural, l.tajweedMaddNaturalHint);
    case TajweedKind.maddArid:
      return (l.tajweedMaddArid, l.tajweedMaddAridHint);
    case TajweedKind.maddWajib:
      return (l.tajweedMaddWajib, l.tajweedMaddWajibHint);
    case TajweedKind.maddLazim:
      return (l.tajweedMaddLazim, l.tajweedMaddLazimHint);
    case TajweedKind.tafkhim:
      return (l.tajweedTafkhim, l.tajweedTafkhimHint);
    case TajweedKind.silent:
      return (l.tajweedSilent, l.tajweedSilentHint);
  }
}

/// The Arabic of an ayah as one span, coloured by [spans] when given.
TextSpan arabicSpan(
  String text,
  List<TajweedSpan> spans,
  TextStyle style,
  Brightness brightness,
) {
  if (spans.isEmpty) return TextSpan(text: text, style: style);
  final children = <TextSpan>[];
  var at = 0;
  for (final s in spans) {
    if (s.start < at || s.end > text.length) continue;
    if (s.start > at) children.add(TextSpan(text: text.substring(at, s.start)));
    children.add(
      TextSpan(
        text: text.substring(s.start, s.end),
        style: TextStyle(color: tajweedColor(s.kind, brightness)),
      ),
    );
    at = s.end;
  }
  if (at < text.length) children.add(TextSpan(text: text.substring(at)));
  return TextSpan(style: style, children: children);
}

/// Which ayahs have their tafsir unfolded. Kept above the list so that an
/// ayah stays open while it is scrolled out of view and back.
class OpenTafsirs extends ChangeNotifier {
  final _open = <String>{};

  bool contains(Verse v) => _open.contains('${v.$1}:${v.$2}');

  void toggle(Verse v) {
    final key = '${v.$1}:${v.$2}';
    _open.contains(key) ? _open.remove(key) : _open.add(key);
    notifyListeners();
  }
}

final _ayahButton = TextButton.styleFrom(
  padding: const EdgeInsets.symmetric(horizontal: 8),
  visualDensity: VisualDensity.compact,
);

/// One ayah: Arabic, transliteration, translation, and the tafsir that
/// unfolds underneath. A tap anywhere opens the menu of the ayah.
class AyahView extends ConsumerWidget {
  const AyahView({
    super.key,
    required this.surah,
    required this.ayah,
    required this.content,
    required this.open,
    this.layout,
  });

  final SurahInfo surah;
  final int ayah;
  final SurahText content;
  final OpenTafsirs open;
  final MushafLayout? layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final verse = (surah.number, ayah);
    final step = ref.watch(settingsProvider.select((s) => s.quranFontStep));
    final showTranslation = ref.watch(
      settingsProvider.select((s) => s.quranShowTranslation),
    );
    final showTransliteration = ref.watch(
      settingsProvider.select((s) => s.quranShowTransliteration),
    );
    final showTajweed = ref.watch(
      settingsProvider.select((s) => s.quranShowTajweed),
    );
    final marked = ref.watch(
      settingsProvider.select(
        (s) => s.bookmarks.contains(AyahRef(surah.number, ayah)),
      ),
    );
    final reciting = ref.watch(
      quranAudioProvider.select((s) => s.verse == verse),
    );

    String? at(List<String>? list) =>
        list != null && ayah <= list.length ? list[ayah - 1] : null;
    final arabic = content.arabic[ayah - 1];
    final translated = showTranslation
        ? at(content.translation(language))
        : null;
    final transliterated = showTransliteration
        ? at(content.transliteration(language))
        : null;

    return Material(
      color: reciting
          ? scheme.primaryContainer.withValues(alpha: 0.35)
          : Colors.transparent,
      child: InkWell(
        onTap: () => showAyahMenu(
          context,
          surah: surah,
          ayah: ayah,
          content: content,
          open: open,
          layout: layout,
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(
                arabicSpan(
                  arabic,
                  showTajweed ? content.tajweedOf(ayah) : const [],
                  quranTextStyle(arabicSizes[step], scheme.onSurface),
                  scheme.brightness,
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.start,
              ),
              if (transliterated != null) ...[
                const SizedBox(height: 10),
                Text(
                  transliterated,
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: translationSizes[step],
                    height: 1.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (translated != null) ...[
                const SizedBox(height: 10),
                Text(
                  translated,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: translationSizes[step],
                    height: 1.55,
                    color: scheme.onSurface,
                  ),
                ),
              ],
              ListenableBuilder(
                listenable: open,
                builder: (context, _) {
                  final unfolded = open.contains(verse);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                          if (marked) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.bookmark,
                              size: 18,
                              color: scheme.primary,
                            ),
                          ],
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => open.toggle(verse),
                            style: _ayahButton,
                            icon: Icon(
                              unfolded ? Icons.expand_less : Icons.expand_more,
                              size: 18,
                            ),
                            label: Text(l.tafsir),
                          ),
                          TextButton.icon(
                            onPressed: () => ref
                                .read(quranAudioProvider.notifier)
                                .play(verse),
                            style: _ayahButton,
                            icon: const Icon(Icons.play_arrow, size: 18),
                            label: Text(l.listen),
                          ),
                        ],
                      ),
                      if (unfolded) _Tafsir(surah: surah.number, ayah: ayah),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tafsir extends ConsumerWidget {
  const _Tafsir({required this.surah, required this.ayah});

  final int surah;
  final int ayah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final tafsir = ref.watch(tafsirProvider((language, surah)));
    final rtl = tafsirLanguage(language) == 'ar';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.tafsirSource,
            style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary),
          ),
          const SizedBox(height: 6),
          tafsir.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Text('$error'),
            data: (entries) => Text(
              ayah <= entries.length ? entries[ayah - 1] : '',
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// The menu of one ayah: where it is, and everything that can be done
/// with it.
void showAyahMenu(
  BuildContext context, {
  required SurahInfo surah,
  required int ayah,
  required SurahText content,
  required OpenTafsirs open,
  MushafLayout? layout,
}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _AyahMenu(
      surah: surah,
      ayah: ayah,
      content: content,
      open: open,
      layout: layout,
    ),
  );
}

class _AyahMenu extends ConsumerWidget {
  const _AyahMenu({
    required this.surah,
    required this.ayah,
    required this.content,
    required this.open,
    this.layout,
  });

  final SurahInfo surah;
  final int ayah;
  final SurahText content;
  final OpenTafsirs open;
  final MushafLayout? layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final verse = (surah.number, ayah);
    final ref_ = AyahRef(surah.number, ayah);
    final marked = ref.watch(
      settingsProvider.select((s) => s.bookmarks.contains(ref_)),
    );
    final layout = this.layout ?? ref.watch(mushafLayoutProvider).value;
    final translation = content.translation(language);
    final translated = translation != null && ayah <= translation.length
        ? translation[ayah - 1]
        : null;

    void close() => Navigator.of(context).pop();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: heroGradient(scheme),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.ayahNumber(ayah),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: onHero,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.surahNumberName(
                        surah.number,
                        surah.titleWithMeaning(language),
                      ),
                      style: theme.textTheme.bodyLarge?.copyWith(color: onHero),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        surah.makkan ? l.makkan : l.madinan,
                        if (layout != null) ...[
                          l.pageNumber(layout.pageOf(verse)),
                          l.juzNumber(layout.juzOf(verse)),
                        ],
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onHeroMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: Text(l.listen),
              onTap: () {
                close();
                ref.read(quranAudioProvider.notifier).play(verse);
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_stories_outlined),
              title: Text(open.contains(verse) ? l.hideTafsir : l.tafsir),
              onTap: () {
                close();
                open.toggle(verse);
              },
            ),
            ListTile(
              leading: Icon(marked ? Icons.bookmark : Icons.bookmark_border),
              title: Text(marked ? l.removeBookmark : l.addBookmark),
              onTap: () {
                close();
                ref.read(settingsProvider.notifier).toggleBookmark(ref_);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: Text(l.copy),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                close();
                await Clipboard.setData(
                  ClipboardData(
                    text: [
                      content.arabic[ayah - 1],
                      ?translated,
                      '(${surah.number}:$ayah)',
                    ].join('\n'),
                  ),
                );
                messenger.showSnackBar(SnackBar(content: Text(l.copied)));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// The banner that opens a surah: its name, where it was revealed, and the
/// basmala. In the mushaf it also marks where a new surah starts in the
/// middle of a page.
class SurahBanner extends StatelessWidget {
  const SurahBanner({super.key, required this.surah});

  final SurahInfo surah;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: heroGradient(scheme),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
            if (language != 'ar') ...[
              const SizedBox(height: 2),
              Text(
                l.surahNumberName(
                  surah.number,
                  surah.titleWithMeaning(language),
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(color: onHero),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              [
                surah.makkan ? l.makkan : l.madinan,
                l.ayahCount(surah.ayahCount),
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(color: onHeroMuted),
            ),
            if (surah.showsBasmalaHeader) ...[
              const SizedBox(height: 10),
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

void showReaderOptions(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const _ReaderOptions(),
  );
}

class _ReaderOptions extends ConsumerWidget {
  const _ReaderOptions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final language = Localizations.localeOf(context).languageCode;
    final reciter = reciterById(settings.quranReciter);
    String reciterName(Reciter r) => language == 'ar' ? r.arabicName : r.name;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Arabic needs neither a translation nor a transliteration.
            if (language != 'ar') ...[
              SwitchListTile(
                title: Text(l.showTranslation),
                value: settings.quranShowTranslation,
                onChanged: (v) => controller.setValue('qTrans', v),
              ),
              SwitchListTile(
                title: Text(l.showTransliteration),
                value: settings.quranShowTransliteration,
                onChanged: (v) => controller.setValue('qTranslit', v),
              ),
            ],
            SwitchListTile(
              title: Text(l.showTajweed),
              value: settings.quranShowTajweed,
              onChanged: (v) => controller.setValue('qTajweed', v),
            ),
            if (settings.quranShowTajweed)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
                child: Column(
                  children: [
                    for (final kind in TajweedKind.values)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: tajweedColor(kind, scheme.brightness),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tajweedLabel(kind, l).$1,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: tajweedColor(
                                        kind,
                                        scheme.brightness,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    tajweedLabel(kind, l).$2,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
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
            SwitchListTile(
              title: Text(l.autoNextAyah),
              // Kept as chosen while repeating, so that it is back as it
              // was once repeating is switched off.
              value: settings.quranAutoNext,
              onChanged: settings.quranRepeat
                  ? null
                  : (v) => controller.setValue('qAutoNext', v),
            ),
            SwitchListTile(
              title: Text(l.repeatAyah),
              subtitle: Text(l.repeatAyahHint),
              value: settings.quranRepeat,
              onChanged: (v) => controller.setValue('qRepeat', v),
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(child: Text(l.recitationSpeed)),
                  Text(
                    '${(settings.quranSpeedTenths / 10).toStringAsFixed(1)}×',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              subtitle: Slider(
                value: settings.quranSpeedTenths.toDouble(),
                min: 2,
                max: 20,
                divisions: 18,
                onChanged: (v) => controller.setValue('qSpeed', v.round()),
              ),
            ),
            ListTile(
              title: Text(l.reciter),
              subtitle: Text(reciterName(reciter)),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () => pickOption<String>(
                context,
                title: l.reciter,
                selected: reciter.id,
                options: {for (final r in reciters) r.id: reciterName(r)},
                onSelected: (id) => controller.setValue('qReciter', id),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// The player strip under a reader, shown while a recitation is open.
class QuranPlayerBar extends ConsumerWidget {
  const QuranPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final audio = ref.watch(quranAudioProvider);
    final verse = audio.verse;
    if (verse == null) return const SizedBox.shrink();
    final controller = ref.read(quranAudioProvider.notifier);
    final surahs = ref.watch(surahIndexProvider).value;
    final reciter = reciterById(
      ref.watch(settingsProvider.select((s) => s.quranReciter)),
    );
    final name = surahs == null || verse.$1 > surahs.length
        ? '${verse.$1}'
        : surahs[verse.$1 - 1].localizedName(language);
    return Material(
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SeekBar(),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 4, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l.surahAyah(name, verse.$2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          audio.failed
                              ? l.audioFailed
                              : language == 'ar'
                              ? reciter.arabicName
                              : reciter.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: audio.failed
                                ? scheme.error
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Playback controls keep their order in every language.
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: l.previousAyah,
                          icon: const Icon(Icons.skip_previous),
                          onPressed: controller.previous,
                        ),
                        audio.loading
                            ? const SizedBox(
                                width: 48,
                                height: 48,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                ),
                              )
                            : IconButton.filled(
                                tooltip: audio.playing ? l.pause : l.listen,
                                icon: Icon(
                                  audio.failed
                                      ? Icons.refresh
                                      : audio.ended
                                      ? Icons.replay
                                      : audio.playing
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                                onPressed: controller.toggle,
                              ),
                        IconButton(
                          tooltip: l.nextAyah,
                          icon: const Icon(Icons.skip_next),
                          onPressed: controller.next,
                        ),
                        IconButton(
                          tooltip: l.closePlayer,
                          icon: const Icon(Icons.close),
                          onPressed: controller.stop,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _clock(Duration d) =>
    '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

/// The timeline of the ayah being recited; drag it to move within the ayah.
class _SeekBar extends ConsumerStatefulWidget {
  const _SeekBar();

  @override
  ConsumerState<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends ConsumerState<_SeekBar> {
  /// The place under the finger while the thumb is dragged, in ms.
  double? _drag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final audio = ref.watch(quranAudioProvider);
    final ready = !audio.loading && !audio.failed;
    final length = ready
        ? (ref.watch(ayahDurationProvider).value ?? Duration.zero)
        : Duration.zero;
    final total = length.inMilliseconds.toDouble();
    final played = audio.ended
        ? total
        : ready
        ? (ref.watch(ayahPositionProvider).value ?? Duration.zero)
              .inMilliseconds
              .toDouble()
        : 0.0;
    final value = (_drag ?? played).clamp(0.0, total);
    final small = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    // Time runs left to right in every language.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Row(
          children: [
            Text(_clock(Duration(milliseconds: value.round())), style: small),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                ),
                child: Slider(
                  value: value,
                  max: total > 0 ? total : 1,
                  onChanged: total > 0
                      ? (v) => setState(() => _drag = v)
                      : null,
                  onChangeEnd: (v) async {
                    await ref
                        .read(quranAudioProvider.notifier)
                        .seek(Duration(milliseconds: v.round()));
                    if (mounted) setState(() => _drag = null);
                  },
                ),
              ),
            ),
            Text(_clock(length), style: small),
          ],
        ),
      ),
    );
  }
}
