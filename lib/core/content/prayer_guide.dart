/// How to pray, step by step, in the Hanafi school. A short guide for
/// someone learning; it does not replace learning with a teacher.
library;

/// A text in the three interface languages.
class Tr {
  const Tr(this.ru, this.en, this.ar);

  final String ru;
  final String en;
  final String ar;

  String of(String languageCode) => switch (languageCode) {
    'ru' => ru,
    'ar' => ar,
    _ => en,
  };
}

/// Words that are said in the prayer.
class Recital {
  const Recital({
    required this.arabic,
    required this.latin,
    required this.cyrillic,
    required this.meaning,
  });

  final String arabic;
  final String latin;
  final String cyrillic;
  final Tr meaning;

  String transliteration(String languageCode) =>
      languageCode == 'ru' ? cyrillic : latin;
}

class GuideStep {
  const GuideStep({required this.title, required this.text, this.recital});

  final Tr title;
  final Tr text;
  final Recital? recital;
}

/// One row of the table of rakaats. Zero means there is none.
class RakaatRow {
  const RakaatRow(
    this.slot, {
    this.sunnahBefore = 0,
    required this.fard,
    this.sunnahAfter = 0,
    this.witr = 0,
  });

  /// fajr, dhuhr, asr, maghrib or isha.
  final String slot;
  final int sunnahBefore;
  final int fard;
  final int sunnahAfter;
  final int witr;
}

const rakaatTable = <RakaatRow>[
  RakaatRow('fajr', sunnahBefore: 2, fard: 2),
  RakaatRow('dhuhr', sunnahBefore: 4, fard: 4, sunnahAfter: 2),
  RakaatRow('asr', fard: 4),
  RakaatRow('maghrib', fard: 3, sunnahAfter: 2),
  RakaatRow('isha', fard: 4, sunnahAfter: 2, witr: 3),
];

const guideIntro = Tr(
  'Молитва состоит из ракаатов. Ракаат — это один круг: стояние с чтением '
      'Корана, поясной поклон и два земных поклона. Ниже описан порядок по '
      'ханафитскому мазхабу. Это краткая памятка, лучше всего учиться '
      'молитве у знающего человека.',
  'A prayer is made of rakaats. A rakaat is one cycle: standing with the '
      'recitation of the Quran, bowing, and two prostrations. Below is the '
      'order in the Hanafi school. This is a short reminder; prayer is best '
      'learnt from a knowledgeable person.',
  'تتكون الصلاة من ركعات. الركعة قيام مع قراءة القرآن ثم ركوع وسجدتان. '
      'فيما يلي صفة الصلاة على المذهب الحنفي. هذه مذكرة مختصرة، والأفضل '
      'تعلّم الصلاة على يد من يعلمها.',
);

const rakaatNotes = Tr(
  'Фард обязателен. Сунна в таблице — это сунна муаккада, которую Пророк ﷺ '
      'не оставлял. Витр после иши — ваджиб. Перед асром и перед ишей можно '
      'по желанию совершить ещё 4 ракаата сунны. В пятницу мужчины вместо '
      'зухра совершают в мечети джума: 4 ракаата сунны, 2 ракаата фарда за '
      'имамом и 4 ракаата сунны.',
  'Fard is obligatory. The sunnah in the table is the emphasised sunnah '
      'that the Prophet ﷺ did not leave. Witr after Isha is wajib. Before '
      'Asr and before Isha one may also pray 4 optional rakaats of sunnah. '
      'On Friday men pray Jumuah in the mosque instead of Dhuhr: 4 rakaats '
      'of sunnah, 2 rakaats of fard behind the imam, and 4 rakaats of sunnah.',
  'الفرض واجب الأداء. والسنة في الجدول هي السنة المؤكدة التي لم يتركها '
      'النبي ﷺ. والوتر بعد العشاء واجب. ويستحب قبل العصر وقبل العشاء أربع '
      'ركعات. ويوم الجمعة يصلي الرجال الجمعة في المسجد بدل الظهر: أربع سنة، '
      'ثم ركعتان فرض خلف الإمام، ثم أربع سنة.',
);

