import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_app/core/content/quran.dart';
import 'package:muslim_app/services/quran_store.dart';

void main() {
  late Directory root;
  final reciter = reciters.first;

  setUp(() => root = Directory.systemTemp.createTempSync('quran_store'));
  tearDown(() => root.deleteSync(recursive: true));

  test('a surah is saved ayah by ayah, counted and deleted', () async {
    final asked = <Uri>[];
    final store = QuranStore(
      root,
      fetch: (url) async {
        asked.add(url);
        return [1, 2, 3];
      },
    );
    final progress = <int>[];
    await store.download(reciter, 112, 4, onProgress: progress.add);

    expect(progress, [1, 2, 3, 4]);
    expect(asked.first.toString(), reciter.url((112, 1)));
    expect(store.file(reciter, (112, 4)).existsSync(), isTrue);
    expect(await store.counts(reciter), {112: 4});

    // What is already on the phone is not loaded again.
    await store.download(reciter, 112, 4);
    expect(asked, hasLength(4));

    await store.delete(reciter, 112);
    expect(await store.counts(reciter), isEmpty);
  });

  test('a failed load leaves no broken file and keeps what was loaded',
      () async {
    final store = QuranStore(
      root,
      fetch: (url) async {
        if (url.path.endsWith('001003.mp3')) throw const SocketException('x');
        return [1];
      },
    );
    await expectLater(store.download(reciter, 1, 7), throwsA(anything));
    expect(await store.counts(reciter), {1: 2});
    expect(root.listSync(recursive: true).where((e) => e.path.endsWith('.part')),
        isEmpty);
  });

  test('cancelling stops between ayahs', () async {
    final store = QuranStore(root, fetch: (url) async => [1]);
    var done = 0;
    await store.download(
      reciter,
      2,
      286,
      onProgress: (d) => done = d,
      cancelled: () => done >= 3,
    );
    expect(await store.counts(reciter), {2: 3});
  });
}
