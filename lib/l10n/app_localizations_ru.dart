// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Время молитвы';

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
  String get rakaatsFajr => '2 ракаата сунны, 2 ракаата фарда';

  @override
  String get rakaatsDhuhr => '4 ракаата сунны, 4 фарда, 2 сунны';

  @override
  String get rakaatsAsr => '4 ракаата фарда';

  @override
  String get rakaatsMaghrib => '3 ракаата фарда, 2 сунны';

  @override
  String get rakaatsIsha => '4 ракаата фарда, 2 сунны, 3 витра';

  @override
  String get howToPray => 'Как совершать молитву?';

  @override
  String get howToPrayHint => 'Пошагово, по ханафитскому мазхабу';

  @override
  String get guideRakaats => 'Сколько ракаатов';

  @override
  String get guideSunnahBefore => 'Сунна до';

  @override
  String get guideFard => 'Фард';

  @override
  String get guideSunnahAfter => 'Сунна после';

  @override
  String get guideWitr => 'Витр';

  @override
  String get guideBefore => 'Перед молитвой';

  @override
  String get guideSteps => 'Молитва из двух ракаатов';

  @override
  String get guideMore => 'Что ещё нужно знать';

  @override
  String soonLabel(int minutes) {
    return 'Через $minutes мин!';
  }

  @override
  String get showTransliterationItem => 'Показать транскрипцию';

  @override
  String get repeatAyah => 'Повторение для заучивания';

  @override
  String get repeatAyahHint =>
      'Аят звучит снова и снова, пока вы не выключите повтор';

  @override
  String get recitationSpeed => 'Скорость чтения';

  @override
  String get resetSpeed => 'Сбросить до 1×';

  @override
  String get lastThirdOfNight => 'Последняя треть ночи';

  @override
  String get settings => 'Настройки';

  @override
  String get supportProject => 'Поддержать проект';

  @override
  String get supportText =>
      'Все пожертвования добровольны. Мой проект всегда будет полностью бесплатным.';

  @override
  String get tbank => 'Т-Банк';

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
  String get locationNotSet => 'Выберите город, чтобы увидеть время молитвы';

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
  String get asrMadhab => 'Время асра';

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
  String get methodGulfRegion => 'Страны Персидского залива';

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
  String get methodMoonsightingCommittee =>
      'Комитет наблюдения за луной (Moonsighting Committee)';

  @override
  String get navPrayer => 'Молитва';

  @override
  String get navQuran => 'Коран';

  @override
  String get navQibla => 'Кибла';

  @override
  String get navSalawat => 'Салават';

  @override
  String get navMore => 'Ещё';

  @override
  String atTime(String time) {
    return 'в $time';
  }

  @override
  String get hadithOfDay => 'Хадис дня';

  @override
  String bukhariRef(int number) {
    return 'Сахих аль-Бухари, № $number';
  }

  @override
  String get readMore => 'Читать полностью';

  @override
  String get previousDay => 'Предыдущий';

  @override
  String get nextDay => 'Следующий';

  @override
  String get copy => 'Скопировать';

  @override
  String get copied => 'Скопировано';

  @override
  String get adhanOn => 'Азан включён';

  @override
  String get adhanOff => 'Азан выключен';

  @override
  String get continueReading => 'Продолжить чтение';

  @override
  String surahAyah(String surah, int ayah) {
    return '$surah, аят $ayah';
  }

  @override
  String get searchSurah => 'Название или номер суры';

  @override
  String ayahCount(int count) {
    return 'Аятов: $count';
  }

  @override
  String get makkan => 'Мекканская';

  @override
  String get madinan => 'Мединская';

  @override
  String get bookmarks => 'Закладки';

  @override
  String get noBookmarks =>
      'Закладок пока нет. Нажмите значок закладки под аятом, чтобы сохранить его.';

  @override
  String get tafsir => 'Тафсир';

  @override
  String get tafsirSource => 'Аль-Мухтасар фи тафсир аль-Кур’ан';

  @override
  String get showTranslation => 'Перевод';

  @override
  String get textSize => 'Размер текста';

  @override
  String get addBookmark => 'Добавить в закладки';

  @override
  String get removeBookmark => 'Убрать из закладок';

  @override
  String qiblaDirection(String degrees) {
    return 'Кибла: $degrees° от севера';
  }

  @override
  String get qiblaAligned => 'Вы стоите лицом к кибле';

  @override
  String qiblaTurnRight(String degrees) {
    return 'Повернитесь вправо на $degrees°';
  }

  @override
  String qiblaTurnLeft(String degrees) {
    return 'Повернитесь влево на $degrees°';
  }

  @override
  String get qiblaNoSensor =>
      'На устройстве нет компаса. Используйте угол выше с любым компасом.';

  @override
  String get qiblaCalibrate =>
      'Держите телефон горизонтально, подальше от металла. Если стрелка плавает, поводите телефоном восьмёркой.';

  @override
  String get qiblaNeedsPlace => 'Выберите город, чтобы определить киблу';

  @override
  String get salawatToday => 'Сегодня';

  @override
  String salawatTotal(int count) {
    return 'За всё время: $count';
  }

  @override
  String get salawatGoal => 'Цель на день';

  @override
  String get salawatReset => 'Сбросить счёт за сегодня';

  @override
  String get salawatTap => 'Нажмите, чтобы считать';

  @override
  String ofGoal(int goal) {
    return 'из $goal';
  }

  @override
  String get notifications => 'Азан и уведомления';

  @override
  String get notificationsHint => 'Для каких молитв звучит азан';

  @override
  String get alarmsTitle => 'Будильники';

  @override
  String get alarms => 'Будильники: сухур и тахаджуд';

  @override
  String get alarmsHint => 'Привязаны к фаджру, время сдвигается каждый день';

  @override
  String get prayerSettings => 'Настройки времени молитвы';

  @override
  String get prayerSettingsHint => 'Город, метод, поправки';

  @override
  String get appearance => 'Оформление';

  @override
  String get sources => 'Источники и лицензии';

  @override
  String get permissionNotifications => 'Разрешить уведомления';

  @override
  String get permissionNotificationsHint =>
      'Без этого разрешения азан не прозвучит';

  @override
  String get permissionExact => 'Разрешить точные будильники';

  @override
  String get permissionExactHint =>
      'Иначе Android может задержать азан на несколько минут';

  @override
  String get permissionGranted => 'Разрешено';

  @override
  String get batteryHint =>
      'Если азан не звучит вовремя, отключите для MyFaith оптимизацию батареи в настройках телефона и разрешите автозапуск. Чаще всего фоновые приложения закрывают телефоны Xiaomi, Huawei и Samsung.';

  @override
  String get testAdhan => 'Включить азан сейчас';

  @override
  String get testScheduled =>
      'Азан должен зазвучать. Если тихо, проверьте громкость будильника.';

  @override
  String get reminderBefore => 'Напоминание до молитвы';

  @override
  String get off => 'Выключено';

  @override
  String minutesBefore(int count) {
    return 'За $count мин';
  }

  @override
  String get hadithNotification => 'Уведомление с хадисом дня';

  @override
  String get hadithTime => 'Время';

  @override
  String get suhoorAlarm => 'Будильник на сухур';

  @override
  String get suhoorBefore => 'Будить до фаджра';

  @override
  String get suhoorDays => 'В какие дни';

  @override
  String get suhoorRamadan => 'Рамадан';

  @override
  String get suhoorMonThu => 'Понедельники и четверги';

  @override
  String get suhoorWhite => 'Белые дни (13–15 числа лунного месяца)';

  @override
  String get suhoorDaily => 'Каждый день';

  @override
  String get suhoorStop => 'Напомнить перед фаджром, что пора заканчивать есть';

  @override
  String nextSuhoor(String when) {
    return 'Ближайший будильник: $when';
  }

  @override
  String get noUpcomingAlarm => 'В ближайшие 10 дней будильника нет';

  @override
  String get tahajjudAlarm => 'Будильник на тахаджуд';

  @override
  String get tahajjudWhen => 'Когда будить';

  @override
  String get tahajjudLastThird => 'В начале последней трети ночи';

  @override
  String get tahajjudBeforeFajr => 'За заданное время до фаджра';

  @override
  String get weekdays => 'Дни недели';

  @override
  String get hijriAdjustment => 'Поправка даты по хиджре';

  @override
  String get hijriAdjustmentHint =>
      'Если в вашей стране месяц начался в другой день';

  @override
  String daysShift(String count) {
    return '$count дн.';
  }

  @override
  String notifAdhanTitle(String prayer) {
    return 'Время молитвы: $prayer';
  }

  @override
  String get notifSunriseTitle => 'Восход солнца';

  @override
  String notifAdhanBody(String time, String city) {
    return '$time, $city';
  }

  @override
  String notifReminderTitle(String prayer, int minutes) {
    return '$prayer через $minutes мин';
  }

  @override
  String get notifSuhoorTitle => 'Время сухура';

  @override
  String notifSuhoorBody(String time) {
    return 'Фаджр в $time';
  }

  @override
  String get notifSuhoorStopTitle => 'Пора заканчивать есть';

  @override
  String get notifTahajjudTitle => 'Время тахаджуда';

  @override
  String get notifRefreshTitle => 'Откройте MyFaith';

  @override
  String get notifRefreshBody =>
      'Откройте приложение, чтобы азан продолжил звучать в следующие дни';

  @override
  String get channelAdhan => 'Азан';

  @override
  String get channelReminder => 'Напоминания';

  @override
  String get channelAlarm => 'Будильники';

  @override
  String get channelHadith => 'Хадис дня';

  @override
  String get sourcesQuran =>
      'Текст Корана: Комплекс имени короля Фахда, усманское письмо, чтение Хафса. Переводы: Эльмир Кулиев (русский), Saheeh International (английский). Тафсир: «Аль-Мухтасар», Центр коранических исследований «Тафсир».';

  @override
  String get sourcesHadith =>
      'Хадисы: Сахих аль-Бухари. Английский перевод Мухсина Хана, русский Абдуллы Нирши. Хадис дня выбирается автоматически из коротких хадисов.';

  @override
  String get sourcesOther =>
      'Время молитвы: adhan_dart. Города: GeoNames, CC BY 4.0. Арабский шрифт: Amiri Quran, SIL Open Font License. Данные собраны из открытых проектов quran-api, hadith-api и tafsir_api. Переводы принадлежат их авторам и используются здесь для личного некоммерческого чтения. Транскрипция: quran-api (латиница), кириллица получена из неё автоматически и служит только подсказкой для чтения. Цвета таджвида приложение выводит из знаков усманского письма, они не заменяют обучение с учителем. Записи чтецов загружаются с everyayah.com, для них нужен интернет. У зикров и дуа источник указан на каждой карточке.';

  @override
  String get sourcesAdhan =>
      'Азан: записи из Дохи (Катар), сделанные в 2013–2014 годах (Internet Archive, общественное достояние), а также азаны шейха Тауфика Ходжа, шейха Турки аль-Хасани и шейха Абдуллы ибн Ахмада ибн Абдуррахмана Ба-Афифа.';

  @override
  String get muezzin => 'Муэдзин';

  @override
  String get channelAdhanFajr => 'Азан на фаджр';

  @override
  String get testAdhanFajr => 'Включить азан фаджра';

  @override
  String syncPending(int count) {
    return 'Запланировано уведомлений: $count';
  }

  @override
  String syncError(String error) {
    return 'Не удалось запланировать: $error';
  }

  @override
  String get stopAdhan => 'Остановить';

  @override
  String get widgetOpenHint => 'Откройте MyFaith';

  @override
  String get navDhikr => 'Зикры';

  @override
  String get dhikrTab => 'Зикры';

  @override
  String get duaTab => 'Дуа';

  @override
  String get dhikrToday => 'Сегодня';

  @override
  String dhikrDone(int done, int total) {
    return 'Выполнено $done из $total';
  }

  @override
  String get dhikrGoal => 'Цель на день';

  @override
  String dhikrGoalDefault(int count) {
    return '$count (рекомендуется)';
  }

  @override
  String get dhikrGoalReached => 'Цель на сегодня выполнена';

  @override
  String get names99 => '99 имён Аллаха';

  @override
  String get names99Hint => 'Викторина и полный список';

  @override
  String get namesQuiz => 'Викторина';

  @override
  String get namesList => 'Список';

  @override
  String get namesQuestion => 'Что означает это имя?';

  @override
  String get namesNext => 'Дальше';

  @override
  String namesStreak(int current, int best) {
    return 'Подряд: $current · рекорд: $best';
  }

  @override
  String get surahs => 'Суры';

  @override
  String get mushaf => 'Мусхаф';

  @override
  String get byJuz => 'Джузы';

  @override
  String get byPage => 'Страницы';

  @override
  String pageNumber(int page) {
    return 'Страница $page';
  }

  @override
  String juzNumber(int juz) {
    return 'Джуз $juz';
  }

  @override
  String pageOf(int page, int total) {
    return 'Страница $page из $total';
  }

  @override
  String juzOf(int juz, int total) {
    return 'Джуз $juz из $total';
  }

  @override
  String ayahNumber(int ayah) {
    return 'Аят $ayah';
  }

  @override
  String surahNumberName(int number, String name) {
    return 'Сура $number. $name';
  }

  @override
  String get listen => 'Слушать';

  @override
  String get pause => 'Пауза';

  @override
  String get previousAyah => 'Предыдущий аят';

  @override
  String get nextAyah => 'Следующий аят';

  @override
  String get closePlayer => 'Закрыть плеер';

  @override
  String get audioFailed => 'Не удалось загрузить запись. Проверьте интернет.';

  @override
  String get reciter => 'Чтец';

  @override
  String get hideTafsir => 'Скрыть тафсир';

  @override
  String get readerOptions => 'Настройки чтения';

  @override
  String get showTransliteration => 'Транскрипция';

  @override
  String get showTajweed => 'Подсказки таджвида';

  @override
  String get tajweedGhunnah => 'Гунна, ихфа, идгам';

  @override
  String get tajweedGhunnahHint =>
      'Идгам с гунной, ихфа, икляб, нун и мим с шаддой, ихфа шафавий';

  @override
  String get tajweedQalqalah => 'Калькаля';

  @override
  String get tajweedQalqalahHint =>
      'Отрывистый отзвук букв ق ط ب ج د с сукуном';

  @override
  String get tajweedMaddNatural => 'Мадд, 2 счёта';

  @override
  String get tajweedMaddNaturalHint => 'Мадд сыля сугра, алиф ханджария';

  @override
  String get tajweedMaddArid => 'Мадд, 2, 4 или 6 счётов';

  @override
  String get tajweedMaddAridHint => 'Мадд ‘арид ли-с-сукун, мадд лин';

  @override
  String get tajweedMaddWajib => 'Мадд, 4 или 5 счётов';

  @override
  String get tajweedMaddWajibHint =>
      'Мадд ваджиб муттасыль, мадд джаиз мунфасыль, мадд сыля кубра';

  @override
  String get tajweedMaddLazim => 'Мадд, 6 счётов';

  @override
  String get tajweedMaddLazimHint => 'Мадд лязим';

  @override
  String get tajweedTafkhim => 'Тафхим';

  @override
  String get tajweedTafkhimHint =>
      'Твёрдое произношение: буквы خ ص ض غ ط ق ظ, твёрдая ра, лям в слове «Аллах»';

  @override
  String get tajweedSilent => 'Не читается';

  @override
  String get tajweedSilentHint =>
      'Хамза васль, лям шамсия, полный идгам без гунны, непроизносимые буквы';

  @override
  String get autoNextAyah => 'Автопроигрывание следующего аята';

  @override
  String get enterPage => 'Введите номер страницы';

  @override
  String get openPage => 'Открыть';

  @override
  String get searchQuran => 'Поиск по Корану';

  @override
  String get searchQuranHint => 'Слово в переводе или на арабском';

  @override
  String get searchQuranPrompt => 'Введите слово хотя бы из двух букв';

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String searchFound(int count) {
    return 'Найдено аятов: $count';
  }

  @override
  String searchManyFound(int count) {
    return 'Показаны первые $count аятов. Уточните запрос.';
  }

  @override
  String get oneHourBefore => 'За 1 час';

  @override
  String get qiblaPoorAccuracy =>
      'Телефон сообщает, что его компас неточен. Поводите телефоном восьмёркой и снимите чехол с магнитом.';

  @override
  String qiblaCheck(String direction) {
    return 'Проверьте себя: отсюда кибла находится на $direction. Если стрелка смотрит в противоположную сторону, компас телефона сбит.';
  }

  @override
  String get compassPoints =>
      'севере,северо-востоке,востоке,юго-востоке,юге,юго-западе,западе,северо-западе';

  @override
  String updateAvailable(String version) {
    return 'Вышла версия $version';
  }

  @override
  String get updateHint =>
      'Скачайте файл и установите его поверх этой версии. Настройки сохранятся.';

  @override
  String get updateDownload => 'Скачать';

  @override
  String get updateLater => 'Пропустить';

  @override
  String get checkUpdates => 'Проверять обновления';

  @override
  String get checkUpdatesHint =>
      'При запуске приложение спрашивает у GitHub, не вышла ли новая версия.';

  @override
  String versionLabel(String version) {
    return 'Установлена $version.';
  }

  @override
  String get channelQuran => 'Чтение Корана';

  @override
  String get offlineListening => 'Слушать без интернета';

  @override
  String get offlineListeningHint => 'Скачать суры на телефон';

  @override
  String offlineHint(String reciter) {
    return 'Скачанные суры звучат без интернета. Они сохраняются для выбранного чтеца: $reciter.';
  }

  @override
  String offlineProgress(int done, int total) {
    return '$done из $total аятов';
  }

  @override
  String get offlineFailed =>
      'Загрузка прервалась. Проверьте интернет и попробуйте ещё раз.';

  @override
  String get offlineSaved => 'На телефоне';

  @override
  String get offlineDelete => 'Удалить с телефона';

  @override
  String get offlineDownload => 'Скачать';

  @override
  String get backup => 'Резервная копия';

  @override
  String get backupSave => 'Сохранить в файл';

  @override
  String get backupSaveHint => 'Настройки, город, закладки, счётчики и цели';

  @override
  String get backupRestore => 'Восстановить из файла';

  @override
  String get backupRestoreHint => 'Выберите файл, сохранённый раньше';

  @override
  String get backupSaved => 'Копия сохранена';

  @override
  String get backupNotOurs => 'Это не файл резервной копии MyFaith';

  @override
  String get backupRestoreConfirm =>
      'Текущие настройки, закладки и счётчики будут заменены теми, что в файле.';

  @override
  String get backupRestoreAction => 'Восстановить';

  @override
  String get backupRestored => 'Восстановлено из файла';

  @override
  String get guideAdhan => 'Азан и икама';
}
