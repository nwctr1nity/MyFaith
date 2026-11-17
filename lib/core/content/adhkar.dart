import 'adhkar_quran.dart';
import 'dhikr.dart';

/// The remembrances of the morning (after Fajr) and of the evening (after
/// Asr). A short set from the sound hadiths; each entry names its source.
/// The counters are kept apart from the other lists and from each other.

Dhikr _shared(String id) => dhikrList.firstWhere((d) => d.id == id);

Dhikr _kursi(String prefix, String whenEn, String whenRu) => Dhikr(
  id: '${prefix}_kursi',
  dua: true,
  arabic: ayatAlKursiArabic,
  latin: ayatAlKursiLatin,
  cyrillic: ayatAlKursiCyrillic,
  english: ayatAlKursiEnglish,
  russian: ayatAlKursiRussian,
  goal: 1,
  source: 'Quran 2:255, al-Hakim 1/562',
  noteEn: 'Ayat al-Kursi. Once in the $whenEn.',
  noteRu: 'Аят аль-Курси. Один раз $whenRu.',
);

Dhikr _quls(String prefix, String whenEn, String whenRu) => Dhikr(
  id: '${prefix}_quls',
  dua: true,
  arabic: threeQulsArabic,
  latin: threeQulsLatin,
  cyrillic: threeQulsCyrillic,
  english: threeQulsEnglish,
  russian: threeQulsRussian,
  goal: 3,
  source: 'Quran 112–114, Abu Dawud 5082, at-Tirmidhi 3575',
  noteEn:
      'Surahs al-Ikhlas, al-Falaq and an-Nas. Three times in the $whenEn.',
  noteRu: 'Суры «аль-Ихлас», «аль-Фаляк» и «ан-Нас». Три раза $whenRu.',
);

const _commonTail =
    'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ '
    'وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ';

const _refuge =
    'رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ '
    'فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ';

const _asbahna = Dhikr(
  id: 'm_asbahna',
  dua: true,
  arabic:
      'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، $_commonTail، '
      'رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَٰذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ، وَأَعُوذُ بِكَ '
      'مِنْ شَرِّ مَا فِي هَٰذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ، $_refuge',
  latin:
      'Asbahna wa asbahal-mulku lillah, wal-hamdu lillah, la ilaha '
      'illallahu wahdahu la sharika lah, lahul-mulku wa lahul-hamdu wa '
      'huwa ala kulli shay\'in qadir. Rabbi as\'aluka khayra ma fi '
      'hadhal-yawmi wa khayra ma ba\'dah, wa a\'udhu bika min sharri ma fi '
      'hadhal-yawmi wa sharri ma ba\'dah. Rabbi a\'udhu bika minal-kasali '
      'wa su\'il-kibar. Rabbi a\'udhu bika min adhabin fin-nari wa adhabin '
      'fil-qabr',
  cyrillic:
      'Асбахна ва асбахаль-мульку лиллях, валь-хамду лиллях, ля иляха '
      'илляллаху вахдаху ля шарикя лях, ляхуль-мульку ва ляхуль-хамду ва '
      'хува аля кулли шай’ин кадир. Рабби ас’алюка хайра ма фи '
      'хазаль-йауми ва хайра ма ба‘дах, ва а‘узу бика мин шарри ма фи '
      'хазаль-йауми ва шарри ма ба‘дах. Рабби а‘узу бика миналь-касали '
      'ва су’иль-кибар. Рабби а‘узу бика мин азабин фин-нари ва азабин '
      'филь-кабр',
  english:
      'We have reached the morning, and at this hour the dominion belongs '
      'to Allah. Praise be to Allah. There is no god but Allah alone, with '
      'no partner; His is the dominion and His is the praise, and He has '
      'power over all things. My Lord, I ask You for the good of this day '
      'and the good of what follows it, and I seek refuge in You from the '
      'evil of this day and the evil of what follows it. My Lord, I seek '
      'refuge in You from laziness and the misery of old age. My Lord, I '
      'seek refuge in You from punishment in the Fire and punishment in '
      'the grave.',
  russian:
      'Мы встретили утро, и в этот час власть принадлежит Аллаху. Хвала '
      'Аллаху. Нет божества, кроме одного лишь Аллаха, у Которого нет '
      'сотоварища. Ему принадлежит власть, Ему хвала, и Он всё может. '
      'Господи, прошу у Тебя блага этого дня и блага того, что будет '
      'после него, и прибегаю к Твоей защите от зла этого дня и зла '
      'того, что будет после него. Господи, прибегаю к Твоей защите от '
      'лени и тягот старости. Господи, прибегаю к Твоей защите от '
      'мучений в Огне и мучений в могиле.',
  goal: 1,
  source: 'Muslim 2723',
  noteEn: 'Once in the morning.',
  noteRu: 'Один раз утром.',
);

