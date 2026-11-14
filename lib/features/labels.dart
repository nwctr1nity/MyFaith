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
