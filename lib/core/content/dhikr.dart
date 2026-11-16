/// A remembrance or a supplication with a daily counter.
class Dhikr {
  const Dhikr({
    required this.id,
    required this.arabic,
    required this.latin,
    required this.cyrillic,
    required this.english,
    required this.russian,
    required this.goal,
    required this.source,
    this.goalFromSunnah = true,
    this.noteEn = '',
    this.noteRu = '',
    this.dua = false,
  });

  /// Stable key for the saved counters.
  final String id;
  final String arabic;
  final String latin;
  final String cyrillic;
  final String english;
  final String russian;

  /// Suggested number of repetitions per day.
  final int goal;

  /// False when no number is narrated and the goal is only a suggestion.
  final bool goalFromSunnah;

  /// Where the wording comes from.
  final String source;

  /// Where the daily number comes from, in English and Russian.
  final String noteEn;
  final String noteRu;
  final bool dua;

  String transliteration(String languageCode) =>
      languageCode == 'ru' ? cyrillic : latin;

  /// Translation in the interface language, or null for Arabic.
  String? translation(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return russian;
      case 'ar':
        return null;
      default:
        return english;
    }
  }

  /// The source with the names of the collections in the interface
  /// language; the data keeps them in English.
  String localizedSource(String languageCode) {
    final names = _collections[languageCode];
    if (names == null) return source;
    var text = source;
    names.forEach((english, local) => text = text.replaceAll(english, local));
    return languageCode == 'ar' ? text.replaceAll(', ', '، ') : text;
  }

  String note(String languageCode) => languageCode == 'ru' ? noteRu : noteEn;
}

/// The first three are the tasbih said after every prayer. The numbers come
/// from the hadiths named in each entry; where none is narrated the entry
/// says so and the goal is a suggestion the user can change.
const _collections = {
  'ru': {
    'al-Bukhari': 'аль-Бухари',
    'Muslim': 'Муслим',
    'at-Tirmidhi': 'ат-Тирмизи',
    'Abu Dawud': 'Абу Дауд',
    'Ibn Majah': 'Ибн Маджа',
    'Quran': 'Коран',
  },
  'ar': {
    'al-Bukhari': 'البخاري',
    'Muslim': 'مسلم',
    'at-Tirmidhi': 'الترمذي',
    'Abu Dawud': 'أبو داود',
    'Ibn Majah': 'ابن ماجه',
    'Quran': 'القرآن',
  },
};

