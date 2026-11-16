import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get appTitle;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerSunrise;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @nextPrayerIn.
  ///
  /// In en, this message translates to:
  /// **'{prayer} in'**
  String nextPrayerIn(String prayer);

  /// No description provided for @nowLabel.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get nowLabel;

  /// No description provided for @rakaatsFajr.
  ///
  /// In en, this message translates to:
  /// **'2 rakaats sunnah, 2 rakaats fard'**
  String get rakaatsFajr;

  /// No description provided for @rakaatsDhuhr.
  ///
  /// In en, this message translates to:
  /// **'4 rakaats sunnah, 4 fard, 2 sunnah'**
  String get rakaatsDhuhr;

  /// No description provided for @rakaatsAsr.
  ///
  /// In en, this message translates to:
  /// **'4 rakaats fard'**
  String get rakaatsAsr;

  /// No description provided for @rakaatsMaghrib.
  ///
  /// In en, this message translates to:
  /// **'3 rakaats fard, 2 sunnah'**
  String get rakaatsMaghrib;

  /// No description provided for @rakaatsIsha.
  ///
  /// In en, this message translates to:
  /// **'4 rakaats fard, 2 sunnah, 3 witr'**
  String get rakaatsIsha;

  /// No description provided for @howToPray.
  ///
  /// In en, this message translates to:
  /// **'How to pray?'**
  String get howToPray;

  /// No description provided for @howToPrayHint.
  ///
  /// In en, this message translates to:
  /// **'Step by step, in the Hanafi school'**
  String get howToPrayHint;

  /// No description provided for @guideRakaats.
  ///
  /// In en, this message translates to:
  /// **'How many rakaats'**
  String get guideRakaats;

  /// No description provided for @guideSunnahBefore.
  ///
  /// In en, this message translates to:
  /// **'Sunnah before'**
  String get guideSunnahBefore;

  /// No description provided for @guideFard.
  ///
  /// In en, this message translates to:
  /// **'Fard'**
  String get guideFard;

  /// No description provided for @guideSunnahAfter.
  ///
  /// In en, this message translates to:
  /// **'Sunnah after'**
  String get guideSunnahAfter;

  /// No description provided for @guideWitr.
  ///
  /// In en, this message translates to:
  /// **'Witr'**
  String get guideWitr;

  /// No description provided for @guideBefore.
  ///
  /// In en, this message translates to:
  /// **'Before the prayer'**
  String get guideBefore;

  /// No description provided for @guideSteps.
  ///
  /// In en, this message translates to:
  /// **'A prayer of two rakaats'**
  String get guideSteps;

  /// No description provided for @guideMore.
  ///
  /// In en, this message translates to:
  /// **'What else to know'**
  String get guideMore;

  /// No description provided for @soonLabel.
  ///
  /// In en, this message translates to:
  /// **'In {minutes} min!'**
  String soonLabel(int minutes);

  /// No description provided for @showTransliterationItem.
  ///
  /// In en, this message translates to:
  /// **'Show transliteration'**
  String get showTransliterationItem;

  /// No description provided for @repeatAyah.
  ///
  /// In en, this message translates to:
  /// **'Repeat for memorising'**
  String get repeatAyah;

  /// No description provided for @repeatAyahHint.
  ///
  /// In en, this message translates to:
  /// **'The ayah plays again and again until switched off'**
  String get repeatAyahHint;

  /// No description provided for @recitationSpeed.
  ///
  /// In en, this message translates to:
  /// **'Recitation speed'**
  String get recitationSpeed;

  /// No description provided for @resetSpeed.
  ///
  /// In en, this message translates to:
  /// **'Reset to 1×'**
  String get resetSpeed;

  /// No description provided for @lastThirdOfNight.
  ///
  /// In en, this message translates to:
  /// **'Last third of the night'**
  String get lastThirdOfNight;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @supportProject.
  ///
  /// In en, this message translates to:
  /// **'Support the project'**
  String get supportProject;

  /// No description provided for @supportText.
  ///
  /// In en, this message translates to:
  /// **'All donations are voluntary. My project will always be completely free.'**
  String get supportText;

  /// No description provided for @tbank.
  ///
  /// In en, this message translates to:
  /// **'T-Bank'**
  String get tbank;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get languageSystem;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @chooseCity.
  ///
  /// In en, this message translates to:
  /// **'Choose a city'**
  String get chooseCity;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'City name'**
  String get searchCity;

  /// No description provided for @searchCityHint.
  ///
  /// In en, this message translates to:
  /// **'Type at least two letters'**
  String get searchCityHint;

  /// No description provided for @noCitiesFound.
  ///
  /// In en, this message translates to:
  /// **'No cities found'**
  String get noCitiesFound;

  /// No description provided for @locationNotSet.
  ///
  /// In en, this message translates to:
  /// **'Choose a city to see prayer times'**
  String get locationNotSet;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. Choose a city by hand.'**
  String get locationDenied;

  /// No description provided for @locationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off on this device. Turn it on or choose a city by hand.'**
  String get locationDisabled;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not get the location. Choose a city by hand.'**
  String get locationFailed;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @calculation.
  ///
  /// In en, this message translates to:
  /// **'Calculation'**
  String get calculation;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @methodAngles.
  ///
  /// In en, this message translates to:
  /// **'Fajr {fajr}°, Isha {isha}°'**
  String methodAngles(String fajr, String isha);

  /// No description provided for @methodAnglesInterval.
  ///
  /// In en, this message translates to:
  /// **'Fajr {fajr}°, Isha {minutes} min after Maghrib'**
  String methodAnglesInterval(String fajr, int minutes);

  /// No description provided for @asrMadhab.
  ///
  /// In en, this message translates to:
  /// **'Asr time'**
  String get asrMadhab;

  /// No description provided for @madhabShafi.
  ///
  /// In en, this message translates to:
  /// **'Shafi, Maliki, Hanbali'**
  String get madhabShafi;

  /// No description provided for @madhabHanafi.
  ///
  /// In en, this message translates to:
  /// **'Hanafi (later)'**
  String get madhabHanafi;

  /// No description provided for @adjustments.
  ///
  /// In en, this message translates to:
  /// **'Corrections in minutes'**
  String get adjustments;

  /// No description provided for @adjustmentsHint.
  ///
  /// In en, this message translates to:
  /// **'Shift a time to match your mosque\'s timetable'**
  String get adjustmentsHint;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesShort(String count);

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'As on the device'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @methodMuslimWorldLeague.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League'**
  String get methodMuslimWorldLeague;

  /// No description provided for @methodRussia.
  ///
  /// In en, this message translates to:
  /// **'Russia'**
  String get methodRussia;

  /// No description provided for @methodTurkiye.
  ///
  /// In en, this message translates to:
  /// **'Türkiye (Diyanet)'**
  String get methodTurkiye;

  /// No description provided for @methodUmmAlQura.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura, Makkah'**
  String get methodUmmAlQura;

  /// No description provided for @methodEgyptian.
  ///
  /// In en, this message translates to:
  /// **'Egypt'**
  String get methodEgyptian;

  /// No description provided for @methodKarachi.
  ///
  /// In en, this message translates to:
  /// **'Karachi'**
  String get methodKarachi;

  /// No description provided for @methodNorthAmerica.
  ///
  /// In en, this message translates to:
  /// **'North America (ISNA)'**
  String get methodNorthAmerica;

  /// No description provided for @methodDubai.
  ///
  /// In en, this message translates to:
  /// **'Dubai'**
  String get methodDubai;

  /// No description provided for @methodQatar.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get methodQatar;

  /// No description provided for @methodKuwait.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get methodKuwait;

  /// No description provided for @methodGulfRegion.
  ///
  /// In en, this message translates to:
  /// **'Gulf region'**
  String get methodGulfRegion;

  /// No description provided for @methodSingapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore, Malaysia'**
  String get methodSingapore;

  /// No description provided for @methodIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesia'**
  String get methodIndonesian;

  /// No description provided for @methodTehran.
  ///
  /// In en, this message translates to:
  /// **'Tehran'**
  String get methodTehran;

  /// No description provided for @methodJafari.
  ///
  /// In en, this message translates to:
  /// **'Jafari'**
  String get methodJafari;

  /// No description provided for @methodFrance.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get methodFrance;

  /// No description provided for @methodJordan.
  ///
  /// In en, this message translates to:
  /// **'Jordan'**
  String get methodJordan;

  /// No description provided for @methodMorocco.
  ///
  /// In en, this message translates to:
  /// **'Morocco'**
  String get methodMorocco;

  /// No description provided for @methodAlgerian.
  ///
  /// In en, this message translates to:
  /// **'Algeria'**
  String get methodAlgerian;

  /// No description provided for @methodTunisia.
  ///
  /// In en, this message translates to:
  /// **'Tunisia'**
  String get methodTunisia;

  /// No description provided for @methodPortugal.
  ///
  /// In en, this message translates to:
  /// **'Portugal'**
  String get methodPortugal;

  /// No description provided for @methodMoonsightingCommittee.
  ///
  /// In en, this message translates to:
  /// **'Moonsighting Committee'**
  String get methodMoonsightingCommittee;

  /// No description provided for @navPrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get navPrayer;

  /// No description provided for @navQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get navQuran;

  /// No description provided for @navQibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get navQibla;

  /// No description provided for @navSalawat.
  ///
  /// In en, this message translates to:
  /// **'Salawat'**
  String get navSalawat;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @atTime.
  ///
  /// In en, this message translates to:
  /// **'at {time}'**
  String atTime(String time);

  /// No description provided for @hadithOfDay.
  ///
  /// In en, this message translates to:
  /// **'Hadith of the day'**
  String get hadithOfDay;

  /// No description provided for @bukhariRef.
  ///
  /// In en, this message translates to:
  /// **'Sahih al-Bukhari, no. {number}'**
  String bukhariRef(int number);

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read in full'**
  String get readMore;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextDay;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @adhanOn.
  ///
  /// In en, this message translates to:
  /// **'Adhan on'**
  String get adhanOn;

  /// No description provided for @adhanOff.
  ///
  /// In en, this message translates to:
  /// **'Adhan off'**
  String get adhanOff;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get continueReading;

  /// No description provided for @surahAyah.
  ///
  /// In en, this message translates to:
  /// **'{surah}, ayah {ayah}'**
  String surahAyah(String surah, int ayah);

  /// No description provided for @searchSurah.
  ///
  /// In en, this message translates to:
  /// **'Surah name or number'**
  String get searchSurah;

  /// No description provided for @ayahCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ayahs'**
  String ayahCount(int count);

  /// No description provided for @makkan.
  ///
  /// In en, this message translates to:
  /// **'Makkan'**
  String get makkan;

  /// No description provided for @madinan.
  ///
  /// In en, this message translates to:
  /// **'Madinan'**
  String get madinan;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @noBookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet. Tap the bookmark icon under an ayah to save it.'**
  String get noBookmarks;

  /// No description provided for @tafsir.
  ///
  /// In en, this message translates to:
  /// **'Tafsir'**
  String get tafsir;

  /// No description provided for @tafsirSource.
  ///
  /// In en, this message translates to:
  /// **'Al-Mukhtasar fi Tafsir al-Quran'**
  String get tafsirSource;

  /// No description provided for @showTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get showTranslation;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @addBookmark.
  ///
  /// In en, this message translates to:
  /// **'Add bookmark'**
  String get addBookmark;

  /// No description provided for @removeBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get removeBookmark;

  /// No description provided for @qiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Qibla is {degrees}° from north'**
  String qiblaDirection(String degrees);

  /// No description provided for @qiblaAligned.
  ///
  /// In en, this message translates to:
  /// **'You are facing the qibla'**
  String get qiblaAligned;

  /// No description provided for @qiblaTurnRight.
  ///
  /// In en, this message translates to:
  /// **'Turn right by {degrees}°'**
  String qiblaTurnRight(String degrees);

  /// No description provided for @qiblaTurnLeft.
  ///
  /// In en, this message translates to:
  /// **'Turn left by {degrees}°'**
  String qiblaTurnLeft(String degrees);

  /// No description provided for @qiblaNoSensor.
  ///
  /// In en, this message translates to:
  /// **'This device has no compass. Use the angle above with any compass.'**
  String get qiblaNoSensor;

  /// No description provided for @qiblaCalibrate.
  ///
  /// In en, this message translates to:
  /// **'Hold the phone flat, away from metal. If the arrow drifts, move the phone in a figure of eight.'**
  String get qiblaCalibrate;

  /// No description provided for @qiblaNeedsPlace.
  ///
  /// In en, this message translates to:
  /// **'Choose a city to find the qibla'**
  String get qiblaNeedsPlace;

  /// No description provided for @salawatToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get salawatToday;

  /// No description provided for @salawatTotal.
  ///
  /// In en, this message translates to:
  /// **'All time: {count}'**
  String salawatTotal(int count);

  /// No description provided for @salawatGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get salawatGoal;

  /// No description provided for @salawatReset.
  ///
  /// In en, this message translates to:
  /// **'Reset today\'s count'**
  String get salawatReset;

  /// No description provided for @salawatTap.
  ///
  /// In en, this message translates to:
  /// **'Tap to count'**
  String get salawatTap;

  /// No description provided for @ofGoal.
  ///
  /// In en, this message translates to:
  /// **'of {goal}'**
  String ofGoal(int goal);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Adhan and notifications'**
  String get notifications;

  /// No description provided for @notificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Which prayers to announce'**
  String get notificationsHint;

  /// No description provided for @alarmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alarms'**
  String get alarmsTitle;

  /// No description provided for @alarms.
  ///
  /// In en, this message translates to:
  /// **'Suhoor and tahajjud alarms'**
  String get alarms;

  /// No description provided for @alarmsHint.
  ///
  /// In en, this message translates to:
  /// **'They follow Fajr, so the time shifts every day'**
  String get alarmsHint;

  /// No description provided for @prayerSettings.
  ///
  /// In en, this message translates to:
  /// **'Prayer time settings'**
  String get prayerSettings;

  /// No description provided for @prayerSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'City, method, corrections'**
  String get prayerSettingsHint;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @sources.
  ///
  /// In en, this message translates to:
  /// **'Sources and licences'**
  String get sources;

  /// No description provided for @permissionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get permissionNotifications;

  /// No description provided for @permissionNotificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Without this permission the adhan cannot sound'**
  String get permissionNotificationsHint;

  /// No description provided for @permissionExact.
  ///
  /// In en, this message translates to:
  /// **'Allow exact alarms'**
  String get permissionExact;

  /// No description provided for @permissionExactHint.
  ///
  /// In en, this message translates to:
  /// **'Otherwise Android may delay the adhan by several minutes'**
  String get permissionExactHint;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get permissionGranted;

  /// No description provided for @batteryHint.
  ///
  /// In en, this message translates to:
  /// **'If the adhan does not sound on time, turn off battery optimisation for MyFaith in the phone settings and allow autostart. Xiaomi, Huawei and Samsung phones close background apps most often.'**
  String get batteryHint;

  /// No description provided for @testAdhan.
  ///
  /// In en, this message translates to:
  /// **'Play the adhan now'**
  String get testAdhan;

  /// No description provided for @testScheduled.
  ///
  /// In en, this message translates to:
  /// **'The adhan should be playing. If it is silent, check the alarm volume.'**
  String get testScheduled;

  /// No description provided for @reminderBefore.
  ///
  /// In en, this message translates to:
  /// **'Reminder before prayer'**
  String get reminderBefore;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @minutesBefore.
  ///
  /// In en, this message translates to:
  /// **'{count} min before'**
  String minutesBefore(int count);

  /// No description provided for @hadithNotification.
  ///
  /// In en, this message translates to:
  /// **'Daily hadith notification'**
  String get hadithNotification;

  /// No description provided for @hadithTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get hadithTime;

  /// No description provided for @suhoorAlarm.
  ///
  /// In en, this message translates to:
  /// **'Suhoor alarm'**
  String get suhoorAlarm;

  /// No description provided for @suhoorBefore.
  ///
  /// In en, this message translates to:
  /// **'Wake up before Fajr'**
  String get suhoorBefore;

  /// No description provided for @suhoorDays.
  ///
  /// In en, this message translates to:
  /// **'On which days'**
  String get suhoorDays;

  /// No description provided for @suhoorRamadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get suhoorRamadan;

  /// No description provided for @suhoorMonThu.
  ///
  /// In en, this message translates to:
  /// **'Mondays and Thursdays'**
  String get suhoorMonThu;

  /// No description provided for @suhoorWhite.
  ///
  /// In en, this message translates to:
  /// **'White days (13th to 15th of the lunar month)'**
  String get suhoorWhite;

  /// No description provided for @suhoorDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get suhoorDaily;

  /// No description provided for @suhoorStop.
  ///
  /// In en, this message translates to:
  /// **'Warn before Fajr to stop eating'**
  String get suhoorStop;

  /// No description provided for @nextSuhoor.
  ///
  /// In en, this message translates to:
  /// **'Next alarm: {when}'**
  String nextSuhoor(String when);

  /// No description provided for @noUpcomingAlarm.
  ///
  /// In en, this message translates to:
  /// **'No alarm in the next 10 days'**
  String get noUpcomingAlarm;

  /// No description provided for @tahajjudAlarm.
  ///
  /// In en, this message translates to:
  /// **'Tahajjud alarm'**
  String get tahajjudAlarm;

  /// No description provided for @tahajjudWhen.
  ///
  /// In en, this message translates to:
  /// **'When to wake'**
  String get tahajjudWhen;

  /// No description provided for @tahajjudLastThird.
  ///
  /// In en, this message translates to:
  /// **'At the start of the last third of the night'**
  String get tahajjudLastThird;

  /// No description provided for @tahajjudBeforeFajr.
  ///
  /// In en, this message translates to:
  /// **'A set time before Fajr'**
  String get tahajjudBeforeFajr;

  /// No description provided for @weekdays.
  ///
  /// In en, this message translates to:
  /// **'Days of the week'**
  String get weekdays;

  /// No description provided for @hijriAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Hijri date correction'**
  String get hijriAdjustment;

  /// No description provided for @hijriAdjustmentHint.
  ///
  /// In en, this message translates to:
  /// **'If the month started on a different day in your country'**
  String get hijriAdjustmentHint;

  /// No description provided for @daysShift.
  ///
  /// In en, this message translates to:
  /// **'{count} d'**
  String daysShift(String count);

  /// No description provided for @notifAdhanTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for {prayer}'**
  String notifAdhanTitle(String prayer);

  /// No description provided for @notifSunriseTitle.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get notifSunriseTitle;

  /// No description provided for @notifAdhanBody.
  ///
  /// In en, this message translates to:
  /// **'{time}, {city}'**
  String notifAdhanBody(String time, String city);

  /// No description provided for @notifReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'{prayer} in {minutes} min'**
  String notifReminderTitle(String prayer, int minutes);

  /// No description provided for @notifSuhoorTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for suhoor'**
  String get notifSuhoorTitle;

  /// No description provided for @notifSuhoorBody.
  ///
  /// In en, this message translates to:
  /// **'Fajr at {time}'**
  String notifSuhoorBody(String time);

  /// No description provided for @notifSuhoorStopTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish eating'**
  String get notifSuhoorStopTitle;

  /// No description provided for @notifTahajjudTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for tahajjud'**
  String get notifTahajjudTitle;

  /// No description provided for @notifRefreshTitle.
  ///
  /// In en, this message translates to:
  /// **'Open MyFaith'**
  String get notifRefreshTitle;

  /// No description provided for @notifRefreshBody.
  ///
  /// In en, this message translates to:
  /// **'Open the app so the adhan keeps sounding in the coming days'**
  String get notifRefreshBody;

  /// No description provided for @channelAdhan.
  ///
  /// In en, this message translates to:
  /// **'Adhan'**
  String get channelAdhan;

  /// No description provided for @channelReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get channelReminder;

  /// No description provided for @channelAlarm.
  ///
  /// In en, this message translates to:
  /// **'Alarms'**
  String get channelAlarm;

  /// No description provided for @channelHadith.
  ///
  /// In en, this message translates to:
  /// **'Hadith of the day'**
  String get channelHadith;

  /// No description provided for @sourcesQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran text: King Fahd Complex, Uthmani script, Hafs. Translations: Elmir Kuliev (Russian), Saheeh International (English). Tafsir: Al-Mukhtasar, Tafsir Center for Quranic Studies.'**
  String get sourcesQuran;

  /// No description provided for @sourcesHadith.
  ///
  /// In en, this message translates to:
  /// **'Hadith: Sahih al-Bukhari. English by Muhsin Khan, Russian by Abdullah Nirsha. The hadith of the day is picked automatically from the shorter narrations.'**
  String get sourcesHadith;

  /// No description provided for @sourcesOther.
  ///
  /// In en, this message translates to:
  /// **'Prayer times: adhan_dart. Cities: GeoNames, CC BY 4.0. Arabic font: Amiri Quran, SIL Open Font License. Data collected from the open projects quran-api, hadith-api and tafsir_api. The translations belong to their authors and are used here for personal, non-commercial reading. Transliteration: quran-api (Latin); the Cyrillic one is derived from it automatically and is only a reading aid. Tajweed colours are derived by the app from the marks of the Uthmani text and do not replace learning with a teacher. Recitations are streamed from everyayah.com and need an internet connection. Dhikr, dua and the 99 names give their hadith sources on each card.'**
  String get sourcesOther;

  /// No description provided for @sourcesAdhan.
  ///
  /// In en, this message translates to:
  /// **'Adhan: recordings from Doha, Qatar, made in 2013–2014 (Internet Archive, public domain), and the adhans of Sheikh Tawfiq Khoj, Sheikh Turki al-Hassani and Sheikh Abdullah ibn Ahmad ibn Abdurrahman Ba-Afif.'**
  String get sourcesAdhan;

  /// No description provided for @muezzin.
  ///
  /// In en, this message translates to:
  /// **'Muezzin'**
  String get muezzin;

  /// No description provided for @channelAdhanFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr adhan'**
  String get channelAdhanFajr;

  /// No description provided for @testAdhanFajr.
  ///
  /// In en, this message translates to:
  /// **'Play the Fajr adhan'**
  String get testAdhanFajr;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'Notifications scheduled: {count}'**
  String syncPending(int count);

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'Scheduling failed: {error}'**
  String syncError(String error);

  /// No description provided for @stopAdhan.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopAdhan;

  /// No description provided for @widgetOpenHint.
  ///
  /// In en, this message translates to:
  /// **'Open MyFaith to refresh'**
  String get widgetOpenHint;

  /// No description provided for @navDhikr.
  ///
  /// In en, this message translates to:
  /// **'Dhikr'**
  String get navDhikr;

  /// No description provided for @dhikrTab.
  ///
  /// In en, this message translates to:
  /// **'Dhikr'**
  String get dhikrTab;

  /// No description provided for @duaTab.
  ///
  /// In en, this message translates to:
  /// **'Dua'**
  String get duaTab;

  /// No description provided for @dhikrToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dhikrToday;

  /// No description provided for @dhikrDone.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String dhikrDone(int done, int total);

  /// No description provided for @dhikrGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get dhikrGoal;

  /// No description provided for @dhikrGoalDefault.
  ///
  /// In en, this message translates to:
  /// **'{count} (recommended)'**
  String dhikrGoalDefault(int count);

  /// No description provided for @dhikrGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal for today reached'**
  String get dhikrGoalReached;

  /// No description provided for @names99.
  ///
  /// In en, this message translates to:
  /// **'99 names of Allah'**
  String get names99;

  /// No description provided for @names99Hint.
  ///
  /// In en, this message translates to:
  /// **'Quiz and full list'**
  String get names99Hint;

  /// No description provided for @namesQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get namesQuiz;

  /// No description provided for @namesList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get namesList;

  /// No description provided for @namesQuestion.
  ///
  /// In en, this message translates to:
  /// **'What does this name mean?'**
  String get namesQuestion;

  /// No description provided for @namesNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get namesNext;

  /// No description provided for @namesStreak.
  ///
  /// In en, this message translates to:
  /// **'In a row: {current} · best: {best}'**
  String namesStreak(int current, int best);

  /// No description provided for @surahs.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get surahs;

  /// No description provided for @mushaf.
  ///
  /// In en, this message translates to:
  /// **'Mushaf'**
  String get mushaf;

  /// No description provided for @byJuz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get byJuz;

  /// No description provided for @byPage.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get byPage;

  /// No description provided for @pageNumber.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String pageNumber(int page);

  /// No description provided for @juzNumber.
  ///
  /// In en, this message translates to:
  /// **'Juz {juz}'**
  String juzNumber(int juz);

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String pageOf(int page, int total);

  /// No description provided for @juzOf.
  ///
  /// In en, this message translates to:
  /// **'Juz {juz} of {total}'**
  String juzOf(int juz, int total);

  /// No description provided for @ayahNumber.
  ///
  /// In en, this message translates to:
  /// **'Ayah {ayah}'**
  String ayahNumber(int ayah);

  /// No description provided for @surahNumberName.
  ///
  /// In en, this message translates to:
  /// **'Surah {number}. {name}'**
  String surahNumberName(int number, String name);

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @previousAyah.
  ///
  /// In en, this message translates to:
  /// **'Previous ayah'**
  String get previousAyah;

  /// No description provided for @nextAyah.
  ///
  /// In en, this message translates to:
  /// **'Next ayah'**
  String get nextAyah;

  /// No description provided for @closePlayer.
  ///
  /// In en, this message translates to:
  /// **'Close the player'**
  String get closePlayer;

  /// No description provided for @audioFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the recording. Check the internet connection.'**
  String get audioFailed;

  /// No description provided for @reciter.
  ///
  /// In en, this message translates to:
  /// **'Reciter'**
  String get reciter;

  /// No description provided for @hideTafsir.
  ///
  /// In en, this message translates to:
  /// **'Hide tafsir'**
  String get hideTafsir;

  /// No description provided for @readerOptions.
  ///
  /// In en, this message translates to:
  /// **'Reading options'**
  String get readerOptions;

  /// No description provided for @showTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Transliteration'**
  String get showTransliteration;

  /// No description provided for @showTajweed.
  ///
  /// In en, this message translates to:
  /// **'Tajweed colours'**
  String get showTajweed;

  /// No description provided for @tajweedGhunnah.
  ///
  /// In en, this message translates to:
  /// **'Ghunnah, ikhfa, idgham'**
  String get tajweedGhunnah;

  /// No description provided for @tajweedGhunnahHint.
  ///
  /// In en, this message translates to:
  /// **'Idgham with ghunnah, ikhfa, iqlab, noon and meem with shadda, ikhfa shafawi'**
  String get tajweedGhunnahHint;

  /// No description provided for @tajweedQalqalah.
  ///
  /// In en, this message translates to:
  /// **'Qalqalah'**
  String get tajweedQalqalah;

  /// No description provided for @tajweedQalqalahHint.
  ///
  /// In en, this message translates to:
  /// **'The echoing bounce of ق ط ب ج د with sukun'**
  String get tajweedQalqalahHint;

  /// No description provided for @tajweedMaddNatural.
  ///
  /// In en, this message translates to:
  /// **'Madd, 2 counts'**
  String get tajweedMaddNatural;

  /// No description provided for @tajweedMaddNaturalHint.
  ///
  /// In en, this message translates to:
  /// **'Short silah, dagger alif'**
  String get tajweedMaddNaturalHint;

  /// No description provided for @tajweedMaddArid.
  ///
  /// In en, this message translates to:
  /// **'Madd, 2, 4 or 6 counts'**
  String get tajweedMaddArid;

  /// No description provided for @tajweedMaddAridHint.
  ///
  /// In en, this message translates to:
  /// **'Madd arid lis-sukun, madd leen'**
  String get tajweedMaddAridHint;

  /// No description provided for @tajweedMaddWajib.
  ///
  /// In en, this message translates to:
  /// **'Madd, 4 or 5 counts'**
  String get tajweedMaddWajib;

  /// No description provided for @tajweedMaddWajibHint.
  ///
  /// In en, this message translates to:
  /// **'Madd wajib muttasil, madd jaiz munfasil, long silah'**
  String get tajweedMaddWajibHint;

  /// No description provided for @tajweedMaddLazim.
  ///
  /// In en, this message translates to:
  /// **'Madd, 6 counts'**
  String get tajweedMaddLazim;

  /// No description provided for @tajweedMaddLazimHint.
  ///
  /// In en, this message translates to:
  /// **'Madd lazim'**
  String get tajweedMaddLazimHint;

  /// No description provided for @tajweedTafkhim.
  ///
  /// In en, this message translates to:
  /// **'Tafkhim'**
  String get tajweedTafkhim;

  /// No description provided for @tajweedTafkhimHint.
  ///
  /// In en, this message translates to:
  /// **'Heavy pronunciation: the letters خ ص ض غ ط ق ظ, heavy ra, the lam of the name Allah'**
  String get tajweedTafkhimHint;

  /// No description provided for @tajweedSilent.
  ///
  /// In en, this message translates to:
  /// **'Not read'**
  String get tajweedSilent;

  /// No description provided for @tajweedSilentHint.
  ///
  /// In en, this message translates to:
  /// **'Hamzat al-wasl, lam shamsiyyah, full idgham without ghunnah, silent letters'**
  String get tajweedSilentHint;

  /// No description provided for @autoNextAyah.
  ///
  /// In en, this message translates to:
  /// **'Play the next ayah automatically'**
  String get autoNextAyah;

  /// No description provided for @enterPage.
  ///
  /// In en, this message translates to:
  /// **'Enter a page number'**
  String get enterPage;

  /// No description provided for @openPage.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openPage;

  /// No description provided for @searchQuran.
  ///
  /// In en, this message translates to:
  /// **'Search the Quran'**
  String get searchQuran;

  /// No description provided for @searchQuranHint.
  ///
  /// In en, this message translates to:
  /// **'Word in the translation or in Arabic'**
  String get searchQuranHint;

  /// No description provided for @searchQuranPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type a word of at least two letters'**
  String get searchQuranPrompt;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// No description provided for @searchFound.
  ///
  /// In en, this message translates to:
  /// **'Ayahs found: {count}'**
  String searchFound(int count);

  /// No description provided for @searchManyFound.
  ///
  /// In en, this message translates to:
  /// **'The first {count} ayahs are shown. Add a word to narrow the search.'**
  String searchManyFound(int count);

  /// No description provided for @oneHourBefore.
  ///
  /// In en, this message translates to:
  /// **'1 hour before'**
  String get oneHourBefore;

  /// No description provided for @qiblaPoorAccuracy.
  ///
  /// In en, this message translates to:
  /// **'The phone reports that its compass is inaccurate. Move it in a figure of eight and take off a case with a magnet.'**
  String get qiblaPoorAccuracy;

  /// No description provided for @qiblaCheck.
  ///
  /// In en, this message translates to:
  /// **'Check yourself: from here the qibla lies to the {direction}. If the arrow points the opposite way, the compass of the phone is off.'**
  String qiblaCheck(String direction);

  /// No description provided for @compassPoints.
  ///
  /// In en, this message translates to:
  /// **'north,north-east,east,south-east,south,south-west,west,north-west'**
  String get compassPoints;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is out'**
  String updateAvailable(String version);

  /// No description provided for @updateHint.
  ///
  /// In en, this message translates to:
  /// **'Download the file and install it over this one. Your settings stay.'**
  String get updateHint;

  /// No description provided for @updateDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get updateDownload;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Not this one'**
  String get updateLater;

  /// No description provided for @checkUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkUpdates;

  /// No description provided for @checkUpdatesHint.
  ///
  /// In en, this message translates to:
  /// **'On start the app asks GitHub whether a newer version is out.'**
  String get checkUpdatesHint;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Installed: {version}.'**
  String versionLabel(String version);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
