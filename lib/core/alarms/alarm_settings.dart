import '../prayer/prayer_calculator.dart';

/// The notification and alarm choices the planner works from.
class AlarmSettings {
  const AlarmSettings({
    this.adhanSlots = const {
      PrayerSlot.fajr,
      PrayerSlot.dhuhr,
      PrayerSlot.asr,
      PrayerSlot.maghrib,
      PrayerSlot.isha,
    },
    this.reminderMinutes = 0,
    this.hadithNotification = false,
    this.hadithHour = 9,
    this.suhoorEnabled = false,
    this.suhoorMinutesBeforeFajr = 60,
    this.suhoorInRamadan = true,
    this.suhoorMonThu = false,
    this.suhoorWhiteDays = false,
    this.suhoorEveryDay = false,
    this.suhoorStopWarningMinutes = 30,
    this.tahajjudEnabled = false,
    this.tahajjudAtLastThird = true,
    this.tahajjudMinutesBeforeFajr = 45,
    this.tahajjudWeekdays = const {1, 2, 3, 4, 5, 6, 7},
    this.hijriAdjustment = 0,
    this.adhkarMorning = false,
    this.adhkarEvening = false,
    this.kahfFriday = false,
  });

  final Set<PrayerSlot> adhanSlots;
  final int reminderMinutes;
  final bool hadithNotification;
  final int hadithHour;
  final bool suhoorEnabled;
  final int suhoorMinutesBeforeFajr;
  final bool suhoorInRamadan;
  final bool suhoorMonThu;
  final bool suhoorWhiteDays;
  final bool suhoorEveryDay;
  final int suhoorStopWarningMinutes;
  final bool tahajjudEnabled;
  final bool tahajjudAtLastThird;
  final int tahajjudMinutesBeforeFajr;
  final Set<int> tahajjudWeekdays;
  final int hijriAdjustment;

  /// Reminders of the morning and evening adhkar and of Surah al-Kahf.
  final bool adhkarMorning;
  final bool adhkarEvening;
  final bool kahfFriday;
}