const _amsayna = Dhikr(
  id: 'e_amsayna',
  dua: true,
  arabic:
      'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، $_commonTail، '
      'رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَٰذِهِ اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهَا، وَأَعُوذُ بِكَ '
      'مِنْ شَرِّ مَا فِي هَٰذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا، $_refuge',
  latin:
      'Amsayna wa amsal-mulku lillah, wal-hamdu lillah, la ilaha '
      'illallahu wahdahu la sharika lah, lahul-mulku wa lahul-hamdu wa '
      'huwa ala kulli shay\'in qadir. Rabbi as\'aluka khayra ma fi '
      'hadhihil-laylati wa khayra ma ba\'daha, wa a\'udhu bika min sharri '
      'ma fi hadhihil-laylati wa sharri ma ba\'daha. Rabbi a\'udhu bika '
      'minal-kasali wa su\'il-kibar. Rabbi a\'udhu bika min adhabin '
      'fin-nari wa adhabin fil-qabr',
  cyrillic:
      'Амсайна ва амсаль-мульку лиллях, валь-хамду лиллях, ля иляха '
      'илляллаху вахдаху ля шарикя лях, ляхуль-мульку ва ляхуль-хамду ва '
      'хува аля кулли шай’ин кадир. Рабби ас’алюка хайра ма фи '
      'хазихиль-ляйляти ва хайра ма ба‘даха, ва а‘узу бика мин шарри ма '
      'фи хазихиль-ляйляти ва шарри ма ба‘даха. Рабби а‘узу бика '
      'миналь-касали ва су’иль-кибар. Рабби а‘узу бика мин азабин '
      'фин-нари ва азабин филь-кабр',
  english:
      'We have reached the evening, and at this hour the dominion belongs '
      'to Allah. Praise be to Allah. There is no god but Allah alone, with '
      'no partner; His is the dominion and His is the praise, and He has '
      'power over all things. My Lord, I ask You for the good of this '
      'night and the good of what follows it, and I seek refuge in You '
      'from the evil of this night and the evil of what follows it. My '
      'Lord, I seek refuge in You from laziness and the misery of old age. '
      'My Lord, I seek refuge in You from punishment in the Fire and '
      'punishment in the grave.',
  russian:
      'Мы встретили вечер, и в этот час власть принадлежит Аллаху. Хвала '
      'Аллаху. Нет божества, кроме одного лишь Аллаха, у Которого нет '
      'сотоварища. Ему принадлежит власть, Ему хвала, и Он всё может. '
      'Господи, прошу у Тебя блага этой ночи и блага того, что будет '
      'после неё, и прибегаю к Твоей защите от зла этой ночи и зла '
      'того, что будет после неё. Господи, прибегаю к Твоей защите от '
      'лени и тягот старости. Господи, прибегаю к Твоей защите от '
      'мучений в Огне и мучений в могиле.',
  goal: 1,
  source: 'Muslim 2723',
  noteEn: 'Once in the evening.',
  noteRu: 'Один раз вечером.',
);

const _bikaMorning = Dhikr(
  id: 'm_bika',
  dua: true,
  arabic:
      'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، '
      'وَإِلَيْكَ النُّشُورُ',
  latin:
      'Allahumma bika asbahna, wa bika amsayna, wa bika nahya, wa bika '
      'namutu, wa ilaykan-nushur',
  cyrillic:
      'Аллахумма бика асбахна, ва бика амсайна, ва бика нахья, ва бика '
      'намуту, ва иляйкян-нушур',
  english:
      'O Allah, by You we reach the morning and by You we reach the '
      'evening, by You we live and by You we die, and to You is the '
      'resurrection.',
  russian:
      'О Аллах, благодаря Тебе мы встретили утро и благодаря Тебе '
      'встречаем вечер, благодаря Тебе мы живём и благодаря Тебе '
      'умираем, и к Тебе воскресение.',
  goal: 1,
  source: 'at-Tirmidhi 3391',
  noteEn: 'Once in the morning.',
  noteRu: 'Один раз утром.',
);

