// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مواقيت الصلاة';

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerSunrise => 'الشروق';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String nextPrayerIn(String prayer) {
    return '$prayer بعد';
  }

  @override
  String get nowLabel => 'الآن';

  @override
  String get rakaatsFajr => 'ركعتان سنة، ركعتان فرض';

  @override
  String get rakaatsDhuhr => '4 ركعات سنة، 4 فرض، ركعتان سنة';

  @override
  String get rakaatsAsr => '4 ركعات فرض';

  @override
  String get rakaatsMaghrib => '3 ركعات فرض، ركعتان سنة';

  @override
  String get rakaatsIsha => '4 ركعات فرض، ركعتان سنة، 3 وتر';

  @override
  String get howToPray => 'كيف أصلي؟';

  @override
  String get howToPrayHint => 'خطوة بخطوة على المذهب الحنفي';

  @override
  String get guideRakaats => 'عدد الركعات';

  @override
  String get guideSunnahBefore => 'سنة قبلية';

  @override
  String get guideFard => 'فرض';

  @override
  String get guideSunnahAfter => 'سنة بعدية';

  @override
  String get guideWitr => 'وتر';

  @override
  String get guideBefore => 'قبل الصلاة';

  @override
  String get guideSteps => 'صلاة من ركعتين';

  @override
  String get guideMore => 'أمور أخرى مهمة';

  @override
  String soonLabel(int minutes) {
    return 'بعد $minutes د!';
  }

  @override
  String get showTransliterationItem => 'إظهار النطق';

  @override
  String get repeatAyah => 'التكرار للحفظ';

  @override
  String get repeatAyahHint => 'تتكرر الآية حتى توقف التكرار';

  @override
  String get recitationSpeed => 'سرعة التلاوة';

  @override
  String get resetSpeed => 'إعادة إلى 1×';

  @override
  String get lastThirdOfNight => 'الثلث الأخير من الليل';

  @override
  String get settings => 'الإعدادات';

  @override
  String get supportProject => 'ادعم المشروع';

  @override
  String get supportText =>
      'جميع التبرعات طوعية. سيبقى مشروعي مجانيًا بالكامل دائمًا.';

  @override
  String get tbank => 'T-Bank';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'لغة الجهاز';

  @override
  String get location => 'الموقع';

  @override
  String get chooseCity => 'اختيار مدينة';

  @override
  String get useMyLocation => 'استخدام موقعي';

  @override
  String get searchCity => 'اسم المدينة';

  @override
  String get searchCityHint => 'اكتب حرفين على الأقل';

  @override
  String get noCitiesFound => 'لم يُعثر على مدن';

  @override
  String get locationNotSet => 'اختر مدينة لعرض مواقيت الصلاة';

  @override
  String get locationDenied => 'لم يُمنح إذن الموقع. اختر مدينة يدويًا.';

  @override
  String get locationDisabled =>
      'خدمة الموقع متوقفة على الجهاز. شغّلها أو اختر مدينة يدويًا.';

  @override
  String get locationFailed => 'تعذّر تحديد الموقع. اختر مدينة يدويًا.';

  @override
  String get myLocation => 'موقعي';

  @override
  String get calculation => 'الحساب';

  @override
  String get method => 'طريقة الحساب';

  @override
  String methodAngles(String fajr, String isha) {
    return 'الفجر $fajr°، العشاء $isha°';
  }

  @override
  String methodAnglesInterval(String fajr, int minutes) {
    return 'الفجر $fajr°، العشاء بعد المغرب بـ $minutes دقيقة';
  }

  @override
  String get asrMadhab => 'وقت العصر';

  @override
  String get madhabShafi => 'الشافعي والمالكي والحنبلي';

  @override
  String get madhabHanafi => 'الحنفي (متأخر)';

  @override
  String get adjustments => 'تعديل بالدقائق';

  @override
  String get adjustmentsHint => 'عدّل الوقت ليطابق تقويم مسجدك';

  @override
  String minutesShort(String count) {
    return '$count د';
  }

  @override
  String get theme => 'المظهر';

  @override
  String get themeSystem => 'كما في الجهاز';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get methodMuslimWorldLeague => 'رابطة العالم الإسلامي';

  @override
  String get methodRussia => 'روسيا';

  @override
  String get methodTurkiye => 'تركيا (ديانت)';

  @override
  String get methodUmmAlQura => 'أم القرى، مكة المكرمة';

  @override
  String get methodEgyptian => 'مصر';

  @override
  String get methodKarachi => 'كراتشي';

  @override
  String get methodNorthAmerica => 'أمريكا الشمالية (ISNA)';

  @override
  String get methodDubai => 'دبي';

  @override
  String get methodQatar => 'قطر';

  @override
  String get methodKuwait => 'الكويت';

  @override
  String get methodGulfRegion => 'دول الخليج';

  @override
  String get methodSingapore => 'سنغافورة وماليزيا';

  @override
  String get methodIndonesian => 'إندونيسيا';

  @override
  String get methodTehran => 'طهران';

  @override
  String get methodJafari => 'الجعفري';

  @override
  String get methodFrance => 'فرنسا';

  @override
  String get methodJordan => 'الأردن';

  @override
  String get methodMorocco => 'المغرب';

  @override
  String get methodAlgerian => 'الجزائر';

  @override
  String get methodTunisia => 'تونس';

  @override
  String get methodPortugal => 'البرتغال';

  @override
  String get methodMoonsightingCommittee => 'Moonsighting Committee';

  @override
  String get navPrayer => 'الصلاة';

  @override
  String get navQuran => 'القرآن';

  @override
  String get navQibla => 'القبلة';

  @override
  String get navSalawat => 'الصلاة على النبي';

  @override
  String get navMore => 'المزيد';

  @override
  String atTime(String time) {
    return 'في $time';
  }

  @override
  String get hadithOfDay => 'حديث اليوم';

  @override
  String bukhariRef(int number) {
    return 'صحيح البخاري، رقم $number';
  }

  @override
  String get readMore => 'قراءة كاملة';

  @override
  String get previousDay => 'السابق';

  @override
  String get nextDay => 'التالي';

  @override
  String get copy => 'نسخ';

  @override
  String get copied => 'تم النسخ';

  @override
  String get adhanOn => 'الأذان مفعّل';

  @override
  String get adhanOff => 'الأذان متوقف';

  @override
  String get continueReading => 'متابعة القراءة';

  @override
  String surahAyah(String surah, int ayah) {
    return '$surah، الآية $ayah';
  }

  @override
  String get searchSurah => 'اسم السورة أو رقمها';

  @override
  String ayahCount(int count) {
    return '$count آية';
  }

  @override
  String get makkan => 'مكية';

  @override
  String get madinan => 'مدنية';

  @override
  String get bookmarks => 'العلامات';

  @override
  String get noBookmarks =>
      'لا توجد علامات بعد. اضغط على أيقونة العلامة تحت الآية لحفظها.';

  @override
  String get tafsir => 'التفسير';

  @override
  String get tafsirSource => 'المختصر في تفسير القرآن الكريم';

  @override
  String get showTranslation => 'الترجمة';

  @override
  String get textSize => 'حجم الخط';

  @override
  String get addBookmark => 'إضافة علامة';

  @override
  String get removeBookmark => 'إزالة العلامة';

  @override
  String qiblaDirection(String degrees) {
    return 'القبلة: $degrees° من الشمال';
  }

  @override
  String get qiblaAligned => 'أنت متجه نحو القبلة';

  @override
  String qiblaTurnRight(String degrees) {
    return 'استدر يمينًا $degrees°';
  }

  @override
  String qiblaTurnLeft(String degrees) {
    return 'استدر يسارًا $degrees°';
  }

  @override
  String get qiblaNoSensor =>
      'لا توجد بوصلة في هذا الجهاز. استخدم الزاوية أعلاه مع أي بوصلة.';

  @override
  String get qiblaCalibrate =>
      'أمسك الهاتف أفقيًا بعيدًا عن المعادن. إذا تذبذب السهم فحرّك الهاتف على شكل الرقم ثمانية.';

  @override
  String get qiblaNeedsPlace => 'اختر مدينة لتحديد القبلة';

  @override
  String get salawatToday => 'اليوم';

  @override
  String salawatTotal(int count) {
    return 'الإجمالي: $count';
  }

  @override
  String get salawatGoal => 'الهدف اليومي';

  @override
  String get salawatReset => 'تصفير عدّاد اليوم';

  @override
  String get salawatTap => 'اضغط للعدّ';

  @override
  String ofGoal(int goal) {
    return 'من $goal';
  }

  @override
  String get notifications => 'الأذان والإشعارات';

  @override
  String get notificationsHint => 'الصلوات التي يُؤذَّن لها';

  @override
  String get alarmsTitle => 'المنبهات';

  @override
  String get alarms => 'منبّه السحور والتهجد';

  @override
  String get alarmsHint => 'مرتبطة بالفجر فيتغير وقتها كل يوم';

  @override
  String get prayerSettings => 'إعدادات مواقيت الصلاة';

  @override
  String get prayerSettingsHint => 'المدينة والطريقة والتعديلات';

  @override
  String get appearance => 'المظهر';

  @override
  String get sources => 'المصادر والتراخيص';

  @override
  String get permissionNotifications => 'السماح بالإشعارات';

  @override
  String get permissionNotificationsHint => 'بدون هذا الإذن لن يُسمع الأذان';

  @override
  String get permissionExact => 'السماح بالمنبّهات الدقيقة';

  @override
  String get permissionExactHint => 'وإلا فقد يؤخّر أندرويد الأذان عدة دقائق';

  @override
  String get permissionGranted => 'مسموح';

  @override
  String get batteryHint =>
      'إذا لم يُسمع الأذان في وقته فأوقف تحسين البطارية لتطبيق MyFaith من إعدادات الهاتف واسمح بالتشغيل التلقائي. هواتف شاومي وهواوي وسامسونج هي الأكثر إغلاقًا للتطبيقات في الخلفية.';

  @override
  String get testAdhan => 'تشغيل الأذان الآن';

  @override
  String get testScheduled =>
      'من المفترض أن يُسمع الأذان الآن. إن لم تسمعه فتحقق من مستوى صوت المنبه.';

  @override
  String get reminderBefore => 'تذكير قبل الصلاة';

  @override
  String get off => 'متوقف';

  @override
  String minutesBefore(int count) {
    return 'قبل $count د';
  }

  @override
  String get hadithNotification => 'إشعار حديث اليوم';

  @override
  String get hadithTime => 'الوقت';

  @override
  String get suhoorAlarm => 'منبّه السحور';

  @override
  String get suhoorBefore => 'الاستيقاظ قبل الفجر';

  @override
  String get suhoorDays => 'في أي الأيام';

  @override
  String get suhoorRamadan => 'رمضان';

  @override
  String get suhoorMonThu => 'الاثنين والخميس';

  @override
  String get suhoorWhite => 'الأيام البيض (13–15 من الشهر القمري)';

  @override
  String get suhoorDaily => 'كل يوم';

  @override
  String get suhoorStop => 'تنبيه قبل الفجر للإمساك';

  @override
  String nextSuhoor(String when) {
    return 'المنبّه القادم: $when';
  }

  @override
  String get noUpcomingAlarm => 'لا يوجد منبّه خلال الأيام العشرة القادمة';

  @override
  String get tahajjudAlarm => 'منبّه التهجد';

  @override
  String get tahajjudWhen => 'وقت الاستيقاظ';

  @override
  String get tahajjudLastThird => 'في بداية الثلث الأخير من الليل';

  @override
  String get tahajjudBeforeFajr => 'قبل الفجر بمدة محددة';

  @override
  String get weekdays => 'أيام الأسبوع';

  @override
  String get hijriAdjustment => 'تعديل التاريخ الهجري';

  @override
  String get hijriAdjustmentHint => 'إذا بدأ الشهر في يوم مختلف في بلدك';

  @override
  String daysShift(String count) {
    return '$count يوم';
  }

  @override
  String notifAdhanTitle(String prayer) {
    return 'حان وقت صلاة $prayer';
  }

  @override
  String get notifSunriseTitle => 'شروق الشمس';

  @override
  String notifAdhanBody(String time, String city) {
    return '$time، $city';
  }

  @override
  String notifReminderTitle(String prayer, int minutes) {
    return '$prayer بعد $minutes د';
  }

  @override
  String get notifSuhoorTitle => 'وقت السحور';

  @override
  String notifSuhoorBody(String time) {
    return 'الفجر في $time';
  }

  @override
  String get notifSuhoorStopTitle => 'حان وقت الإمساك';

  @override
  String get notifTahajjudTitle => 'وقت التهجد';

  @override
  String get notifRefreshTitle => 'افتح MyFaith';

  @override
  String get notifRefreshBody => 'افتح التطبيق ليستمر الأذان في الأيام القادمة';

  @override
  String get channelAdhan => 'الأذان';

  @override
  String get channelReminder => 'التذكيرات';

  @override
  String get channelAlarm => 'المنبّهات';

  @override
  String get channelHadith => 'حديث اليوم';

  @override
  String get sourcesQuran =>
      'نص القرآن: مجمع الملك فهد، الرسم العثماني برواية حفص. الترجمات: إلمير قولييف (الروسية)، صحيح إنترناشيونال (الإنجليزية). التفسير: المختصر، مركز تفسير للدراسات القرآنية.';

  @override
  String get sourcesHadith =>
      'الحديث: صحيح البخاري. الترجمة الإنجليزية لمحسن خان والروسية لعبد الله نيرشا. يُختار حديث اليوم تلقائيًا من الأحاديث القصيرة.';

  @override
  String get sourcesOther =>
      'مواقيت الصلاة: adhan_dart. المدن: GeoNames، CC BY 4.0. الخط العربي: Amiri Quran برخصة SIL Open Font. جُمعت البيانات من المشاريع المفتوحة quran-api و hadith-api و tafsir_api. الترجمات ملك لأصحابها وتُستخدم هنا للقراءة الشخصية غير التجارية. النطق بالحروف اللاتينية من quran-api. ألوان التجويد يستخرجها التطبيق من علامات الرسم العثماني ولا تغني عن التلقي من معلم. التلاوات تُبث من everyayah.com وتحتاج إلى الإنترنت.';

  @override
  String get sourcesAdhan =>
      'الأذان: تسجيلات من الدوحة (قطر) بين عامي 2013 و2014 (أرشيف الإنترنت، ملكية عامة)، وأذان الشيخ توفيق خوج والشيخ تركي الحسني والشيخ عبد الله بن أحمد بن عبد الرحمن باعفيف.';

  @override
  String get muezzin => 'المؤذن';

  @override
  String get channelAdhanFajr => 'أذان الفجر';

  @override
  String get testAdhanFajr => 'تشغيل أذان الفجر';

  @override
  String syncPending(int count) {
    return 'الإشعارات المجدولة: $count';
  }

  @override
  String syncError(String error) {
    return 'تعذرت الجدولة: $error';
  }

  @override
  String get stopAdhan => 'إيقاف';

  @override
  String get widgetOpenHint => 'افتح MyFaith للتحديث';

  @override
  String get navDhikr => 'الأذكار';

  @override
  String get dhikrTab => 'الأذكار';

  @override
  String get duaTab => 'الأدعية';

  @override
  String get dhikrToday => 'اليوم';

  @override
  String dhikrDone(int done, int total) {
    return 'أُنجز $done من $total';
  }

  @override
  String get dhikrGoal => 'الهدف اليومي';

  @override
  String dhikrGoalDefault(int count) {
    return '$count (موصى به)';
  }

  @override
  String get dhikrGoalReached => 'تم بلوغ هدف اليوم';

  @override
  String get names99 => 'أسماء الله الحسنى';

  @override
  String get names99Hint => 'اختبار وقائمة كاملة';

  @override
  String get namesQuiz => 'اختبار';

  @override
  String get namesList => 'القائمة';

  @override
  String get namesQuestion => 'ما معنى هذا الاسم؟';

  @override
  String get namesNext => 'التالي';

  @override
  String namesStreak(int current, int best) {
    return 'على التوالي: $current · الأفضل: $best';
  }

  @override
  String get surahs => 'السور';

  @override
  String get mushaf => 'المصحف';

  @override
  String get byJuz => 'الأجزاء';

  @override
  String get byPage => 'الصفحات';

  @override
  String pageNumber(int page) {
    return 'الصفحة $page';
  }

  @override
  String juzNumber(int juz) {
    return 'الجزء $juz';
  }

  @override
  String pageOf(int page, int total) {
    return 'الصفحة $page من $total';
  }

  @override
  String juzOf(int juz, int total) {
    return 'الجزء $juz من $total';
  }

  @override
  String ayahNumber(int ayah) {
    return 'الآية $ayah';
  }

  @override
  String surahNumberName(int number, String name) {
    return 'سورة $number. $name';
  }

  @override
  String get listen => 'استماع';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get previousAyah => 'الآية السابقة';

  @override
  String get nextAyah => 'الآية التالية';

  @override
  String get closePlayer => 'إغلاق المشغل';

  @override
  String get audioFailed => 'تعذّر تحميل التسجيل. تحقق من الاتصال بالإنترنت.';

  @override
  String get reciter => 'القارئ';

  @override
  String get hideTafsir => 'إخفاء التفسير';

  @override
  String get readerOptions => 'إعدادات القراءة';

  @override
  String get showTransliteration => 'النطق بالحروف';

  @override
  String get showTajweed => 'ألوان التجويد';

  @override
  String get tajweedGhunnah => 'غنة، إخفاء، إدغام';

  @override
  String get tajweedGhunnahHint =>
      'إدغام بغنة، إخفاء، إقلاب، النون والميم المشددتان، إخفاء شفوي';

  @override
  String get tajweedQalqalah => 'قلقلة';

  @override
  String get tajweedQalqalahHint => 'حروف ق ط ب ج د الساكنة';

  @override
  String get tajweedMaddNatural => 'مد، حركتان';

  @override
  String get tajweedMaddNaturalHint => 'صلة صغرى، ألف خنجرية';

  @override
  String get tajweedMaddArid => 'مد، 2 أو 4 أو 6 حركات';

  @override
  String get tajweedMaddAridHint => 'مد عارض للسكون، مد لين';

  @override
  String get tajweedMaddWajib => 'مد، 4 أو 5 حركات';

  @override
  String get tajweedMaddWajibHint => 'مد واجب متصل، مد جائز منفصل، صلة كبرى';

  @override
  String get tajweedMaddLazim => 'مد، 6 حركات';

  @override
  String get tajweedMaddLazimHint => 'مد لازم';

  @override
  String get tajweedTafkhim => 'تفخيم';

  @override
  String get tajweedTafkhimHint =>
      'حروف خ ص ض غ ط ق ظ، الراء المفخمة، لام لفظ الجلالة';

  @override
  String get tajweedSilent => 'لا يُقرأ';

  @override
  String get tajweedSilentHint =>
      'همزة الوصل، اللام الشمسية، إدغام كامل بلا غنة، حروف لا تُنطق';

  @override
  String get autoNextAyah => 'تشغيل الآية التالية تلقائيًا';

  @override
  String get enterPage => 'أدخل رقم الصفحة';

  @override
  String get openPage => 'فتح';

  @override
  String get searchQuran => 'البحث في القرآن';

  @override
  String get searchQuranHint => 'كلمة في القرآن';

  @override
  String get searchQuranPrompt => 'اكتب كلمة من حرفين على الأقل';

  @override
  String get nothingFound => 'لا توجد نتائج';

  @override
  String searchFound(int count) {
    return 'عدد الآيات: $count';
  }

  @override
  String searchManyFound(int count) {
    return 'تُعرض أول $count آية. أضف كلمة لتضييق البحث.';
  }

  @override
  String get oneHourBefore => 'قبل ساعة';

  @override
  String get qiblaPoorAccuracy =>
      'يفيد الهاتف بأن البوصلة غير دقيقة. حرّك الهاتف على شكل الرقم 8 وانزع الغطاء المغناطيسي.';

  @override
  String qiblaCheck(String direction) {
    return 'للتحقق: القبلة من هنا باتجاه $direction. إذا أشار السهم إلى الجهة المعاكسة فبوصلة الهاتف غير مضبوطة.';
  }

  @override
  String get compassPoints =>
      'الشمال,الشمال الشرقي,الشرق,الجنوب الشرقي,الجنوب,الجنوب الغربي,الغرب,الشمال الغربي';

  @override
  String updateAvailable(String version) {
    return 'صدر الإصدار $version';
  }

  @override
  String get updateHint =>
      'نزّل الملف وثبّته فوق هذا الإصدار. تبقى إعداداتك كما هي.';

  @override
  String get updateDownload => 'تنزيل';

  @override
  String get updateLater => 'تخطَّ هذا الإصدار';

  @override
  String get checkUpdates => 'التحقق من التحديثات';

  @override
  String get checkUpdatesHint =>
      'عند التشغيل يسأل التطبيق GitHub عن صدور إصدار أحدث.';

  @override
  String versionLabel(String version) {
    return 'المثبَّت: $version.';
  }

  @override
  String get channelQuran => 'تلاوة القرآن';
}
