import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../core/content/quran.dart';
import 'app_settings.dart';
import 'content_providers.dart';

/// Plays one recording at a time. Tests replace it with a fake.
abstract class AyahPlayer {
  /// Starts [url] from the beginning.
  Future<void> play(String url);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();

  /// Fires each time a recording has played to its end.
  Stream<void> get completed;
  Future<void> dispose();
}

class JustAudioAyahPlayer implements AyahPlayer {
  JustAudioAyahPlayer() {
    _subscription = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _completed.add(null);
      }
    });
  }

  final _player = AudioPlayer();
  final _completed = StreamController<void>.broadcast();
  late final StreamSubscription<PlayerState> _subscription;

  @override
  Stream<void> get completed => _completed.stream;

  @override
  Future<void> play(String url) async {
    await _player.setUrl(url);
    // `play` completes only when playback ends, so it is not awaited.
    unawaited(_player.play());
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() async => unawaited(_player.play());

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() async {
    await _subscription.cancel();
    await _completed.close();
    await _player.dispose();
  }
}

final ayahPlayerProvider = Provider<AyahPlayer>((ref) {
  final player = JustAudioAyahPlayer();
  ref.onDispose(player.dispose);
  return player;
});

class QuranAudioState {
  const QuranAudioState({
    this.verse,
    this.playing = false,
    this.loading = false,
    this.failed = false,
  });

  /// The verse being recited, or null when the player is closed.
  final Verse? verse;
  final bool playing;
  final bool loading;

  /// True when the recording could not be loaded, usually for lack of an
  /// internet connection.
  final bool failed;
}

/// Recites the Quran ayah by ayah, moving on to the next one by itself.
class QuranAudioController extends Notifier<QuranAudioState> {
  StreamSubscription<void>? _subscription;

  /// Guards against a slow load finishing after a newer request.
  int _request = 0;

  @override
  QuranAudioState build() {
    final player = ref.watch(ayahPlayerProvider);
    _subscription?.cancel();
    _subscription = player.completed.listen((_) => next(auto: true));
    ref.onDispose(() => _subscription?.cancel());
    return const QuranAudioState();
  }

  AyahPlayer get _player => ref.read(ayahPlayerProvider);

  Future<void> play(Verse verse) async {
    final request = ++_request;
    state = QuranAudioState(verse: verse, loading: true);
    final reciter = reciterById(ref.read(settingsProvider).quranReciter);
    try {
      await _player.play(reciter.url(verse));
      if (request != _request) return;
      state = QuranAudioState(verse: verse, playing: true);
    } on Object {
      if (request != _request) return;
      state = QuranAudioState(verse: verse, failed: true);
    }
  }

  Future<void> toggle() async {
    final verse = state.verse;
    if (verse == null || state.loading) return;
    if (state.failed) return play(verse);
    if (state.playing) {
      await _player.pause();
      state = QuranAudioState(verse: verse);
    } else {
      await _player.resume();
      state = QuranAudioState(verse: verse, playing: true);
    }
  }

  /// Moves to the next verse. At the end of the Quran the player closes.
  Future<void> next({bool auto = false}) async {
    final verse = state.verse;
    if (verse == null) return;
    if (auto && !state.playing) return;
    final layout = await ref.read(mushafLayoutProvider.future);
    final following = layout.next(verse);
    if (following == null) return stop();
    await play(following);
  }

  Future<void> previous() async {
    final verse = state.verse;
    if (verse == null) return;
    if (verse.$2 > 1) return play((verse.$1, verse.$2 - 1));
    if (verse.$1 == 1) return play(verse);
    final layout = await ref.read(mushafLayoutProvider.future);
    await play((verse.$1 - 1, layout.ayahCounts[verse.$1 - 2]));
  }

  Future<void> stop() async {
    _request++;
    state = const QuranAudioState();
    try {
      await _player.stop();
    } on Object {
      // Nothing was playing.
    }
  }
}

final quranAudioProvider =
    NotifierProvider<QuranAudioController, QuranAudioState>(
      QuranAudioController.new,
    );