const _bikaEvening = Dhikr(
  id: 'e_bika',
  dua: true,
  arabic:
      'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، '
      'وَإِلَيْكَ الْمَصِيرُ',
  latin:
      'Allahumma bika amsayna, wa bika asbahna, wa bika nahya, wa bika '
      'namutu, wa ilaykal-masir',
  cyrillic:
      'Аллахумма бика амсайна, ва бика асбахна, ва бика нахья, ва бика '
      'намуту, ва иляйкяль-масыр',
  english:
      'O Allah, by You we reach the evening and by You we reach the '
      'morning, by You we live and by You we die, and to You is the '
      'return.',
  russian:
      'О Аллах, благодаря Тебе мы встретили вечер и благодаря Тебе '
      'встречаем утро, благодаря Тебе мы живём и благодаря Тебе '
      'умираем, и к Тебе возвращение.',
  goal: 1,
  source: 'at-Tirmidhi 3391',
  noteEn: 'Once in the evening.',
  noteRu: 'Один раз вечером.',
);

Dhikr _raditu(String prefix, String whenEn, String whenRu) => Dhikr(
  id: '${prefix}_raditu',
  dua: true,
  arabic:
      'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ '
      'وَسَلَّمَ نَبِيًّا',
  latin:
      'Raditu billahi rabba, wa bil-islami dina, wa bi Muhammadin '
      'sallallahu alayhi wa sallama nabiyya',
  cyrillic:
      'Радыту билляхи раббан, ва биль-ислями динан, ва би Мухаммадин '
      'салляллаху алейхи ва саллям набийян',
  english:
      'I am pleased with Allah as my Lord, with Islam as my religion and '
      'with Muhammad, peace and blessings be upon him, as my Prophet.',
  russian:
      'Я доволен Аллахом как Господом, исламом как религией и '
      'Мухаммадом, да благословит его Аллах и приветствует, как '
      'пророком.',
  goal: 3,
  source: 'Abu Dawud 5072, at-Tirmidhi 3389',
  noteEn: 'Three times in the $whenEn.',
  noteRu: 'Три раза $whenRu.',
);

const _kalimat = Dhikr(
  id: 'e_kalimat',
  dua: true,
  arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
  latin: 'A\'udhu bikalimatillahit-tammati min sharri ma khalaq',
  cyrillic: 'А‘узу бикалиматилляхит-таммати мин шарри ма халяк',
  english:
      'I seek refuge in the perfect words of Allah from the evil of what '
      'He has created.',
  russian:
      'Прибегаю к защите совершенных слов Аллаха от зла того, что Он '
      'сотворил.',
  goal: 1,
  source: 'Muslim 2709',
  noteEn: 'In the evening, for protection during the night.',
  noteRu: 'Вечером, для защиты ночью.',
);

final morningAdhkar = <Dhikr>[
  _kursi('m', 'morning', 'утром'),
  _quls('m', 'morning', 'утром'),
  _shared('sayyid_istighfar').inList(
    id: 'm_sayyid',
    goal: 1,
    noteEn: 'The best way of asking forgiveness. Once in the morning.',
    noteRu: 'Лучшая мольба о прощении. Один раз утром.',
  ),
  _asbahna,
  _bikaMorning,
  _shared('bismillah_protection').inList(
    id: 'm_bismillah',
    goal: 3,
    noteEn: 'Three times in the morning.',
    noteRu: 'Три раза утром.',
  ),
  _raditu('m', 'morning', 'утром'),
  _shared('ilm_nafi').inList(
    id: 'm_ilm',
    goal: 1,
    noteEn: 'Once after the Fajr prayer.',
    noteRu: 'Один раз после утренней молитвы.',
  ),
  _shared('subhanallahi_wa_bihamdih').inList(
    id: 'm_subhan',
    goal: 100,
    source: 'Muslim 2692',
    noteEn: '100 times in the morning.',
    noteRu: '100 раз утром.',
  ),
];

final eveningAdhkar = <Dhikr>[
  _kursi('e', 'evening', 'вечером'),
  _quls('e', 'evening', 'вечером'),
  _shared('sayyid_istighfar').inList(
    id: 'e_sayyid',
    goal: 1,
    noteEn: 'The best way of asking forgiveness. Once in the evening.',
    noteRu: 'Лучшая мольба о прощении. Один раз вечером.',
  ),
  _amsayna,
  _bikaEvening,
  _shared('bismillah_protection').inList(
    id: 'e_bismillah',
    goal: 3,
    noteEn: 'Three times in the evening.',
    noteRu: 'Три раза вечером.',
  ),
  _raditu('e', 'evening', 'вечером'),
  _kalimat,
  _shared('subhanallahi_wa_bihamdih').inList(
    id: 'e_subhan',
    goal: 100,
    source: 'Muslim 2692',
    noteEn: '100 times in the evening.',
    noteRu: '100 раз вечером.',
  ),
];
