/// One of the 99 names of Allah.
class DivineName {
  const DivineName(
    this.number,
    this.arabic,
    this.latin,
    this.cyrillic,
    this.english,
    this.russian,
  );

  final int number;
  final String arabic;
  final String latin;
  final String cyrillic;
  final String english;
  final String russian;

  /// Transliteration for the interface language.
  String transliteration(String languageCode) =>
      languageCode == 'ru' ? cyrillic : latin;

  /// Meaning in the interface language. Arabic falls back to English.
  String meaning(String languageCode) =>
      languageCode == 'ru' ? russian : english;
}

/// The list narrated by at-Tirmidhi (3507), in its order. The hadith that
/// there are ninety-nine names is in al-Bukhari (2736) and Muslim (2677);
/// the enumeration itself is the well-known one, though scholars differ on
/// whether it is part of the hadith.
const _rows = '''
الرَّحْمَٰنُ|Ar-Rahman|Ар-Рахман|The Most Merciful|Милостивый
الرَّحِيمُ|Ar-Rahim|Ар-Рахим|The Especially Merciful|Милосердный
الْمَلِكُ|Al-Malik|Аль-Малик|The King|Царь
الْقُدُّوسُ|Al-Quddus|Аль-Куддус|The Most Holy|Святой
السَّلَامُ|As-Salam|Ас-Салям|The Source of Peace|Дарующий мир
الْمُؤْمِنُ|Al-Mu'min|Аль-Мумин|The Giver of Security|Дарующий безопасность
الْمُهَيْمِنُ|Al-Muhaymin|Аль-Мухаймин|The Guardian|Хранитель
الْعَزِيزُ|Al-Aziz|Аль-Азиз|The Almighty|Могущественный
الْجَبَّارُ|Al-Jabbar|Аль-Джаббар|The Compeller|Могучий
الْمُتَكَبِّرُ|Al-Mutakabbir|Аль-Мутакаббир|The Supreme|Превосходящий
الْخَالِقُ|Al-Khaliq|Аль-Халик|The Creator|Творец
الْبَارِئُ|Al-Bari|Аль-Бари|The Originator|Создатель
الْمُصَوِّرُ|Al-Musawwir|Аль-Мусаввир|The Fashioner|Дарующий облик
الْغَفَّارُ|Al-Ghaffar|Аль-Гаффар|The Ever-Forgiving|Всепрощающий
الْقَهَّارُ|Al-Qahhar|Аль-Каххар|The Subduer|Всепобеждающий
الْوَهَّابُ|Al-Wahhab|Аль-Ваххаб|The Bestower|Дарующий
الرَّزَّاقُ|Ar-Razzaq|Ар-Раззак|The Provider|Наделяющий уделом
الْفَتَّاحُ|Al-Fattah|Аль-Фаттах|The Opener|Раскрывающий
الْعَلِيمُ|Al-Alim|Аль-Алим|The All-Knowing|Всезнающий
الْقَابِضُ|Al-Qabid|Аль-Кабид|The Withholder|Удерживающий
الْبَاسِطُ|Al-Basit|Аль-Басит|The Extender|Щедро дарующий
الْخَافِضُ|Al-Khafid|Аль-Хафид|The Abaser|Принижающий
الرَّافِعُ|Ar-Rafi|Ар-Рафи|The Exalter|Возвышающий
الْمُعِزُّ|Al-Mu'izz|Аль-Муизз|The Giver of Honour|Дарующий величие
الْمُذِلُّ|Al-Mudhill|Аль-Музилль|The Giver of Dishonour|Унижающий
السَّمِيعُ|As-Sami|Ас-Сами|The All-Hearing|Всеслышащий
الْبَصِيرُ|Al-Basir|Аль-Басыр|The All-Seeing|Всевидящий
الْحَكَمُ|Al-Hakam|Аль-Хакам|The Judge|Судья
الْعَدْلُ|Al-Adl|Аль-Адль|The Just|Справедливый
اللَّطِيفُ|Al-Latif|Аль-Латыф|The Subtle and Kind|Добрый, Проницательный
الْخَبِيرُ|Al-Khabir|Аль-Хабир|The All-Aware|Ведающий
الْحَلِيمُ|Al-Halim|Аль-Халим|The Forbearing|Выдержанный
الْعَظِيمُ|Al-Azim|Аль-Азым|The Magnificent|Великий
الْغَفُورُ|Al-Ghafur|Аль-Гафур|The Forgiving|Прощающий
الشَّكُورُ|Ash-Shakur|Аш-Шакур|The Appreciative|Благодарный
الْعَلِيُّ|Al-Ali|Аль-Али|The Most High|Возвышенный
الْكَبِيرُ|Al-Kabir|Аль-Кабир|The Most Great|Большой
الْحَفِيظُ|Al-Hafiz|Аль-Хафиз|The Preserver|Оберегающий
الْمُقِيتُ|Al-Muqit|Аль-Мукыт|The Sustainer|Дарующий пропитание
الْحَسِيبُ|Al-Hasib|Аль-Хасиб|The Reckoner|Ведущий счёт
الْجَلِيلُ|Al-Jalil|Аль-Джалиль|The Majestic|Величественный
الْكَرِيمُ|Al-Karim|Аль-Карим|The Generous|Щедрый
الرَّقِيبُ|Ar-Raqib|Ар-Ракыб|The Watchful|Наблюдающий
الْمُجِيبُ|Al-Mujib|Аль-Муджиб|The Responsive|Отвечающий на мольбы
الْوَاسِعُ|Al-Wasi|Аль-Васи|The All-Encompassing|Объемлющий
الْحَكِيمُ|Al-Hakim|Аль-Хаким|The All-Wise|Мудрый
الْوَدُودُ|Al-Wadud|Аль-Вадуд|The Most Loving|Любящий
الْمَجِيدُ|Al-Majid|Аль-Маджид|The Glorious|Славный
الْبَاعِثُ|Al-Ba'ith|Аль-Баис|The Resurrector|Воскрешающий
الشَّهِيدُ|Ash-Shahid|Аш-Шахид|The Witness|Свидетель
الْحَقُّ|Al-Haqq|Аль-Хакк|The Truth|Истинный
الْوَكِيلُ|Al-Wakil|Аль-Вакиль|The Trustee|Попечитель
الْقَوِيُّ|Al-Qawi|Аль-Кави|The All-Strong|Всесильный
الْمَتِينُ|Al-Matin|Аль-Матин|The Firm|Крепкий
الْوَلِيُّ|Al-Wali|Аль-Вали|The Protecting Friend|Покровитель
الْحَمِيدُ|Al-Hamid|Аль-Хамид|The Praiseworthy|Достойный хвалы
الْمُحْصِي|Al-Muhsi|Аль-Мухсы|The One Who Counts All|Исчисляющий
الْمُبْدِئُ|Al-Mubdi|Аль-Мубди|The Beginner of Creation|Начинающий творение
الْمُعِيدُ|Al-Mu'id|Аль-Муид|The Restorer|Возвращающий
الْمُحْيِي|Al-Muhyi|Аль-Мухйи|The Giver of Life|Оживляющий
الْمُمِيتُ|Al-Mumit|Аль-Мумит|The Bringer of Death|Умерщвляющий
الْحَيُّ|Al-Hayy|Аль-Хайй|The Ever-Living|Живой
الْقَيُّومُ|Al-Qayyum|Аль-Каййум|The Self-Sustaining|Вседержитель
الْوَاجِدُ|Al-Wajid|Аль-Ваджид|The Finder|Находящий
الْمَاجِدُ|Al-Majid|Аль-Маджид|The Noble|Благородный
الْوَاحِدُ|Al-Wahid|Аль-Вахид|The One|Единый
الْأَحَدُ|Al-Ahad|Аль-Ахад|The Unique|Единственный
الصَّمَدُ|As-Samad|Ас-Самад|The Eternal Refuge|Самодостаточный
الْقَادِرُ|Al-Qadir|Аль-Кадир|The Able|Могущий
الْمُقْتَدِرُ|Al-Muqtadir|Аль-Муктадир|The All-Powerful|Всемогущий
الْمُقَدِّمُ|Al-Muqaddim|Аль-Мукаддим|The One Who Brings Forward|Выдвигающий вперёд
الْمُؤَخِّرُ|Al-Mu'akhkhir|Аль-Муаххир|The One Who Puts Back|Отодвигающий назад
الْأَوَّلُ|Al-Awwal|Аль-Авваль|The First|Первый
الْآخِرُ|Al-Akhir|Аль-Ахир|The Last|Последний
الظَّاهِرُ|Az-Zahir|Аз-Захир|The Manifest|Явный
الْبَاطِنُ|Al-Batin|Аль-Батын|The Hidden|Сокровенный
الْوَالِي|Al-Wali|Аль-Вали|The Governor|Правящий
الْمُتَعَالِي|Al-Muta'ali|Аль-Мутаали|The Most Exalted|Превознесённый
الْبَرُّ|Al-Barr|Аль-Барр|The Source of Goodness|Добродетельный
التَّوَّابُ|At-Tawwab|Ат-Тавваб|The Acceptor of Repentance|Принимающий покаяние
الْمُنْتَقِمُ|Al-Muntaqim|Аль-Мунтаким|The Avenger|Воздающий
الْعَفُوُّ|Al-Afuw|Аль-Афув|The Pardoner|Снисходительный
الرَّءُوفُ|Ar-Ra'uf|Ар-Рауф|The Most Kind|Сострадательный
مَالِكُ الْمُلْكِ|Malik al-Mulk|Малик аль-Мульк|Owner of the Dominion|Владыка царства
ذُو الْجَلَالِ وَالْإِكْرَامِ|Dhul-Jalali wal-Ikram|Зуль-Джаляли валь-Икрам|Lord of Majesty and Honour|Обладатель величия и почёта
الْمُقْسِطُ|Al-Muqsit|Аль-Муксит|The Equitable|Беспристрастный
الْجَامِعُ|Al-Jami|Аль-Джами|The Gatherer|Собирающий
الْغَنِيُّ|Al-Ghani|Аль-Гани|The Self-Sufficient|Богатый
الْمُغْنِي|Al-Mughni|Аль-Мугни|The Enricher|Обогащающий
الْمَانِعُ|Al-Mani|Аль-Мани|The Preventer|Ограждающий
الضَّارُّ|Ad-Darr|Ад-Дарр|The One Who Sends Harm|Посылающий вред
النَّافِعُ|An-Nafi|Ан-Нафи|The One Who Sends Benefit|Приносящий пользу
النُّورُ|An-Nur|Ан-Нур|The Light|Свет
الْهَادِي|Al-Hadi|Аль-Хади|The Guide|Ведущий прямым путём
الْبَدِيعُ|Al-Badi|Аль-Бади|The Incomparable Originator|Первосоздатель
الْبَاقِي|Al-Baqi|Аль-Баки|The Everlasting|Вечный
الْوَارِثُ|Al-Warith|Аль-Варис|The Inheritor|Наследник
الرَّشِيدُ|Ar-Rashid|Ар-Рашид|The Guide to the Right Path|Направляющий
الصَّبُورُ|As-Sabur|Ас-Сабур|The Most Patient|Терпеливый
''';

final List<DivineName> divineNames = () {
  final out = <DivineName>[];
  for (final line in _rows.trim().split('\n')) {
    final p = line.split('|');
    out.add(DivineName(out.length + 1, p[0], p[1], p[2], p[3], p[4]));
  }
  return out;
}();

/// A quiz question: one name and three meanings, exactly one of them right.
class NameQuestion {
  const NameQuestion(this.name, this.options);

  final DivineName name;
  final List<DivineName> options;
}

/// Builds a question for the name at [index]. [pick] returns a number below
/// its argument; pass a seeded generator in tests. The wrong options never
/// share their meaning with the right one.
NameQuestion nameQuestion(
  int index,
  int Function(int) pick,
  String languageCode,
) {
  final name = divineNames[index];
  final options = <DivineName>[name];
  final used = {name.meaning(languageCode)};
  while (options.length < 3) {
    final other = divineNames[pick(divineNames.length)];
    if (used.add(other.meaning(languageCode))) options.add(other);
  }
  // Shuffle so that the right answer is not always first.
  for (var i = options.length - 1; i > 0; i--) {
    final j = pick(i + 1);
    final t = options[i];
    options[i] = options[j];
    options[j] = t;
  }
  return NameQuestion(name, options);
}
