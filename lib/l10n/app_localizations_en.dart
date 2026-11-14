// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Prayer Times';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Sunrise';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String nextPrayerIn(String prayer) {
    return '$prayer in';
  }

  @override
  String get nowLabel => 'Now';

  @override
  String get lastThirdOfNight => 'Last third of the night';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System language';

  @override
  String get location => 'Location';

  @override
  String get chooseCity => 'Choose a city';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get searchCity => 'City name';

  @override
  String get searchCityHint => 'Type at least two letters';

  @override
  String get noCitiesFound => 'No cities found';

  @override
  String get locationNotSet => 'Choose a city to see prayer times';

  @override
  String get locationDenied =>
      'Location permission was denied. Choose a city by hand.';

  @override
  String get locationDisabled =>
      'Location is turned off on this device. Turn it on or choose a city by hand.';

  @override
  String get locationFailed =>
      'Could not get the location. Choose a city by hand.';

  @override
  String get myLocation => 'My location';

  @override
  String get calculation => 'Calculation';

  @override
  String get method => 'Method';

  @override
  String methodAngles(String fajr, String isha) {
    return 'Fajr $fajr°, Isha $isha°';
  }

  @override
  String methodAnglesInterval(String fajr, int minutes) {
    return 'Fajr $fajr°, Isha $minutes min after Maghrib';
  }

  @override
  String get asrMadhab => 'Asr time';

  @override
  String get madhabShafi => 'Shafi, Maliki, Hanbali';

  @override
  String get madhabHanafi => 'Hanafi (later)';

  @override
  String get adjustments => 'Corrections in minutes';

  @override
  String get adjustmentsHint =>
      'Shift a time to match your mosque\'s timetable';

  @override
  String minutesShort(String count) {
    return '$count min';
  }

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'As on the device';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get methodMuslimWorldLeague => 'Muslim World League';

  @override
  String get methodRussia => 'Russia';

  @override
  String get methodTurkiye => 'Türkiye (Diyanet)';

  @override
  String get methodUmmAlQura => 'Umm al-Qura, Makkah';

  @override
  String get methodEgyptian => 'Egypt';

  @override
  String get methodKarachi => 'Karachi';

  @override
  String get methodNorthAmerica => 'North America (ISNA)';

  @override
  String get methodDubai => 'Dubai';

  @override
  String get methodQatar => 'Qatar';

  @override
  String get methodKuwait => 'Kuwait';

  @override
  String get methodGulfRegion => 'Gulf region';

  @override
  String get methodSingapore => 'Singapore, Malaysia';

  @override
  String get methodIndonesian => 'Indonesia';

  @override
  String get methodTehran => 'Tehran';

  @override
  String get methodJafari => 'Jafari';

  @override
  String get methodFrance => 'France';

  @override
  String get methodJordan => 'Jordan';

  @override
  String get methodMorocco => 'Morocco';

  @override
  String get methodAlgerian => 'Algeria';

  @override
  String get methodTunisia => 'Tunisia';

  @override
  String get methodPortugal => 'Portugal';

  @override
  String get methodMoonsightingCommittee => 'Moonsighting Committee';
}
