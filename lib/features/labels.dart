import '../core/hijri.dart';
import '../core/prayer/prayer_calculator.dart';
import '../l10n/app_localizations.dart';

String prayerName(AppLocalizations l, PrayerSlot slot) {
  switch (slot) {
    case PrayerSlot.fajr:
      return l.prayerFajr;
    case PrayerSlot.sunrise:
      return l.prayerSunrise;
    case PrayerSlot.dhuhr:
      return l.prayerDhuhr;
    case PrayerSlot.asr:
      return l.prayerAsr;
    case PrayerSlot.maghrib:
      return l.prayerMaghrib;
    case PrayerSlot.isha:
      return l.prayerIsha;
  }
}

String methodName(AppLocalizations l, CalcMethod method) {
  switch (method) {
    case CalcMethod.muslimWorldLeague:
      return l.methodMuslimWorldLeague;
    case CalcMethod.russia:
      return l.methodRussia;
    case CalcMethod.turkiye:
      return l.methodTurkiye;
    case CalcMethod.ummAlQura:
      return l.methodUmmAlQura;
    case CalcMethod.egyptian:
      return l.methodEgyptian;
    case CalcMethod.karachi:
      return l.methodKarachi;
    case CalcMethod.northAmerica:
      return l.methodNorthAmerica;
    case CalcMethod.dubai:
      return l.methodDubai;
    case CalcMethod.qatar:
      return l.methodQatar;
    case CalcMethod.kuwait:
      return l.methodKuwait;
    case CalcMethod.gulfRegion:
      return l.methodGulfRegion;
    case CalcMethod.singapore:
      return l.methodSingapore;
    case CalcMethod.indonesian:
      return l.methodIndonesian;
    case CalcMethod.tehran:
      return l.methodTehran;
    case CalcMethod.jafari:
      return l.methodJafari;
    case CalcMethod.france:
      return l.methodFrance;
    case CalcMethod.jordan:
      return l.methodJordan;
    case CalcMethod.morocco:
      return l.methodMorocco;
    case CalcMethod.algerian:
      return l.methodAlgerian;
    case CalcMethod.tunisia:
      return l.methodTunisia;
    case CalcMethod.portugal:
      return l.methodPortugal;
    case CalcMethod.moonsightingCommittee:
      return l.methodMoonsightingCommittee;
  }
}

String _angle(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

/// One line describing the angles a method uses.
String methodDetails(AppLocalizations l, CalcMethod method) {
  final a = methodAngles(method);
  if (a.ishaInterval > 0) {
    return l.methodAnglesInterval(_angle(a.fajr), a.ishaInterval);
  }
  return l.methodAngles(_angle(a.fajr), _angle(a.isha));
}

const _hijriMonths = <String, List<String>>{
  'en': [
    'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani', 'Jumada al-Ula',
    'Jumada al-Akhira', 'Rajab', 'Shaban', 'Ramadan', 'Shawwal',
    'Dhu al-Qadah', 'Dhu al-Hijjah',
  ],
  'ru': [
    'мухаррама', 'сафара', 'раби аль-авваль', 'раби ас-сани',
    'джумада аль-уля', 'джумада аль-ахира', 'раджаба', 'шабана', 'рамадана',
    'шавваля', 'зуль-када', 'зуль-хиджа',
  ],
  'ar': [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى',
    'جمادى الآخرة', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة',
    'ذو الحجة',
  ],
};

/// A Hijri date as text, for example `4 джумада аль-ахира 1448`.
String hijriText(String languageCode, int year, int month, int day) {
  final months = _hijriMonths[languageCode] ?? _hijriMonths['en']!;
  final text = '$day ${months[(month - 1).clamp(0, 11)]} $year';
  if (languageCode != 'ar') return text;
  // Arabic dates and times elsewhere on the screen use Arabic-Indic digits.
  return text.replaceAllMapped(
    RegExp(r'\d'),
    (m) => String.fromCharCode(0x0660 + int.parse(m[0]!)),
  );
}

const _hijriMonthTitles = <String, List<String>>{
  'ru': [
    'Мухаррам', 'Сафар', 'Раби аль-авваль', 'Раби ас-сани',
    'Джумада аль-уля', 'Джумада аль-ахира', 'Раджаб', 'Шабан', 'Рамадан',
    'Шавваль', 'Зуль-када', 'Зуль-хиджа',
  ],
};

/// A Hijri month as a heading, for example `Рамадан 1448`.
String hijriMonthTitle(String languageCode, int year, int month) {
  final months = _hijriMonthTitles[languageCode] ??
      _hijriMonths[languageCode] ??
      _hijriMonths['en']!;
  return arabicDigits(languageCode, '${months[(month - 1).clamp(0, 11)]} $year');
}

/// Arabic-Indic digits in Arabic, the text unchanged otherwise.
String arabicDigits(String languageCode, String text) {
  if (languageCode != 'ar') return text;
  return text.replaceAllMapped(
    RegExp(r'\d'),
    (m) => String.fromCharCode(0x0660 + int.parse(m[0]!)),
  );
}

String hijriEventName(AppLocalizations l, HijriEvent event) => switch (event) {
  HijriEvent.newYear => l.eventNewYear,
  HijriEvent.ashura => l.eventAshura,
  HijriEvent.ramadan => l.eventRamadan,
  HijriEvent.lastTenNights => l.eventLastTen,
  HijriEvent.eidFitr => l.eventEidFitr,
  HijriEvent.firstTenDays => l.eventFirstTen,
  HijriEvent.arafah => l.eventArafah,
  HijriEvent.eidAdha => l.eventEidAdha,
  HijriEvent.tashriq => l.eventTashriq,
};