const guideBefore = <Tr>[
  Tr(
    'Наступило время молитвы.',
    'The time of the prayer has come.',
    'دخول وقت الصلاة.',
  ),
  Tr(
    'Есть омовение (вуду), а когда нужно — полное омовение (гусль).',
    'You have wudu, and ghusl when it is required.',
    'الطهارة: الوضوء، والغسل عند وجوبه.',
  ),
  Tr(
    'Тело, одежда и место молитвы чисты.',
    'Your body, clothes and the place of prayer are clean.',
    'طهارة البدن والثوب والمكان.',
  ),
  Tr(
    'Аврат закрыт: у мужчины от пупка до колен включительно, у женщины всё '
        'тело, кроме лица, кистей рук и стоп.',
    'The awrah is covered: for a man from the navel to the knees inclusive, '
        'for a woman the whole body except the face, hands and feet.',
    'ستر العورة: للرجل من السرة إلى الركبة مع الركبة، وللمرأة جميع البدن '
        'إلا الوجه والكفين والقدمين.',
  ),
  Tr('Вы стоите лицом к кибле.', 'You face the qibla.', 'استقبال القبلة.'),
  Tr(
    'В сердце есть намерение: какую именно молитву вы совершаете.',
    'You have the intention in your heart: which prayer you are praying.',
    'النية بالقلب: تعيين الصلاة التي تصليها.',
  ),
];

/// What surrounds the adhan: kept short, the guide is long as it is.
const guideAdhan = <GuideStep>[
  GuideStep(
    title: Tr('Дуа после азана', 'The dua after the adhan', 'الدعاء بعد الأذان'),
    text: Tr(
      'Слушая азан, повторяйте слова муэдзина, а на «Хаййа ‘аля-с-салях» и '
          '«Хаййа ‘аля-ль-фалях» говорите «Ля хауля ва ля куввата илля '
          'биллях». После азана прочитайте салават и это дуа (аль-Бухари, '
          '614).',
      'While listening to the adhan repeat the muezzin’s words, and at '
          '“Hayya ‘ala-s-salah” and “Hayya ‘ala-l-falah” say “La hawla wa la '
          'quwwata illa billah”. After the adhan read the salawat and this '
          'dua (al-Bukhari, 614).',
      'ردِّد ما يقول المؤذن، وقل عند الحيعلتين: «لا حول ولا قوة إلا بالله». '
          'وبعد الأذان صلِّ على النبي ﷺ ثم ادعُ بهذا الدعاء (البخاري، 614).',
    ),
    recital: Recital(
      arabic:
          'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ '
          'الْقَائِمَةِ، آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ، '
          'وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ',
      latin:
          'Allahumma Rabba hadhihi-d-da‘wati-t-tammah, wa-s-salati-l-qa’imah, '
          'ati Muhammadan al-wasilata wa-l-fadilah, wab‘ath-hu maqaman '
          'mahmudan alladhi wa‘adtah',
      cyrillic:
          'Аллахумма Рабба хазихи-д-да‘вати-т-таммати ва-с-саляти-ль-ка’има, '
          'ати Мухаммадан аль-василята ва-ль-фадыля, ваб‘асху макаман '
          'махмудан аллязи ва‘адтах',
      meaning: Tr(
        'О Аллах, Господь этого совершенного призыва и начинающейся молитвы, '
            'даруй Мухаммаду аль-Василю и высокое положение и возведи его '
            'на достохвальное место, которое Ты ему обещал.',
        'O Allah, Lord of this perfect call and of the prayer about to be '
            'established, grant Muhammad al-Wasilah and the high rank, and '
            'raise him to the praised station that You have promised him.',
        '',
      ),
    ),
  ),
  GuideStep(
    title: Tr('Икама', 'The iqamah', 'الإقامة'),
    text: Tr(
      'Икама произносится прямо перед фардом. Её слова те же, что в азане, '
          'и повторяются столько же раз, а после «Хаййа ‘аля-ль-фалях» '
          'дважды добавляется эта фраза. Икаму читают быстрее азана. '
          'Мужчине, который молится один, читать её желательно, женщины '
          'её не читают.',
      'The iqamah is said right before the fard prayer. Its words are those '
          'of the adhan, repeated the same number of times, and after “Hayya '
          '‘ala-l-falah” this phrase is added twice. It is said faster than '
          'the adhan. A man praying alone is recommended to say it; women '
          'do not say it.',
      'تُقال الإقامة قبل الفرض مباشرة، وألفاظها كألفاظ الأذان مثنى مثنى، '
          'ويُزاد بعد «حيّ على الفلاح» هذا اللفظ مرتين. وتُحدَر الإقامة '
          'أسرع من الأذان. وهي مستحبة للرجل المنفرد، ولا تقيم المرأة.',
    ),
    recital: Recital(
      arabic: 'قَدْ قَامَتِ الصَّلَاةُ',
      latin: 'Qad qamati-s-salah',
      cyrillic: 'Кад камати-с-салях',
      meaning: Tr('Молитва началась.', 'The prayer has begun.', ''),
    ),
  ),
];

