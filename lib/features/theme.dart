import 'package:material_ui/material_ui.dart';

const _seed = Color(0xFF0F6B55);

/// Font family of the bundled Amiri Quran face, for Arabic scripture.
const quranFont = 'AmiriQuran';

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.primaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant),
  );
}

/// The green gradient behind the next-prayer card.
LinearGradient heroGradient(ColorScheme scheme) {
  final dark = scheme.brightness == Brightness.dark;
  return LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: dark
        ? const [Color(0xFF0B4A3B), Color(0xFF123A4A)]
        : const [Color(0xFF0F6B55), Color(0xFF1C8A6B)],
  );
}

const onHero = Color(0xFFFFFFFF);
const onHeroMuted = Color(0xCCFFFFFF);

/// Arabic scripture style. Line height is generous because the Uthmani
/// marks stack above and below the letters.
TextStyle quranTextStyle(double size, Color color) => TextStyle(
      fontFamily: quranFont,
      fontSize: size,
      height: 2.0,
      color: color,
    );
