import 'dart:io';
import 'dart:typed_data';

import '../core/content/quran.dart';

/// Loads one recording. Tests replace it.
typedef FetchBytes = Future<List<int>> Function(Uri url);

Future<List<int>> fetchOverHttp(Uri url) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    final request = await client.getUrl(url);
    final response = await request.close().timeout(const Duration(seconds: 60));
    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}', uri: url);
    }
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in response) {
      bytes.add(chunk);
    }
    return bytes.takeBytes();
  } finally {
    client.close(force: true);
  }
}

/// Recitations kept on the phone, so a surah plays without the internet.
/// One file per ayah, in a folder per reciter.
class QuranStore {
  QuranStore(this.root, {this.fetch = fetchOverHttp});

  final Directory root;
  final FetchBytes fetch;

  static String _name(Verse verse) =>
      '${verse.$1.toString().padLeft(3, '0')}'
      '${verse.$2.toString().padLeft(3, '0')}.mp3';

  File file(Reciter reciter, Verse verse) =>
      File('${root.path}/${reciter.folder}/${_name(verse)}');

  /// How many ayahs of each surah are on the phone for [reciter].
  Future<Map<int, int>> counts(Reciter reciter) async {
    final folder = Directory('${root.path}/${reciter.folder}');
    final result = <int, int>{};
    if (!await folder.exists()) return result;
    await for (final entry in folder.list()) {
      final name = entry.uri.pathSegments.last;
      if (entry is! File || name.length != 10 || !name.endsWith('.mp3')) {
        continue;
      }
      final surah = int.tryParse(name.substring(0, 3));
      if (surah != null) result[surah] = (result[surah] ?? 0) + 1;
    }
    return result;
  }

  /// Loads the ayahs of [surah] that are not on the phone yet. Stops early
  /// when [cancelled] turns true; what is loaded by then is kept.
  Future<void> download(
    Reciter reciter,
    int surah,
    int ayahCount, {
    void Function(int done)? onProgress,
    bool Function()? cancelled,
  }) async {
    await Directory('${root.path}/${reciter.folder}').create(recursive: true);
    var done = 0;
    for (var ayah = 1; ayah <= ayahCount; ayah++) {
      if (cancelled?.call() ?? false) return;
      final target = file(reciter, (surah, ayah));
      if (!await target.exists()) {
        final bytes = await fetch(Uri.parse(reciter.url((surah, ayah))));
        // Written under another name first: a file with the final name is
        // always a whole recording.
        final partial = File('${target.path}.part');
        await partial.writeAsBytes(bytes, flush: true);
        await partial.rename(target.path);
      }
      onProgress?.call(++done);
    }
  }

  Future<void> delete(Reciter reciter, int surah) async {
    final folder = Directory('${root.path}/${reciter.folder}');
    if (!await folder.exists()) return;
    final prefix = surah.toString().padLeft(3, '0');
    await for (final entry in folder.list()) {
      if (entry is File && entry.uri.pathSegments.last.startsWith(prefix)) {
        await entry.delete();
      }
    }
  }
}
