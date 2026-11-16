import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_app/core/content/muezzins.dart';
import 'package:muslim_app/core/prayer/prayer_calculator.dart';

void main() {
  test('every recording of every muezzin is in the app', () {
    for (final m in muezzins) {
      for (final slot in PrayerSlot.values) {
        final file = File('android/app/src/main/res/raw/${m.sound(slot)}.m4a');
        expect(file.existsSync(), isTrue, reason: file.path);
      }
      for (final code in ['ru', 'en', 'ar']) {
        expect(m.name(code), isNotEmpty);
      }
    }
  });

  test('Fajr has its own recording, an unknown id gives the default', () {
    final doha = muezzinById('nobody');
    expect(doha.id, muezzins.first.id);
    expect(doha.sound(PrayerSlot.fajr), 'azan_doha_fajr');
    expect(doha.sound(PrayerSlot.asr), 'azan_doha_asr');
    expect(doha.sound(PrayerSlot.dhuhr), 'azan_doha_dhuhr');
  });
}
