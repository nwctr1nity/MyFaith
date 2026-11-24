import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/content/quran.dart';
import '../../l10n/app_localizations.dart';
import '../../state/content_providers.dart';
import '../theme.dart';
import 'reader_screen.dart';

/// Searches the text of the Quran for a word.
class QuranSearchScreen extends ConsumerStatefulWidget {
  const QuranSearchScreen({super.key});

  @override
  ConsumerState<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends ConsumerState<QuranSearchScreen> {
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final corpus = ref.watch(quranCorpusProvider);
    final surahs = ref.watch(surahIndexProvider).value ?? const [];

    Widget message(String text) => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l.searchQuranHint,
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
          onSubmitted: (v) {
            _debounce?.cancel();
            setState(() => _query = v);
          },
        ),
      ),
      body: corpus.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (texts) {
          if (_query.trim().length < 2) return message(l.searchQuranPrompt);
          final hits = searchQuran(texts, _query, language);
          if (hits.isEmpty) return message(l.nothingFound);
          return ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: hits.length + 1,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 8),
                  child: Text(
                    hits.length >= 300
                        ? l.searchManyFound(hits.length)
                        : l.searchFound(hits.length),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                );
              }
              final hit = hits[i - 1];
              final surah = surahs[hit.verse.$1 - 1];
              final found = hit.length == 0;
              return ListTile(
                title: Text(
                  l.surahAyah(surah.localizedName(language), hit.verse.$2),
                  style: theme.textTheme.labelLarge,
                ),
                subtitle: found
                    ? Text(
                        hit.text,
                        textDirection: TextDirection.rtl,
                        style: quranTextStyle(22, scheme.onSurface),
                      )
                    : Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: hit.text.substring(0, hit.start)),
                            TextSpan(
                              text: hit.text.substring(
                                hit.start,
                                hit.start + hit.length,
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: scheme.primary,
                              ),
                            ),
                            TextSpan(
                              text: hit.text.substring(hit.start + hit.length),
                            ),
                          ],
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                          color: scheme.onSurface,
                        ),
                      ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ReaderScreen(surah: surah, initialAyah: hit.verse.$2),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
