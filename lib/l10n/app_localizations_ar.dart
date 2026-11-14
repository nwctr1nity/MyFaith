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
  String get lastThirdOfNight => 'الثلث الأخير من الليل';

  @override
  String get settings => 'الإعدادات';

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
}
