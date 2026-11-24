import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/content/quran.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../../state/content_providers.dart';
import '../../state/quran_downloads.dart';
import '../widgets.dart';

/// Surahs kept on the phone for the chosen reciter.
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final reciter = reciterById(ref.watch(settingsProvider).quranReciter);
    final surahs = ref.watch(surahIndexProvider).value ?? const <SurahInfo>[];
    final downloads = ref.watch(quranDownloadsProvider).value;
    final controller = ref.read(quranDownloadsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l.offlineListening)),
      body: downloads == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: surahs.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return HintText(
                    l.offlineHint(
                      language == 'ar' ? reciter.arabicName : reciter.name,
                    ),
                  );
                }
                final surah = surahs[index - 1];
                final have = downloads.counts[surah.number] ?? 0;
                final running = downloads.running == surah.number;
                final complete = have >= surah.ayahCount;
                final String status;
                if (running) {
                  status = l.offlineProgress(have, surah.ayahCount);
                } else if (downloads.failed == surah.number) {
                  status = l.offlineFailed;
                } else if (complete) {
                  status = l.offlineSaved;
                } else if (have > 0) {
                  status = l.offlineProgress(have, surah.ayahCount);
                } else {
                  status = l.ayahCount(surah.ayahCount);
                }
                return ListTile(
                  title: Text(
                    '${surah.number}. ${surah.localizedName(language)}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status,
                        style: downloads.failed == surah.number && !running
                            ? TextStyle(color: scheme.error)
                            : null,
                      ),
                      if (running)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: LinearProgressIndicator(
                            value: have / surah.ayahCount,
                          ),
                        ),
                    ],
                  ),
                  trailing: running
                      ? IconButton(
                          tooltip: MaterialLocalizations.of(context).cancelButtonLabel,
                          icon: const Icon(Icons.close),
                          onPressed: controller.cancel,
                        )
                      : complete
                      ? IconButton(
                          tooltip: l.offlineDelete,
                          icon: Icon(Icons.check_circle, color: scheme.primary),
                          onPressed: () => controller.delete(surah.number),
                        )
                      : IconButton(
                          tooltip: l.offlineDownload,
                          icon: const Icon(Icons.download_outlined),
                          onPressed: downloads.running != null
                              ? null
                              : () => controller.download(surah.number),
                        ),
                );
              },
            ),
    );
  }
}
