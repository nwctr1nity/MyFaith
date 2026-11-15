/// A salawat formula with its source and translations.
class Salawat {
  const Salawat({
    required this.arabic,
    required this.latin,
    required this.cyrillic,
    required this.russian,
    required this.english,
    this.bukhariNumber,
  });

  final String arabic;
  final String latin;
  final String cyrillic;
  final String russian;
  final String english;

  /// Number in Sahih al-Bukhari when the wording is narrated there.
  final int? bukhariNumber;

  /// How it is read, in the letters of the interface language.
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
}

/// From the shortest to the longest, so that the first cards show the whole
/// text with its translation at a glance. The last three wordings are copied
/// from Sahih al-Bukhari (6358, 3369, 3370).
const salawatList = <Salawat>[
  Salawat(
    arabic: 'صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ',
    latin: "Sallallahu ‘alayhi wa sallam",
    cyrillic: "Салляллаху ‘алейхи ва саллям",
    russian: 'Да благословит его Аллах и приветствует.',
    english: 'May Allah send prayers and peace upon him.',
  ),
  Salawat(
    arabic: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
    latin: "Allahumma salli wa sallim ‘ala nabiyyina Muhammad",
    cyrillic: "Аллахумма салли ва саллим ‘аля набиййина Мухаммад",
    russian: 'О Аллах, благослови и приветствуй нашего пророка Мухаммада.',
    english: 'O Allah, send prayers and peace upon our Prophet Muhammad.',
  ),
  Salawat(
    arabic:
        'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ عَبْدِكَ وَرَسُولِكَ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ، '
        'وَبَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَآلِ '
        'إِبْرَاهِيمَ',
    latin: "Allahumma salli ‘ala Muhammadin ‘abdika wa rasulika, kama sallayta ‘ala Ibrahim, wa barik ‘ala Muhammadin wa ‘ala ali Muhammad, kama barakta ‘ala Ibrahima wa ali Ibrahim",
    cyrillic: "Аллахумма салли ‘аля Мухаммадин ‘абдика ва расулика, кама салляйта ‘аля Ибрахим, ва барик ‘аля Мухаммадин ва ‘аля али Мухаммад, кама баракта ‘аля Ибрахима ва али Ибрахим",
    russian:
        'О Аллах, благослови Мухаммада, Твоего раба и Твоего посланника, '
        'как Ты благословил Ибрахима, и пошли благодать Мухаммаду и '
        'семейству Мухаммада, как Ты послал её Ибрахиму и семейству Ибрахима.',
    english:
        'O Allah, send prayers upon Muhammad, Your servant and Your '
        'messenger, as You sent prayers upon Ibrahim, and bless Muhammad and '
        'the family of Muhammad, as You blessed Ibrahim and the family of '
        'Ibrahim.',
    bukhariNumber: 6358,
  ),
  Salawat(
    arabic:
        'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَأَزْوَاجِهِ وَذُرِّيَّتِهِ، كَمَا صَلَّيْتَ عَلَى آلِ '
        'إِبْرَاهِيمَ، وَبَارِكْ عَلَى مُحَمَّدٍ وَأَزْوَاجِهِ وَذُرِّيَّتِهِ، كَمَا بَارَكْتَ عَلَى آلِ '
        'إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
    latin: "Allahumma salli ‘ala Muhammadin wa azwajihi wa dhurriyyatihi, kama sallayta ‘ala ali Ibrahim, wa barik ‘ala Muhammadin wa azwajihi wa dhurriyyatihi, kama barakta ‘ala ali Ibrahim, innaka Hamidun Majid",
    cyrillic: "Аллахумма салли ‘аля Мухаммадин ва азваджихи ва зурриййатихи, кама салляйта ‘аля али Ибрахим, ва барик ‘аля Мухаммадин ва азваджихи ва зурриййатихи, кама баракта ‘аля али Ибрахим, иннака Хамидун Маджид",
    russian:
        'О Аллах, благослови Мухаммада, его жён и его потомство, как Ты '
        'благословил семейство Ибрахима, и пошли благодать Мухаммаду, его '
        'жёнам и его потомству, как Ты послал её семейству Ибрахима, '
        'поистине, Ты — Достойный хвалы, Славный.',
    english:
        'O Allah, send prayers upon Muhammad, his wives and his '
        'offspring, as You sent prayers upon the family of Ibrahim, and bless '
        'Muhammad, his wives and his offspring, as You blessed the family of '
        'Ibrahim; You are Praiseworthy, Glorious.',
    bukhariNumber: 3369,
  ),
  Salawat(
    arabic:
        'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ، وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى '
        'إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى '
        'مُحَمَّدٍ، وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ، وَعَلَى آلِ '
        'إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
    latin: "Allahumma salli ‘ala Muhammadin wa ‘ala ali Muhammad, kama sallayta ‘ala Ibrahima wa ‘ala ali Ibrahim, innaka Hamidun Majid. Allahumma barik ‘ala Muhammadin wa ‘ala ali Muhammad, kama barakta ‘ala Ibrahima wa ‘ala ali Ibrahim, innaka Hamidun Majid",
    cyrillic: "Аллахумма салли ‘аля Мухаммадин ва ‘аля али Мухаммад, кама салляйта ‘аля Ибрахима ва ‘аля али Ибрахим, иннака Хамидун Маджид. Аллахумма барик ‘аля Мухаммадин ва ‘аля али Мухаммад, кама баракта ‘аля Ибрахима ва ‘аля али Ибрахим, иннака Хамидун Маджид",
    russian:
        'О Аллах, благослови Мухаммада и семейство Мухаммада, как Ты '
        'благословил Ибрахима и семейство Ибрахима, поистине, Ты — Достойный '
        'хвалы, Славный. О Аллах, пошли благодать Мухаммаду и семейству '
        'Мухаммада, как Ты послал её Ибрахиму и семейству Ибрахима, поистине, '
        'Ты — Достойный хвалы, Славный.',
    english:
        'O Allah, send prayers upon Muhammad and the family of Muhammad, '
        'as You sent prayers upon Ibrahim and the family of Ibrahim; You are '
        'Praiseworthy, Glorious. O Allah, bless Muhammad and the family of '
        'Muhammad, as You blessed Ibrahim and the family of Ibrahim; You are '
        'Praiseworthy, Glorious.',
    bukhariNumber: 3370,
  ),
];