const guideSteps = <GuideStep>[
  GuideStep(
    title: Tr('Вступительный такбир', 'The opening takbir', 'تكبيرة الإحرام'),
    text: Tr(
      'Встаньте прямо. Мужчина поднимает руки так, чтобы большие пальцы '
          'коснулись мочек ушей, женщина — до уровня плеч. Произнесите '
          'такбир. С этого момента нельзя разговаривать, есть и '
          'оглядываться.',
      'Stand upright. A man raises his hands until the thumbs touch the '
          'earlobes, a woman to the level of the shoulders. Say the takbir. '
          'From this moment you do not talk, eat or look around.',
      'قف مستقيمًا. يرفع الرجل يديه حتى يحاذي إبهاماه شحمتي أذنيه، وترفع '
          'المرأة يديها حذاء منكبيها. ثم كبّر. ومن هذه اللحظة يحرم الكلام '
          'والأكل والالتفات.',
    ),
    recital: Recital(
      arabic: 'اللَّهُ أَكْبَرُ',
      latin: 'Allahu akbar',
      cyrillic: 'Аллаху акбар',
      meaning: Tr('Аллах велик.', 'Allah is the Greatest.', ''),
    ),
  ),
  GuideStep(
    title: Tr(
      'Стояние: сана',
      'Standing: the opening praise',
      'القيام: الثناء',
    ),
    text: Tr(
      'Мужчина кладёт правую руку на левую ниже пупка, женщина — на грудь. '
          'Смотрите на место земного поклона. Про себя прочитайте сана. Она '
          'читается только в первом ракаате.',
      'A man places the right hand over the left below the navel, a woman '
          'on the chest. Look at the place of prostration. Quietly read the '
          'opening praise. It is read only in the first rakaat.',
      'يضع الرجل يمينه على يساره تحت السرة، وتضع المرأة يديها على صدرها. '
          'انظر إلى موضع السجود. اقرأ الثناء سرًّا، وهو في الركعة الأولى فقط.',
    ),
    recital: Recital(
      arabic:
          'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى جَدُّكَ، '
          'وَلَا إِلَهَ غَيْرُكَ',
      latin:
          'Subhanaka Allahumma wa bihamdika, wa tabarakasmuka, wa ta‘ala '
          'jadduka, wa la ilaha ghayruk',
      cyrillic:
          'Субханака Аллахумма ва бихамдика, ва табаракасмука, ва та‘аля '
          'джаддука, ва ля иляха гайрук',
      meaning: Tr(
        'Пречист Ты, о Аллах, и хвала Тебе. Благословенно имя Твоё, '
            'превыше всего величие Твоё, и нет божества, кроме Тебя.',
        'Glory be to You, O Allah, and praise. Blessed is Your name, '
            'exalted is Your majesty, and there is no god but You.',
        '',
      ),
    ),
  ),
  GuideStep(
    title: Tr('Чтение Корана', 'Recitation of the Quran', 'القراءة'),
    text: Tr(
      'Прочитайте про себя «А‘узу билляхи минаш-шайтанир-раджим», затем '
          '«Бисмилляхир-Рахманир-Рахим» и суру «Аль-Фатиха». После неё тихо '
          'скажите «Амин». Затем прочитайте любую короткую суру или не '
          'меньше трёх коротких аятов, например суру «Аль-Ихлас».',
      'Quietly read “A‘udhu billahi minash-shaytanir-rajim”, then '
          '“Bismillahir-Rahmanir-Rahim” and surah Al-Fatihah. After it say '
          '“Amin” quietly. Then read any short surah or at least three '
          'short ayahs, for example surah Al-Ikhlas.',
      'تعوّذ سرًّا، ثم سمِّ، ثم اقرأ سورة الفاتحة وقل بعدها «آمين» سرًّا. ثم '
          'اقرأ سورة قصيرة أو ثلاث آيات قصار على الأقل، كسورة الإخلاص.',
    ),
  ),
  GuideStep(
    title: Tr('Поясной поклон (руку‘)', 'Bowing (ruku)', 'الركوع'),
    text: Tr(
      'Со словами «Аллаху акбар» поклонитесь. Мужчина держит спину ровно и '
          'обхватывает колени ладонями, женщина наклоняется меньше. Трижды '
          'произнесите тасбих.',
      'Saying “Allahu akbar”, bow. A man keeps his back level and grasps '
          'the knees with his palms; a woman bows less deeply. Say the '
          'tasbih three times.',
      'كبّر واركع. يسوّي الرجل ظهره ويقبض على ركبتيه بكفيه، وتنحني المرأة '
          'انحناءً يسيرًا. وسبّح ثلاثًا.',
    ),
    recital: Recital(
      arabic: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
      latin: 'Subhana Rabbiyal-‘Azim',
      cyrillic: 'Субхана Раббияль-‘Азым',
      meaning: Tr(
        'Пречист мой Великий Господь.',
        'Glory be to my Lord, the Magnificent.',
        '',
      ),
    ),
  ),
  GuideStep(
    title: Tr('Выпрямление', 'Rising from the bow', 'الرفع من الركوع'),
    text: Tr(
      'Выпрямляясь, произнесите первые слова, а когда встанете прямо — '
          'вторые. Постойте мгновение спокойно.',
      'While rising say the first words, and once upright the second. '
          'Stand still for a moment.',
      'قل عند الرفع الجملة الأولى، فإذا استويت قائمًا فقل الثانية، واطمئن '
          'قائمًا.',
    ),
    recital: Recital(
      arabic: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ ۝ رَبَّنَا لَكَ الْحَمْدُ',
      latin: 'Sami‘allahu liman hamidah. Rabbana lakal-hamd',
      cyrillic: 'Сами‘аллаху лиман хамидах. Раббана лякаль-хамд',
      meaning: Tr(
        'Аллах слышит того, кто Его восхвалил. Господь наш, Тебе хвала.',
        'Allah hears the one who praises Him. Our Lord, to You is the '
            'praise.',
        '',
      ),
    ),
  ),
  GuideStep(
    title: Tr('Земной поклон (саджда)', 'Prostration (sajdah)', 'السجود'),
    text: Tr(
      'Со словами «Аллаху акбар» опуститесь: сначала колени, затем ладони, '
          'затем лоб и нос между ладонями. Пальцы ног направлены к кибле. '
          'Мужчина держит локти приподнятыми, женщина прижимает руки к '
          'телу. Трижды произнесите тасбих.',
      'Saying “Allahu akbar”, go down: knees first, then palms, then the '
          'forehead and nose between the palms. The toes point to the '
          'qibla. A man keeps his elbows raised; a woman keeps her arms '
          'close to the body. Say the tasbih three times.',
      'كبّر واسجد: ضع ركبتيك ثم كفيك ثم جبهتك وأنفك بين كفيك، ووجّه أصابع '
          'قدميك إلى القبلة. يجافي الرجل مرفقيه، وتضم المرأة ذراعيها. وسبّح '
          'ثلاثًا.',
    ),
    recital: Recital(
      arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      latin: 'Subhana Rabbiyal-A‘la',
      cyrillic: 'Субхана Раббияль-А‘ля',
      meaning: Tr(
        'Пречист мой Высочайший Господь.',
        'Glory be to my Lord, the Most High.',
        '',
      ),
    ),
  ),
  GuideStep(
    title: Tr(
      'Сидение и второй земной поклон',
      'Sitting and the second prostration',
      'الجلسة والسجدة الثانية',
    ),
    text: Tr(
      'Со словами «Аллаху акбар» сядьте и на мгновение замрите. Затем с '
          'такбиром совершите второй земной поклон так же, как первый. На '
          'этом первый ракаат закончен.',
      'Saying “Allahu akbar”, sit up and pause for a moment. Then, with a '
          'takbir, make the second prostration like the first. This '
          'completes the first rakaat.',
      'كبّر واجلس مطمئنًّا، ثم كبّر واسجد السجدة الثانية كالأولى. وبهذا تتم '
          'الركعة الأولى.',
    ),
  ),
  GuideStep(
    title: Tr('Второй ракаат', 'The second rakaat', 'الركعة الثانية'),
    text: Tr(
      'С такбиром встаньте, не опираясь руками о пол без нужды. Сана и '
          '«А‘узу» больше не читаются: начните с «Бисмиллях», прочитайте '
          '«Аль-Фатиху» и короткую суру. Затем совершите поясной поклон и '
          'два земных поклона, как в первом ракаате.',
      'Stand up with a takbir, without leaning on the floor unless you '
          'need to. The opening praise and “A‘udhu” are not repeated: start '
          'with “Bismillah”, read Al-Fatihah and a short surah. Then bow '
          'and make two prostrations as in the first rakaat.',
      'قم مكبّرًا. لا يعاد الثناء ولا التعوذ: سمِّ واقرأ الفاتحة وسورة قصيرة، '
          'ثم اركع واسجد سجدتين كما في الركعة الأولى.',
    ),
  ),
  GuideStep(
    title: Tr(
      'Сидение и ташаххуд',
      'Sitting and the tashahhud',
      'القعود والتشهد',
    ),
    text: Tr(
      'После второго земного поклона второго ракаата сядьте. Мужчина '
          'садится на левую стопу, а правую ставит вертикально; женщина '
          'выводит обе стопы вправо. Руки лежат на бёдрах. Прочитайте '
          'ташаххуд. На словах «ля иляха» поднимите указательный палец '
          'правой руки, на словах «илляллах» опустите.',
      'After the second prostration of the second rakaat, sit. A man sits '
          'on the left foot and keeps the right one upright; a woman puts '
          'both feet out to the right. The hands rest on the thighs. Read '
          'the tashahhud. At “la ilaha” raise the right index finger, at '
          '“illallah” lower it.',
      'بعد السجدة الثانية من الركعة الثانية اجلس. يفترش الرجل رجله اليسرى '
          'وينصب اليمنى، وتتورك المرأة. ضع يديك على فخذيك واقرأ التشهد، '
          'وارفع السبابة عند النفي وضعها عند الإثبات.',
    ),
    recital: Recital(
      arabic:
          'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلَامُ عَلَيْكَ أَيُّهَا '
          'النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ '
          'الصَّالِحِينَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا '
          'عَبْدُهُ وَرَسُولُهُ',
      latin:
          'At-tahiyyatu lillahi was-salawatu wat-tayyibat. As-salamu '
          '‘alayka ayyuhan-nabiyyu wa rahmatullahi wa barakatuh. As-salamu '
          '‘alayna wa ‘ala ‘ibadillahis-salihin. Ashhadu an la ilaha '
          'illallah, wa ashhadu anna Muhammadan ‘abduhu wa rasuluh',
      cyrillic:
          'Ат-тахийяту лилляхи вас-салявату ват-таййибат. Ас-саляму '
          '‘алейка аййухан-набийю ва рахматуллахи ва баракатух. Ас-саляму '
          '‘алейна ва ‘аля ‘ибадилляхис-салихин. Ашхаду ан ля иляха '
          'илляллах, ва ашхаду анна Мухаммадан ‘абдуху ва расулюх',
      meaning: Tr(
        'Приветствия Аллаху, и молитвы, и всё благое. Мир тебе, о Пророк, '
            'милость Аллаха и Его благословения. Мир нам и праведным рабам '
            'Аллаха. Свидетельствую, что нет божества, кроме Аллаха, и '
            'свидетельствую, что Мухаммад — Его раб и посланник.',
        'All greetings, prayers and good things are for Allah. Peace be '
            'upon you, O Prophet, and the mercy of Allah and His blessings. '
            'Peace be upon us and upon the righteous servants of Allah. I '
            'bear witness that there is no god but Allah, and I bear '
            'witness that Muhammad is His servant and messenger.',
        '',
      ),
    ),
  ),
  GuideStep(
    title: Tr(
      'Салават, дуа и салям',
      'Salawat, dua and the salam',
      'الصلاة على النبي والدعاء والتسليم',
    ),
    text: Tr(
      'В последнем сидении после ташаххуда прочитайте салават (самый '
          'длинный на вкладке «Салават») и любое дуа из Корана или сунны, '
          'например «Раббана атина» с вкладки «Дуа». Затем поверните голову '
          'направо и произнесите салям, потом налево и произнесите его ещё '
          'раз. Молитва завершена.',
      'In the last sitting, after the tashahhud, read the salawat (the '
          'longest one on the Salawat tab) and any dua from the Quran or '
          'the Sunnah, for example “Rabbana atina” from the Dua tab. Then '
          'turn the head to the right and say the salam, then to the left '
          'and say it again. The prayer is complete.',
      'في القعود الأخير بعد التشهد اقرأ الصلاة الإبراهيمية ثم ادعُ بدعاء من '
          'القرآن أو السنة مثل «ربنا آتنا». ثم سلّم عن يمينك ثم عن يسارك. '
          'وبهذا تمت الصلاة.',
    ),
    recital: Recital(
      arabic: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
      latin: 'As-salamu ‘alaykum wa rahmatullah',
      cyrillic: 'Ас-саляму ‘алейкум ва рахматуллах',
      meaning: Tr(
        'Мир вам и милость Аллаха.',
        'Peace be upon you and the mercy of Allah.',
        '',
      ),
    ),
  ),
];

