import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../core/content/quran.dart';
import '../services/quran_store.dart';
import 'app_settings.dart';
import 'content_providers.dart';

/// Null where files cannot be kept (the web build, tests).
final quranStoreProvider = FutureProvider<QuranStore?>((ref) async {
  if (kIsWeb) return null;
  try {
    final base = await getApplicationSupportDirectory();
    return QuranStore(Directory('${base.path}/quran_audio'));
  } on Object {
    return null;
  }
});

class DownloadsState {
  const DownloadsState({
    this.counts = const {},
    this.running,
    this.failed,
  });

  /// Ayahs on the phone per surah, for the chosen reciter.
  final Map<int, int> counts;

  /// The surah being loaded now, if any.
  final int? running;

  /// The surah whose last load stopped on an error.
  final int? failed;
}

/// Downloads of the chosen reciter. One surah loads at a time.
class QuranDownloads extends AsyncNotifier<DownloadsState> {
  bool _cancel = false;

  Reciter get _reciter =>
      reciterById(ref.read(settingsProvider).quranReciter);

  @override
  Future<DownloadsState> build() async {
    ref.watch(settingsProvider.select((s) => s.quranReciter));
    _cancel = true;
    final store = await ref.watch(quranStoreProvider.future);
    if (store == null) return const DownloadsState();
    return DownloadsState(counts: await store.counts(_reciter));
  }

  Future<void> download(int surah) async {
    final store = await ref.read(quranStoreProvider.future);
    final current = state.value;
    if (store == null || current == null || current.running != null) return;
    final reciter = _reciter;
    final surahs = await ref.read(surahIndexProvider.future);
    final total = surahs[surah - 1].ayahCount;
    _cancel = false;
    var counts = {...current.counts};
    state = AsyncData(DownloadsState(counts: counts, running: surah));
    int? failed;
    try {
      await store.download(
        reciter,
        surah,
        total,
        cancelled: () => _cancel,
        onProgress: (done) {
          counts = {...counts, surah: done};
          state = AsyncData(DownloadsState(counts: counts, running: surah));
        },
      );
    } on Object {
      failed = surah;
    }
    if (reciter.id != _reciter.id) return;
    state = AsyncData(
      DownloadsState(counts: await store.counts(reciter), failed: failed),
    );
  }

  void cancel() => _cancel = true;

  Future<void> delete(int surah) async {
    final store = await ref.read(quranStoreProvider.future);
    if (store == null) return;
    final reciter = _reciter;
    await store.delete(reciter, surah);
    state = AsyncData(DownloadsState(counts: await store.counts(reciter)));
  }
}

final quranDownloadsProvider =
    AsyncNotifierProvider<QuranDownloads, DownloadsState>(QuranDownloads.new);
