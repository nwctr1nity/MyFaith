import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_app/services/backup.dart';

void main() {
  test('a backup gives back the settings it was made from', () {
    final settings = <String, Object?>{
      'lang': 'ru',
      'qMarks': ['2:255'],
      'place': {'name': 'Алматы', 'lat': 43.25},
    };
    final bytes = encodeBackup(settings, now: DateTime.utc(2026, 11, 16));
    expect(decodeBackup(bytes), settings);
    expect(utf8.decode(bytes), contains('"saved": "2026-11-16T00:00:00.000Z"'));
  });

  test('other files are refused', () {
    expect(decodeBackup(utf8.encode('{"lang": "ru"}')), isNull);
    expect(decodeBackup(utf8.encode('not json')), isNull);
    expect(decodeBackup([0xff, 0xfe, 0x00]), isNull);
    expect(decodeBackup(utf8.encode('{"format":"myfaith-backup"}')), isNull);
  });
}
