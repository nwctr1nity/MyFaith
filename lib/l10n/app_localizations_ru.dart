// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Время намаза';

  @override
  String get prayerFajr => 'Фаджр';

  @override
  String get prayerSunrise => 'Восход';

  @override
  String get prayerDhuhr => 'Зухр';

  @override
  String get prayerAsr => 'Аср';

  @override
  String get prayerMaghrib => 'Магриб';

  @override
  String get prayerIsha => 'Иша';

  @override
  String nextPrayerIn(String prayer) {
    return '$prayer через';
  }

  @override
  String get nowLabel => 'Сейчас';

  @override
  String get lastThirdOfNight => 'Последняя треть ночи';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Язык устройства';

  @override
  String get location => 'Место';

  @override
  String get chooseCity => 'Выбрать город';

  @override
  String get useMyLocation => 'Определить по геолокации';

  @override
  String get searchCity => 'Название города';

  @override
  String get searchCityHint => 'Введите хотя бы две буквы';

  @override
  String get noCitiesFound => 'Города не найдены';

  @override
  String get locationNotSet => 'Выберите город, чтобы увидеть время намаза';

  @override
  String get locationDenied =>
      'Нет разрешения на геолокацию. Выберите город вручную.';

  @override
  String get locationDisabled =>
      'Геолокация на устройстве выключена. Включите её или выберите город вручную.';

  @override
  String get locationFailed =>
      'Не удалось определить место. Выберите город вручную.';

  @override
  String get myLocation => 'Моё местоположение';

  @override
  String get calculation => 'Расчёт';

  @override
  String get method => 'Метод';

  @override
  String methodAngles(String fajr, String isha) {
    return 'Фаджр $fajr°, иша $isha°';
  }

  @override
  String methodAnglesInterval(String fajr, int minutes) {
    return 'Фаджр $fajr°, иша через $minutes мин после магриба';
  }

  @override
  String get asrMadhab => 'Время аср';

  @override
  String get madhabShafi => 'Шафиитский, маликитский, ханбалитский';

  @override
  String get madhabHanafi => 'Ханафитский (позже)';

  @override
  String get adjustments => 'Поправки в минутах';

  @override
  String get adjustmentsHint =>
      'Сдвиньте время, чтобы оно совпало с расписанием вашей мечети';

  @override
  String minutesShort(String count) {
    return '$count мин';
  }

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Как на устройстве';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get methodMuslimWorldLeague => 'Всемирная исламская лига';

  @override
  String get methodRussia => 'Россия';

  @override
  String get methodTurkiye => 'Турция (Диянет)';

  @override
  String get methodUmmAlQura => 'Умм аль-Кура, Мекка';

  @override
  String get methodEgyptian => 'Египет';

  @override
  String get methodKarachi => 'Карачи';

  @override
  String get methodNorthAmerica => 'Северная Америка (ISNA)';

  @override
  String get methodDubai => 'Дубай';

  @override
  String get methodQatar => 'Катар';

  @override
  String get methodKuwait => 'Кувейт';

  @override
  String get methodGulfRegion => 'Страны Залива';

  @override
  String get methodSingapore => 'Сингапур, Малайзия';

  @override
  String get methodIndonesian => 'Индонезия';

  @override
  String get methodTehran => 'Тегеран';

  @override
  String get methodJafari => 'Джафаритский';

  @override
  String get methodFrance => 'Франция';

  @override
  String get methodJordan => 'Иордания';

  @override
  String get methodMorocco => 'Марокко';

  @override
  String get methodAlgerian => 'Алжир';

  @override
  String get methodTunisia => 'Тунис';

  @override
  String get methodPortugal => 'Португалия';

  @override
  String get methodMoonsightingCommittee => 'Moonsighting Committee';
}
