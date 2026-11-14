import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'features/shell.dart';
import 'features/theme.dart';
import 'l10n/app_localizations.dart';
import 'state/app_settings.dart';

class MuslimApp extends ConsumerWidget {
  const MuslimApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode =
        ref.watch(settingsProvider.select((s) => s.languageCode));
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));
    return MaterialApp(
      title: 'MyFaith',
      locale: languageCode == null ? null : Locale(languageCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      themeMode: themeMode,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: const AppShell(),
    );
  }
}