const guideMore = <GuideStep>[
  GuideStep(
    title: Tr(
      'Если ракаатов три или четыре',
      'When there are three or four rakaats',
      'إذا كانت الصلاة ثلاثية أو رباعية',
    ),
    text: Tr(
      'После второго ракаата прочитайте в сидении только ташаххуд и с '
          'такбиром встаньте. В третьем и четвёртом ракаатах фарда читается '
          'только «Аль-Фатиха», без суры. В молитвах сунны и в витре сура '
          'после «Аль-Фатихи» читается в каждом ракаате. В последнем '
          'ракаате сядьте, прочитайте ташаххуд, салават и дуа и дайте '
          'салям.',
      'After the second rakaat read only the tashahhud while sitting and '
          'stand up with a takbir. In the third and fourth rakaats of a '
          'fard prayer only Al-Fatihah is read, without a surah. In sunnah '
          'prayers and in witr a surah follows Al-Fatihah in every rakaat. '
          'In the last rakaat sit, read the tashahhud, the salawat and a '
          'dua, and give the salam.',
      'بعد الركعة الثانية اقرأ التشهد فقط ثم قم مكبّرًا. في الثالثة والرابعة '
          'من الفرض تُقرأ الفاتحة وحدها. وفي السنن والوتر تُقرأ سورة بعد '
          'الفاتحة في كل ركعة. وفي الركعة الأخيرة اجلس واقرأ التشهد والصلاة '
          'على النبي والدعاء ثم سلّم.',
    ),
  ),
  GuideStep(
    title: Tr('Витр', 'Witr', 'الوتر'),
    text: Tr(
      'Витр — три ракаата с одним салямом, после иши. После второго '
          'ракаата читается ташаххуд. В третьем ракаате после «Аль-Фатихи» '
          'и суры поднимите руки, как при вступительном такбире, скажите '
          '«Аллаху акбар», снова сложите руки и прочитайте дуа кунут, затем '
          'совершите поясной поклон. Кто ещё не выучил кунут, может '
          'прочитать «Раббана атина».',
      'Witr is three rakaats with one salam, after Isha. After the second '
          'rakaat the tashahhud is read. In the third rakaat, after '
          'Al-Fatihah and a surah, raise the hands as in the opening '
          'takbir, say “Allahu akbar”, fold the hands again and read the '
          'qunut, then bow. Someone who has not yet learnt the qunut may '
          'read “Rabbana atina”.',
      'الوتر ثلاث ركعات بتسليمة واحدة بعد العشاء، ويُقرأ التشهد بعد الثانية. '
          'وفي الثالثة بعد الفاتحة والسورة ارفع يديك وكبّر ثم اقرأ دعاء '
          'القنوت ثم اركع. ومن لم يحفظ القنوت فليقرأ «ربنا آتنا».',
    ),
    recital: Recital(
      arabic:
          'اللَّهُمَّ إِنَّا نَسْتَعِينُكَ وَنَسْتَغْفِرُكَ، وَنُؤْمِنُ بِكَ وَنَتَوَكَّلُ عَلَيْكَ، '
          'وَنُثْنِي عَلَيْكَ الْخَيْرَ، وَنَشْكُرُكَ وَلَا نَكْفُرُكَ، وَنَخْلَعُ وَنَتْرُكُ مَنْ '
          'يَفْجُرُكَ، اللَّهُمَّ إِيَّاكَ نَعْبُدُ، وَلَكَ نُصَلِّي وَنَسْجُدُ، وَإِلَيْكَ نَسْعَى '
          'وَنَحْفِدُ، نَرْجُو رَحْمَتَكَ وَنَخْشَى عَذَابَكَ، إِنَّ عَذَابَكَ بِالْكُفَّارِ مُلْحِقٌ',
      latin:
          'Allahumma inna nasta‘inuka wa nastaghfiruk, wa nu’minu bika wa '
          'natawakkalu ‘alayk, wa nuthni ‘alaykal-khayr, wa nashkuruka wa '
          'la nakfuruk, wa nakhla‘u wa natruku man yafjuruk. Allahumma '
          'iyyaka na‘budu, wa laka nusalli wa nasjud, wa ilayka nas‘a wa '
          'nahfid, narju rahmataka wa nakhsha ‘adhabak, inna ‘adhabaka '
          'bil-kuffari mulhiq',
      cyrillic:
          'Аллахумма инна наста‘инука ва настагфирук, ва ну’мину бика ва '
          'натаваккалю ‘алейк, ва нусни ‘алейкаль-хайр, ва нашкурука ва ля '
          'накфурук, ва нахля‘у ва натруку ман яфджурук. Аллахумма иййака '
          'на‘буду, ва ляка нусалли ва насджуд, ва илейка нас‘а ва нахфид, '
          'нарджу рахматака ва нахша ‘азабак, инна ‘азабака биль-куффари '
          'мульхик',
      meaning: Tr(
        'О Аллах, мы просим у Тебя помощи и прощения, веруем в Тебя и '
            'уповаем на Тебя, восхваляем Тебя за всё благое, благодарим '
            'Тебя и не проявляем неблагодарности, отрекаемся от тех, кто '
            'ослушается Тебя, и оставляем их. О Аллах, Тебе одному мы '
            'поклоняемся, Тебе молимся и совершаем земной поклон, к Тебе '
            'стремимся и спешим, надеемся на Твою милость и страшимся '
            'Твоего наказания. Поистине, Твоё наказание постигнет '
            'неверующих.',
        'O Allah, we ask You for help and forgiveness, we believe in You '
            'and rely on You, we praise You for all good, we thank You and '
            'are not ungrateful, and we leave and forsake those who disobey '
            'You. O Allah, You alone we worship, to You we pray and '
            'prostrate, to You we strive and hasten, we hope for Your mercy '
            'and fear Your punishment. Indeed, Your punishment will reach '
            'the disbelievers.',
        '',
      ),
    ),
  ),
  GuideStep(
    title: Tr('Вслух или про себя', 'Aloud or quietly', 'الجهر والإسرار'),
    text: Tr(
      'Когда вы молитесь в одиночку, всё можно читать тихо, так, чтобы '
          'слышать себя. Имам читает «Аль-Фатиху» и суру вслух в двух '
          'ракаатах фаджра и в первых двух ракаатах магриба и иши. Тот, кто '
          'молится за имамом, Коран не читает и только следует за ним.',
      'When you pray alone, everything may be read quietly, so that you '
          'hear yourself. The imam reads Al-Fatihah and the surah aloud in '
          'the two rakaats of Fajr and in the first two rakaats of Maghrib '
          'and Isha. Someone praying behind an imam does not recite the '
          'Quran and only follows him.',
      'المنفرد له أن يسرّ في كل صلاته بحيث يُسمع نفسه. ويجهر الإمام بالفاتحة '
          'والسورة في ركعتي الفجر وفي الأوليين من المغرب والعشاء. والمقتدي لا '
          'يقرأ خلف الإمام بل يتابعه.',
    ),
  ),
];
