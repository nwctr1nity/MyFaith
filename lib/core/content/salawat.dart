/// A salawat formula with its source and translations.
class Salawat {
  const Salawat({
    required this.arabic,
    required this.russian,
    required this.english,
    this.bukhariNumber,
  });

  final String arabic;
  final String russian;
  final String english;

  /// Number in Sahih al-Bukhari when the wording is narrated there.
  final int? bukhariNumber;

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

/// Wordings 1, 4 and 5 are copied from Sahih al-Bukhari (3370, 3369, 6358).
const salawatList = <Salawat>[
  Salawat(
    arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ، وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى '
        'إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى '
        'مُحَمَّدٍ، وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ، وَعَلَى آلِ '
        'إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
    russian: 'О Аллах, благослови Мухаммада и семейство Мухаммада, как Ты '
        'благословил Ибрахима и семейство Ибрахима, поистине, Ты — Достойный '
        'хвалы, Славный. О Аллах, пошли благодать Мухаммаду и семейству '
        'Мухаммада, как Ты послал её Ибрахиму и семейству Ибрахима, поистине, '
        'Ты — Достойный хвалы, Славный.',
    english: 'O Allah, send prayers upon Muhammad and the family of Muhammad, '
        'as You sent prayers upon Ibrahim and the family of Ibrahim; You are '
        'Praiseworthy, Glorious. O Allah, bless Muhammad and the family of '
        'Muhammad, as You blessed Ibrahim and the family of Ibrahim; You are '
        'Praiseworthy, Glorious.',
    bukhariNumber: 3370,
  ),
  Salawat(
    arabic: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
    russian: 'О Аллах, благослови и приветствуй нашего пророка Мухаммада.',
    english: 'O Allah, send prayers and peace upon our Prophet Muhammad.',
  ),
  Salawat(
    arabic: 'صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ',
    russian: 'Да благословит его Аллах и приветствует.',
    english: 'May Allah send prayers and peace upon him.',
  ),
  Salawat(
    arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَأَزْوَاجِهِ وَذُرِّيَّتِهِ، كَمَا صَلَّيْتَ عَلَى آلِ '
        'إِبْرَاهِيمَ، وَبَارِكْ عَلَى مُحَمَّدٍ وَأَزْوَاجِهِ وَذُرِّيَّتِهِ، كَمَا بَارَكْتَ عَلَى آلِ '
        'إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
    russian: 'О Аллах, благослови Мухаммада, его жён и его потомство, как Ты '
        'благословил семейство Ибрахима, и пошли благодать Мухаммаду, его '
        'жёнам и его потомству, как Ты послал её семейству Ибрахима, '
        'поистине, Ты — Достойный хвалы, Славный.',
    english: 'O Allah, send prayers upon Muhammad, his wives and his '
        'offspring, as You sent prayers upon the family of Ibrahim, and bless '
        'Muhammad, his wives and his offspring, as You blessed the family of '
        'Ibrahim; You are Praiseworthy, Glorious.',
    bukhariNumber: 3369,
  ),
  Salawat(
    arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ عَبْدِكَ وَرَسُولِكَ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ، '
        'وَبَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَآلِ '
        'إِبْرَاهِيمَ',
    russian: 'О Аллах, благослови Мухаммада, Твоего раба и Твоего посланника, '
        'как Ты благословил Ибрахима, и пошли благодать Мухаммаду и '
        'семейству Мухаммада, как Ты послал её Ибрахиму и семейству Ибрахима.',
    english: 'O Allah, send prayers upon Muhammad, Your servant and Your '
        'messenger, as You sent prayers upon Ibrahim, and bless Muhammad and '
        'the family of Muhammad, as You blessed Ibrahim and the family of '
        'Ibrahim.',
    bukhariNumber: 6358,
  ),
];
