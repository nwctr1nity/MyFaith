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
  String get rakaatsFajr => '2 rakaats sunnah, 2 rakaats fard';

  @override
  String get rakaatsDhuhr => '4 rakaats sunnah, 4 fard, 2 sunnah';

  @override
  String get rakaatsAsr => '4 rakaats fard';

  @override
  String get rakaatsMaghrib => '3 rakaats fard, 2 sunnah';

  @override
  String get rakaatsIsha => '4 rakaats fard, 2 sunnah, 3 witr';

  @override
  String get howToPray => 'How to pray?';

  @override
  String get howToPrayHint => 'Step by step, in the Hanafi school';

  @override
  String get guideRakaats => 'How many rakaats';

  @override
  String get guideSunnahBefore => 'Sunnah before';

  @override
  String get guideFard => 'Fard';

  @override
  String get guideSunnahAfter => 'Sunnah after';

  @override
  String get guideWitr => 'Witr';

  @override
  String get guideBefore => 'Before the prayer';

  @override
  String get guideSteps => 'A prayer of two rakaats';

  @override
  String get guideMore => 'What else to know';

  @override
  String soonLabel(int minutes) {
    return 'In $minutes min!';
  }

  @override
  String get showTransliterationItem => 'Show transliteration';

  @override
  String get repeatAyah => 'Repeat for memorising';

  @override
  String get repeatAyahHint =>
      'The ayah plays again and again until switched off';

  @override
  String get recitationSpeed => 'Recitation speed';

  @override
  String get resetSpeed => 'Reset to 1×';

  @override
  String get lastThirdOfNight => 'Last third of the night';

  @override
  String get settings => 'Settings';

  @override
  String get supportProject => 'Support the project';

  @override
  String get supportText =>
      'All donations are voluntary. My project will always be completely free.';

  @override
  String get tbank => 'T-Bank';

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

  @override
  String get navPrayer => 'Prayer';

  @override
  String get navQuran => 'Quran';

  @override
  String get navQibla => 'Qibla';

  @override
  String get navSalawat => 'Salawat';

  @override
  String get navMore => 'More';

  @override
  String atTime(String time) {
    return 'at $time';
  }

  @override
  String get hadithOfDay => 'Hadith of the day';

  @override
  String bukhariRef(int number) {
    return 'Sahih al-Bukhari, no. $number';
  }

  @override
  String get readMore => 'Read in full';

  @override
  String get previousDay => 'Previous';

  @override
  String get nextDay => 'Next';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get adhanOn => 'Adhan on';

  @override
  String get adhanOff => 'Adhan off';

  @override
  String get continueReading => 'Continue reading';

  @override
  String surahAyah(String surah, int ayah) {
    return '$surah, ayah $ayah';
  }

  @override
  String get searchSurah => 'Surah name or number';

  @override
  String ayahCount(int count) {
    return '$count ayahs';
  }

  @override
  String get makkan => 'Makkan';

  @override
  String get madinan => 'Madinan';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get noBookmarks =>
      'No bookmarks yet. Tap the bookmark icon under an ayah to save it.';

  @override
  String get tafsir => 'Tafsir';

  @override
  String get tafsirSource => 'Al-Mukhtasar fi Tafsir al-Quran';

  @override
  String get showTranslation => 'Translation';

  @override
  String get textSize => 'Text size';

  @override
  String get addBookmark => 'Add bookmark';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String qiblaDirection(String degrees) {
    return 'Qibla is $degrees° from north';
  }

  @override
  String get qiblaAligned => 'You are facing the qibla';

  @override
  String qiblaTurnRight(String degrees) {
    return 'Turn right by $degrees°';
  }

  @override
  String qiblaTurnLeft(String degrees) {
    return 'Turn left by $degrees°';
  }

  @override
  String get qiblaNoSensor =>
      'This device has no compass. Use the angle above with any compass.';

  @override
  String get qiblaCalibrate =>
      'Hold the phone flat, away from metal. If the arrow drifts, move the phone in a figure of eight.';

  @override
  String get qiblaNeedsPlace => 'Choose a city to find the qibla';

  @override
  String get salawatToday => 'Today';

  @override
  String salawatTotal(int count) {
    return 'All time: $count';
  }

  @override
  String get salawatGoal => 'Daily goal';

  @override
  String get salawatReset => 'Reset today\'s count';

  @override
  String get salawatTap => 'Tap to count';

  @override
  String ofGoal(int goal) {
    return 'of $goal';
  }

  @override
  String get notifications => 'Adhan and notifications';

  @override
  String get notificationsHint => 'Which prayers to announce';

  @override
  String get alarmsTitle => 'Alarms';

  @override
  String get alarms => 'Suhoor and tahajjud alarms';

  @override
  String get alarmsHint => 'They follow Fajr, so the time shifts every day';

  @override
  String get prayerSettings => 'Prayer time settings';

  @override
  String get prayerSettingsHint => 'City, method, corrections';

  @override
  String get appearance => 'Appearance';

  @override
  String get sources => 'Sources and licences';

  @override
  String get permissionNotifications => 'Allow notifications';

  @override
  String get permissionNotificationsHint =>
      'Without this permission the adhan cannot sound';

  @override
  String get permissionExact => 'Allow exact alarms';

  @override
  String get permissionExactHint =>
      'Otherwise Android may delay the adhan by several minutes';

  @override
  String get permissionGranted => 'Allowed';

  @override
  String get batteryHint =>
      'If the adhan does not sound on time, turn off battery optimisation for MyFaith in the phone settings and allow autostart. Xiaomi, Huawei and Samsung phones close background apps most often.';

  @override
  String get testAdhan => 'Play the adhan now';

  @override
  String get testScheduled =>
      'The adhan should be playing. If it is silent, check the alarm volume.';

  @override
  String get reminderBefore => 'Reminder before prayer';

  @override
  String get off => 'Off';

  @override
  String minutesBefore(int count) {
    return '$count min before';
  }

  @override
  String get hadithNotification => 'Daily hadith notification';

  @override
  String get hadithTime => 'Time';

  @override
  String get suhoorAlarm => 'Suhoor alarm';

  @override
  String get suhoorBefore => 'Wake up before Fajr';

  @override
  String get suhoorDays => 'On which days';

  @override
  String get suhoorRamadan => 'Ramadan';

  @override
  String get suhoorMonThu => 'Mondays and Thursdays';

  @override
  String get suhoorWhite => 'White days (13th to 15th of the lunar month)';

  @override
  String get suhoorDaily => 'Every day';

  @override
  String get suhoorStop => 'Warn before Fajr to stop eating';

  @override
  String nextSuhoor(String when) {
    return 'Next alarm: $when';
  }

  @override
  String get noUpcomingAlarm => 'No alarm in the next 10 days';

  @override
  String get tahajjudAlarm => 'Tahajjud alarm';

  @override
  String get tahajjudWhen => 'When to wake';

  @override
  String get tahajjudLastThird => 'At the start of the last third of the night';

  @override
  String get tahajjudBeforeFajr => 'A set time before Fajr';

  @override
  String get weekdays => 'Days of the week';

  @override
  String get hijriAdjustment => 'Hijri date correction';

  @override
  String get hijriAdjustmentHint =>
      'If the month started on a different day in your country';

  @override
  String daysShift(String count) {
    return '$count d';
  }

  @override
  String notifAdhanTitle(String prayer) {
    return 'Time for $prayer';
  }

  @override
  String get notifSunriseTitle => 'Sunrise';

  @override
  String notifAdhanBody(String time, String city) {
    return '$time, $city';
  }

  @override
  String notifReminderTitle(String prayer, int minutes) {
    return '$prayer in $minutes min';
  }

  @override
  String get notifSuhoorTitle => 'Time for suhoor';

  @override
  String notifSuhoorBody(String time) {
    return 'Fajr at $time';
  }

  @override
  String get notifSuhoorStopTitle => 'Finish eating';

  @override
  String get notifTahajjudTitle => 'Time for tahajjud';

  @override
  String get notifRefreshTitle => 'Open MyFaith';

  @override
  String get notifRefreshBody =>
      'Open the app so the adhan keeps sounding in the coming days';

  @override
  String get channelAdhan => 'Adhan';

  @override
  String get channelReminder => 'Reminders';

  @override
  String get channelAlarm => 'Alarms';

  @override
  String get channelHadith => 'Hadith of the day';

  @override
  String get sourcesQuran =>
      'Quran text: King Fahd Complex, Uthmani script, Hafs. Translations: Elmir Kuliev (Russian), Saheeh International (English). Tafsir: Al-Mukhtasar, Tafsir Center for Quranic Studies.';

  @override
  String get sourcesHadith =>
      'Hadith: Sahih al-Bukhari. English by Muhsin Khan, Russian by Abdullah Nirsha. The hadith of the day is picked automatically from the shorter narrations.';

  @override
  String get sourcesOther =>
      'Prayer times: adhan_dart. Cities: GeoNames, CC BY 4.0. Arabic font: Amiri Quran, SIL Open Font License. Data collected from the open projects quran-api, hadith-api and tafsir_api. The translations belong to their authors and are used here for personal, non-commercial reading. Transliteration: quran-api (Latin); the Cyrillic one is derived from it automatically and is only a reading aid. Tajweed colours are derived by the app from the marks of the Uthmani text and do not replace learning with a teacher. Recitations are streamed from everyayah.com and need an internet connection. Dhikr, dua and the 99 names give their hadith sources on each card.';

  @override
  String get sourcesAdhan =>
      'Adhan: recordings from Doha, Qatar, made in 2013–2014 (Internet Archive, public domain), and the adhans of Sheikh Tawfiq Khoj, Sheikh Turki al-Hassani and Sheikh Abdullah ibn Ahmad ibn Abdurrahman Ba-Afif. Dua after the adhan: a recording from hisnmuslim.com (Fortress of the Muslim).';

  @override
  String get muezzin => 'Muezzin';

  @override
  String get channelAdhanFajr => 'Fajr adhan';

  @override
  String get testAdhanFajr => 'Play the Fajr adhan';

  @override
  String syncPending(int count) {
    return 'Notifications scheduled: $count';
  }

  @override
  String syncError(String error) {
    return 'Scheduling failed: $error';
  }

  @override
  String get stopAdhan => 'Stop';

  @override
  String get widgetOpenHint => 'Open MyFaith to refresh';

  @override
  String get navDhikr => 'Dhikr';

  @override
  String get dhikrTab => 'Dhikr';

  @override
  String get duaTab => 'Dua';

  @override
  String get dhikrToday => 'Today';

  @override
  String dhikrDone(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get dhikrGoal => 'Daily goal';

  @override
  String dhikrGoalDefault(int count) {
    return '$count (recommended)';
  }

  @override
  String get dhikrGoalReached => 'Goal for today reached';

  @override
  String get names99 => '99 names of Allah';

  @override
  String get names99Hint => 'Quiz and full list';

  @override
  String get namesQuiz => 'Quiz';

  @override
  String get namesList => 'List';

  @override
  String get namesQuestion => 'What does this name mean?';

  @override
  String get namesNext => 'Next';

  @override
  String namesStreak(int current, int best) {
    return 'In a row: $current · best: $best';
  }

  @override
  String get surahs => 'Surahs';

  @override
  String get mushaf => 'Mushaf';

  @override
  String get byJuz => 'Juz';

  @override
  String get byPage => 'Pages';

  @override
  String pageNumber(int page) {
    return 'Page $page';
  }

  @override
  String juzNumber(int juz) {
    return 'Juz $juz';
  }

  @override
  String pageOf(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String juzOf(int juz, int total) {
    return 'Juz $juz of $total';
  }

  @override
  String ayahNumber(int ayah) {
    return 'Ayah $ayah';
  }

  @override
  String surahNumberName(int number, String name) {
    return 'Surah $number. $name';
  }

  @override
  String get listen => 'Listen';

  @override
  String get pause => 'Pause';

  @override
  String get previousAyah => 'Previous ayah';

  @override
  String get nextAyah => 'Next ayah';

  @override
  String get closePlayer => 'Close the player';

  @override
  String get audioFailed =>
      'Could not load the recording. Check the internet connection.';

  @override
  String get reciter => 'Reciter';

  @override
  String get hideTafsir => 'Hide tafsir';

  @override
  String get readerOptions => 'Reading options';

  @override
  String get showTransliteration => 'Transliteration';

  @override
  String get showTajweed => 'Tajweed colours';

  @override
  String get tajweedGhunnah => 'Ghunnah, ikhfa, idgham';

  @override
  String get tajweedGhunnahHint =>
      'Idgham with ghunnah, ikhfa, iqlab, noon and meem with shadda, ikhfa shafawi';

  @override
  String get tajweedQalqalah => 'Qalqalah';

  @override
  String get tajweedQalqalahHint =>
      'The echoing bounce of ق ط ب ج د with sukun';

  @override
  String get tajweedMaddNatural => 'Madd, 2 counts';

  @override
  String get tajweedMaddNaturalHint => 'Short silah, dagger alif';

  @override
  String get tajweedMaddArid => 'Madd, 2, 4 or 6 counts';

  @override
  String get tajweedMaddAridHint => 'Madd arid lis-sukun, madd leen';

  @override
  String get tajweedMaddWajib => 'Madd, 4 or 5 counts';

  @override
  String get tajweedMaddWajibHint =>
      'Madd wajib muttasil, madd jaiz munfasil, long silah';

  @override
  String get tajweedMaddLazim => 'Madd, 6 counts';

  @override
  String get tajweedMaddLazimHint => 'Madd lazim';

  @override
  String get tajweedTafkhim => 'Tafkhim';

  @override
  String get tajweedTafkhimHint =>
      'Heavy pronunciation: the letters خ ص ض غ ط ق ظ, heavy ra, the lam of the name Allah';

  @override
  String get tajweedSilent => 'Not read';

  @override
  String get tajweedSilentHint =>
      'Hamzat al-wasl, lam shamsiyyah, full idgham without ghunnah, silent letters';

  @override
  String get autoNextAyah => 'Play the next ayah automatically';

  @override
  String get enterPage => 'Enter a page number';

  @override
  String get openPage => 'Open';

  @override
  String get searchQuran => 'Search the Quran';

  @override
  String get searchQuranHint => 'Word in the translation or in Arabic';

  @override
  String get searchQuranPrompt => 'Type a word of at least two letters';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String searchFound(int count) {
    return 'Ayahs found: $count';
  }

  @override
  String searchManyFound(int count) {
    return 'The first $count ayahs are shown. Add a word to narrow the search.';
  }

  @override
  String get oneHourBefore => '1 hour before';

  @override
  String get qiblaPoorAccuracy =>
      'The phone reports that its compass is inaccurate. Move it in a figure of eight and take off a case with a magnet.';

  @override
  String qiblaCheck(String direction) {
    return 'Check yourself: from here the qibla lies to the $direction. If the arrow points the opposite way, the compass of the phone is off.';
  }

  @override
  String get compassPoints =>
      'north,north-east,east,south-east,south,south-west,west,north-west';

  @override
  String updateAvailable(String version) {
    return 'Version $version is out';
  }

  @override
  String get updateHint =>
      'Download the file and install it over this one. Your settings stay.';

  @override
  String get updateDownload => 'Download';

  @override
  String get updateLater => 'Not this one';

  @override
  String get checkUpdates => 'Check for updates';

  @override
  String get checkUpdatesHint =>
      'On start the app asks GitHub whether a newer version is out.';

  @override
  String versionLabel(String version) {
    return 'Installed: $version.';
  }

  @override
  String get channelQuran => 'Quran recitation';

  @override
  String get offlineListening => 'Listen without the internet';

  @override
  String get offlineListeningHint => 'Download surahs to the phone';

  @override
  String offlineHint(String reciter) {
    return 'Downloaded surahs play without the internet. They are saved for the chosen reciter: $reciter.';
  }

  @override
  String offlineProgress(int done, int total) {
    return '$done of $total ayahs';
  }

  @override
  String get offlineFailed =>
      'Download stopped. Check the internet and try again.';

  @override
  String get offlineSaved => 'On the phone';

  @override
  String get offlineDelete => 'Delete from the phone';

  @override
  String get offlineDownload => 'Download';

  @override
  String get backup => 'Backup';

  @override
  String get backupSave => 'Save to a file';

  @override
  String get backupSaveHint => 'Settings, city, bookmarks, counters and goals';

  @override
  String get backupRestore => 'Restore from a file';

  @override
  String get backupRestoreHint => 'Choose a file saved earlier';

  @override
  String get backupSaved => 'The backup is saved';

  @override
  String get backupNotOurs => 'This is not a MyFaith backup file';

  @override
  String get backupRestoreConfirm =>
      'The current settings, bookmarks and counters will be replaced with the ones from the file.';

  @override
  String get backupRestoreAction => 'Restore';

  @override
  String get backupRestored => 'Restored from the file';

  @override
  String get guideAdhan => 'The adhan and the iqamah';

  @override
  String get undo => 'Undo';

  @override
  String get missedLabel => 'Missed';

  @override
  String missedMarked(String prayer) {
    return '$prayer is marked as missed';
  }

  @override
  String missedUnmarked(String prayer) {
    return 'The mark is removed from $prayer';
  }

  @override
  String get qadaTitle => 'Missed prayers';

  @override
  String get qadaNone => 'None to make up';

  @override
  String qadaTotal(int count) {
    return 'To make up: $count';
  }

  @override
  String get qadaHint =>
      'Every prayer counts as prayed. If you missed one, press and hold it on the prayer screen: it is added here. When you make it up, press the minus.';

  @override
  String get qadaButtonsHint =>
      'Plus adds a prayer missed earlier, minus takes away one you have made up.';

  @override
  String get qadaMadeUp => 'Made up';

  @override
  String get qadaAdd => 'Add a missed prayer';

  @override
  String get adhanDua => 'Dua after the adhan';

  @override
  String get adhanDuaHint =>
      'Three seconds after the adhan the dua “Allahumma Rabba hadhihi-d-da‘wati-t-tammah” is played.';

  @override
  String get hijriCalendar => 'Hijri calendar';

  @override
  String get hijriComing => 'Coming dates';

  @override
  String get hijriWhiteDays =>
      'White days (13th, 14th, 15th): fasting is recommended';

  @override
  String get hijriNote =>
      'The calendar is calculated (Umm al-Qura). The real start of a month depends on the sighting of the moon and may differ by a day; the shift is set in the settings.';

  @override
  String inDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count days',
      one: 'tomorrow',
      zero: 'today',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Today';

  @override
  String get eventNewYear => 'Islamic New Year';

  @override
  String get eventAshura => 'Day of Ashura';

  @override
  String get eventRamadan => 'Start of Ramadan';

  @override
  String get eventLastTen => 'The last ten nights of Ramadan';

  @override
  String get eventEidFitr => 'Eid al-Fitr';

  @override
  String get eventFirstTen => 'The first ten days of Dhu al-Hijjah';

  @override
  String get eventArafah => 'Day of Arafah';

  @override
  String get eventEidAdha => 'Eid al-Adha';

  @override
  String get eventTashriq => 'Days of Tashriq';

  @override
  String get ramadan => 'Ramadan';

  @override
  String get untilIftar => 'Until iftar';

  @override
  String get untilSuhoorEnd => 'Until the end of suhoor';

  @override
  String get iftarDua => 'Dua when breaking the fast';

  @override
  String get ramadanMode => 'Fasting countdown';

  @override
  String get ramadanModeHint => 'A card on the prayer screen.';

  @override
  String get ramadanAuto => 'In Ramadan';

  @override
  String get ramadanAutoHint =>
      'Appears with the Maghrib before the first fast and goes away on the eve of Eid';

  @override
  String get ramadanAlways => 'Always';

  @override
  String get ramadanAlwaysHint => 'For voluntary fasts too';

  @override
  String get ramadanNever => 'Never';

  @override
  String get suhoorOffer => 'Wake you for suhoor during Ramadan?';

  @override
  String get suhoorOfferYes => 'Wake me';

  @override
  String get suhoorOfferNo => 'No, thanks';

  @override
  String get suhoorOfferDone =>
      'The suhoor alarm is on. Its time can be changed under Alarms on the More tab.';

  @override
  String get morningTab => 'Morning';

  @override
  String get eveningTab => 'Evening';

  @override
  String get adhkarSection => 'Adhkar and Friday';

  @override
  String get adhkarMorningReminder => 'Morning adhkar';

  @override
  String get adhkarMorningReminderHint => 'A reminder 30 minutes after Fajr';

  @override
  String get adhkarEveningReminder => 'Evening adhkar';

  @override
  String get adhkarEveningReminderHint => 'A reminder 15 minutes after Asr';

  @override
  String get kahfReminder => 'Surah al-Kahf on Friday';

  @override
  String get kahfReminderHint => 'A reminder on Friday at 9:00';

  @override
  String get notifAdhkarMorningBody => 'Tap to open the morning adhkar.';

  @override
  String get notifAdhkarEveningBody => 'Tap to open the evening adhkar.';

  @override
  String get notifKahfTitle => 'Friday: Surah al-Kahf';

  @override
  String get notifKahfBody =>
      'It is recommended to read Surah al-Kahf on Friday. Tap to open it.';

  @override
  String get share => 'Share';

  @override
  String get favoriteAdd => 'Add to favourites';

  @override
  String get favoriteRemove => 'Remove from favourites';

  @override
  String get favoriteHadiths => 'Favourite hadiths';

  @override
  String get noFavoriteHadiths =>
      'No favourites yet. Press the star on a hadith to keep it here.';
}