const dhikrList = <Dhikr>[
  Dhikr(
    id: 'subhanallah',
    arabic: 'سُبْحَانَ اللَّهِ',
    latin: 'Subhanallah',
    cyrillic: 'Субханаллах',
    english: 'Glory be to Allah.',
    russian: 'Пречист Аллах.',
    goal: 33,
    source: 'Muslim 597',
    noteEn: '33 times after a prayer.',
    noteRu: '33 раза после молитвы.',
  ),
  Dhikr(
    id: 'alhamdulillah',
    arabic: 'الْحَمْدُ لِلَّهِ',
    latin: 'Alhamdulillah',
    cyrillic: 'Альхамдулиллях',
    english: 'All praise is due to Allah.',
    russian: 'Хвала Аллаху.',
    goal: 33,
    source: 'Muslim 597',
    noteEn: '33 times after a prayer.',
    noteRu: '33 раза после молитвы.',
  ),
  Dhikr(
    id: 'allahuakbar',
    arabic: 'اللَّهُ أَكْبَرُ',
    latin: 'Allahu akbar',
    cyrillic: 'Аллаху акбар',
    english: 'Allah is the Greatest.',
    russian: 'Аллах велик.',
    goal: 33,
    source: 'Muslim 597',
    noteEn: '33 times after a prayer.',
    noteRu: '33 раза после молитвы.',
  ),
  Dhikr(
    id: 'tahlil',
    arabic:
        'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، '
        'وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    latin:
        'La ilaha illallahu wahdahu la sharika lah, lahul-mulku wa '
        'lahul-hamd, wa huwa ala kulli shay\'in qadir',
    cyrillic:
        'Ля иляха илляллаху вахдаху ля шарика лях, ляхуль-мульку ва '
        'ляхуль-хамд, ва хува аля кулли шайин кадир',
    english:
        'There is no god but Allah alone, without partner. His is the '
        'dominion and His is the praise, and He is able to do all things.',
    russian:
        'Нет божества, кроме одного лишь Аллаха, у Которого нет '
        'сотоварища. Ему принадлежит власть, Ему хвала, и Он всё может.',
    goal: 100,
    source: 'al-Bukhari 3293, Muslim 2691',
    noteEn: '100 times a day.',
    noteRu: '100 раз в день.',
  ),
  Dhikr(
    id: 'subhanallahi_wa_bihamdih',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    latin: 'Subhanallahi wa bihamdih',
    cyrillic: 'Субханаллахи ва бихамдих',
    english: 'Glory be to Allah and praise be to Him.',
    russian: 'Пречист Аллах, и хвала Ему.',
    goal: 100,
    source: 'al-Bukhari 6405, Muslim 2691',
    noteEn: '100 times a day.',
    noteRu: '100 раз в день.',
  ),
  Dhikr(
    id: 'istighfar',
    arabic: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    latin: 'Astaghfirullaha wa atubu ilayh',
    cyrillic: 'Астагфируллаха ва атубу иляйх',
    english: 'I ask Allah for forgiveness and I repent to Him.',
    russian: 'Прошу прощения у Аллаха и приношу Ему покаяние.',
    goal: 100,
    source: 'Muslim 2702, al-Bukhari 6307',
    noteEn: '100 times a day.',
    noteRu: '100 раз в день.',
  ),
  Dhikr(
    id: 'two_light_words',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
    latin: 'Subhanallahi wa bihamdih, subhanallahil-azim',
    cyrillic: 'Субханаллахи ва бихамдих, субханаллахиль-азым',
    english:
        'Glory be to Allah and praise be to Him; glory be to Allah, '
        'the Magnificent.',
    russian: 'Пречист Аллах, и хвала Ему; пречист Аллах Великий.',
    goal: 33,
    goalFromSunnah: false,
    source: 'al-Bukhari 6406, Muslim 2694',
    noteEn: 'No number is narrated; the goal is a suggestion.',
    noteRu: 'Число в хадисе не названо, цель предложена приложением.',
  ),
  Dhikr(
    id: 'four_words',
    arabic: 'سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَٰهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ',
    latin:
        'Subhanallah, walhamdulillah, wa la ilaha illallah, wallahu '
        'akbar',
    cyrillic:
        'Субханаллах, валь-хамдулиллях, ва ля иляха илляллах, '
        'валлаху акбар',
    english:
        'Glory be to Allah, praise be to Allah, there is no god but '
        'Allah, and Allah is the Greatest.',
    russian:
        'Пречист Аллах, хвала Аллаху, нет божества, кроме Аллаха, и '
        'Аллах велик.',
    goal: 33,
    goalFromSunnah: false,
    source: 'Muslim 2695',
    noteEn: 'No number is narrated; the goal is a suggestion.',
    noteRu: 'Число в хадисе не названо, цель предложена приложением.',
  ),
  Dhikr(
    id: 'hawqala',
    arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    latin: 'La hawla wa la quwwata illa billah',
    cyrillic: 'Ля хауля ва ля куввата илля биллях',
    english: 'There is no might and no power except with Allah.',
    russian: 'Нет мощи и силы ни у кого, кроме Аллаха.',
    goal: 33,
    goalFromSunnah: false,
    source: 'al-Bukhari 6384, Muslim 2704',
    noteEn: 'No number is narrated; the goal is a suggestion.',
    noteRu: 'Число в хадисе не названо, цель предложена приложением.',
  ),
  Dhikr(
    id: 'la_ilaha_illallah',
    arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
    latin: 'La ilaha illallah',
    cyrillic: 'Ля иляха илляллах',
    english: 'There is no god but Allah.',
    russian: 'Нет божества, кроме Аллаха.',
    goal: 100,
    goalFromSunnah: false,
    source: 'at-Tirmidhi 3383',
    noteEn: 'No number is narrated; the goal is a suggestion.',
    noteRu: 'Число в хадисе не названо, цель предложена приложением.',
  ),
  Dhikr(
    id: 'sayyid_istighfar',
    arabic:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا '
        'عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ '
        'لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ '
        'الذُّنُوبَ إِلَّا أَنْتَ',
    latin:
        'Allahumma anta rabbi, la ilaha illa ant, khalaqtani wa ana '
        'abduk, wa ana ala ahdika wa wa\'dika mastata\'t, a\'udhu bika min '
        'sharri ma sana\'t, abu\'u laka bini\'matika alayy, wa abu\'u laka '
        'bidhanbi faghfir li, fa innahu la yaghfirudh-dhunuba illa ant',
    cyrillic:
        'Аллахумма анта рабби, ля иляха илля ант, халяктани ва ана '
        'абдук, ва ана аля ахдика ва ва‘дика мастата‘т, а‘узу бика мин '
        'шарри ма сана‘т, абу’у ляка бини‘матика алеййа, ва абу’у ляка '
        'бизанби фагфир ли, фа иннаху ля йагфируз-зунуба илля ант',
    english:
        'O Allah, You are my Lord; there is no god but You. You '
        'created me and I am Your servant, and I keep Your covenant and '
        'promise as best I can. I seek refuge in You from the evil of what '
        'I have done. I acknowledge Your favour upon me and I acknowledge '
        'my sin, so forgive me, for none forgives sins but You.',
    russian:
        'О Аллах, Ты мой Господь, нет божества, кроме Тебя. Ты создал '
        'меня, и я Твой раб, и я верен завету с Тобой и обещанию Тебе, '
        'насколько могу. Прибегаю к Твоей защите от зла того, что я '
        'совершил. Признаю Твою милость ко мне и признаю свой грех, '
        'прости же меня, ведь никто не прощает грехов, кроме Тебя.',
    goal: 2,
    source: 'al-Bukhari 6306',
    noteEn: 'Once in the morning and once in the evening.',
    noteRu: 'Один раз утром и один раз вечером.',
  ),
  Dhikr(
    id: 'rabbana_atina',
    dua: true,
    arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    latin:
        'Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa '
        'qina adhaban-nar',
    cyrillic:
        'Раббана атина фид-дунья хасанатан ва филь-ахирати хасанатан '
        'ва кына азабан-нар',
    english:
        'Our Lord, give us good in this world and good in the '
        'Hereafter, and protect us from the punishment of the Fire.',
    russian:
        'Господь наш, даруй нам добро в этом мире и добро в Последней '
        'жизни и защити нас от мучений в Огне.',
    goal: 3,
    goalFromSunnah: false,
    source: 'Quran 2:201, al-Bukhari 6389',
    noteEn:
        'The supplication the Prophet made most often. No number is '
        'narrated; the goal is a suggestion.',
    noteRu:
        'Мольба, с которой Пророк обращался чаще всего. Число в хадисе '
        'не названо, цель предложена приложением.',
  ),
  Dhikr(
    id: 'ainni',
    dua: true,
    arabic:
        'اللَّهُمَّ أَعِنِّي عَلَىٰ ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
    latin: 'Allahumma a\'inni ala dhikrika wa shukrika wa husni ibadatik',
    cyrillic: 'Аллахумма а‘инни аля зикрика ва шукрика ва хусни ибадатик',
    english:
        'O Allah, help me to remember You, to thank You and to '
        'worship You well.',
    russian:
        'О Аллах, помоги мне поминать Тебя, благодарить Тебя и '
        'наилучшим образом поклоняться Тебе.',
    goal: 5,
    source: 'Abu Dawud 1522',
    noteEn: 'After each of the five prayers.',
    noteRu: 'После каждой из пяти молитв.',
  ),
  Dhikr(
    id: 'bismillah_protection',
    dua: true,
    arabic:
        'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ، '
        'وَهُوَ السَّمِيعُ الْعَلِيمُ',
    latin:
        'Bismillahil-ladhi la yadurru ma\'asmihi shay\'un fil-ardi wa '
        'la fis-sama\', wa huwas-sami\'ul-alim',
    cyrillic:
        'Бисмилляхиль-лязи ля йадурру ма‘асмихи шайун филь-арды ва '
        'ля фис-сама, ва хувас-сами‘уль-алим',
    english:
        'In the name of Allah, with whose name nothing on earth or in '
        'heaven can cause harm, and He is the All-Hearing, the All-Knowing.',
    russian:
        'С именем Аллаха, с именем Которого ничто не причинит вреда '
        'ни на земле, ни на небе, и Он Слышащий, Знающий.',
    goal: 6,
    source: 'Abu Dawud 5088, at-Tirmidhi 3388',
    noteEn: 'Three times in the morning and three times in the evening.',
    noteRu: 'Три раза утром и три раза вечером.',
  ),
  Dhikr(
    id: 'rabbighfirli',
    dua: true,
    arabic: 'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ، إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ',
    latin: 'Rabbighfir li wa tub alayy, innaka antat-tawwabur-rahim',
    cyrillic: 'Раббигфир ли ва туб алеййа, иннака антат-таввабур-рахим',
    english:
        'My Lord, forgive me and accept my repentance; You are the '
        'Acceptor of repentance, the Merciful.',
    russian:
        'Господи, прости меня и прими моё покаяние, поистине, Ты '
        'Принимающий покаяние, Милосердный.',
    goal: 100,
    source: 'Abu Dawud 1516, at-Tirmidhi 3434',
    noteEn: 'The Prophet was counted saying it 100 times in one sitting.',
    noteRu:
        'Сподвижники насчитывали, что Пророк произносил это 100 раз за '
        'одно собрание.',
  ),
  Dhikr(
    id: 'huda',
    dua: true,
    arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَىٰ وَالتُّقَىٰ وَالْعَفَافَ وَالْغِنَىٰ',
    latin: 'Allahumma inni as\'alukal-huda wat-tuqa wal-afafa wal-ghina',
    cyrillic:
        'Аллахумма инни ас’алюкаль-худа ват-тука валь-афафа '
        'валь-гына',
    english:
        'O Allah, I ask You for guidance, piety, chastity and '
        'sufficiency.',
    russian:
        'О Аллах, прошу у Тебя верного руководства, богобоязненности, '
        'целомудрия и достатка.',
    goal: 1,
    goalFromSunnah: false,
    source: 'Muslim 2721',
    noteEn: 'No number is narrated; the goal is a suggestion.',
    noteRu: 'Число в хадисе не названо, цель предложена приложением.',
  ),
  Dhikr(
    id: 'muqallib',
    dua: true,
    arabic: 'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَىٰ دِينِكَ',
    latin: 'Ya muqallibal-qulubi thabbit qalbi ala dinik',
    cyrillic: 'Йа мукаллибаль-кулюби саббит кальби аля диник',
    english: 'O Turner of hearts, keep my heart firm upon Your religion.',
    russian:
        'О Тот, Кто переворачивает сердца, укрепи моё сердце на Твоей '
        'религии.',
    goal: 1,
    goalFromSunnah: false,
    source: 'at-Tirmidhi 2140',
    noteEn:
        'The Prophet said it often. No number is narrated; the goal '
        'is a suggestion.',
    noteRu:
        'Пророк часто произносил эту мольбу. Число в хадисе не '
        'названо, цель предложена приложением.',
  ),
  Dhikr(
    id: 'ilm_nafi',
    dua: true,
    arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا',
    latin:
        'Allahumma inni as\'aluka ilman nafi\'an, wa rizqan tayyiban, '
        'wa amalan mutaqabbala',
    cyrillic:
        'Аллахумма инни ас’алюка ильман нафи‘ан, ва ризкан таййибан, '
        'ва амалян мутакаббаля',
    english:
        'O Allah, I ask You for beneficial knowledge, good provision '
        'and deeds that are accepted.',
    russian:
        'О Аллах, прошу у Тебя полезного знания, благого удела и '
        'дел, которые будут приняты.',
    goal: 1,
    source: 'Ibn Majah 925',
    noteEn: 'Once after the Fajr prayer.',
    noteRu: 'Один раз после утренней молитвы.',
  ),
  Dhikr(
    id: 'afuw',
    dua: true,
    arabic: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
    latin: 'Allahumma innaka afuwwun tuhibbul-afwa fa\'fu anni',
    cyrillic: 'Аллахумма иннака афуввун тухиббуль-афва фа‘фу анни',
    english: 'O Allah, You are Pardoning and love to pardon, so pardon me.',
    russian:
        'О Аллах, поистине, Ты Снисходительный, любишь прощать, '
        'прости же меня.',
    goal: 1,
    goalFromSunnah: false,
    source: 'at-Tirmidhi 3513',
    noteEn:
        'Taught for Laylat al-Qadr. No number is narrated; the goal '
        'is a suggestion.',
    noteRu:
        'Мольба, которой Пророк научил для Ночи предопределения. '
        'Число в хадисе не названо, цель предложена приложением.',
  ),
];

/// The local date as yyyy-mm-dd, the key the daily counters are saved under.
String dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
