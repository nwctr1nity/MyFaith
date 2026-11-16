import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:file_picker/file_picker.dart';

import '../../services/backup.dart';
import '../../state/update_provider.dart';
import '../../core/prayer/prayer_calculator.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../labels.dart';
import '../location/city_picker_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _languages = <String, String>{
    'ru': 'Русский',
    'en': 'English',
    'ar': 'العربية',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final version = ref.watch(installedVersionProvider).value;

    String themeName(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.system:
          return l.themeSystem;
        case ThemeMode.light:
          return l.themeLight;
        case ThemeMode.dark:
          return l.themeDark;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.place_outlined),
            title: Text(l.location),
            subtitle: Text(settings.place?.name ?? l.chooseCity),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CityPickerScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.language),
            subtitle: Text(
              _languages[settings.languageCode] ?? l.languageSystem,
            ),
            onTap: () => _pick<String?>(
              context,
              title: l.language,
              selected: settings.languageCode,
              options: {
                null: l.languageSystem,
                for (final e in _languages.entries) e.key: e.value,
              },
              onSelected: controller.setLanguage,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(l.theme),
            subtitle: Text(themeName(settings.themeMode)),
            onTap: () => _pick<ThemeMode>(
              context,
              title: l.theme,
              selected: settings.themeMode,
              options: {for (final m in ThemeMode.values) m: themeName(m)},
              onSelected: controller.setThemeMode,
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.system_update_outlined),
            title: Text(l.checkUpdates),
            subtitle: Text(
              version == null
                  ? l.checkUpdatesHint
                  : '${l.checkUpdatesHint} ${l.versionLabel(version)}',
            ),
            value: settings.checkUpdates,
            onChanged: (v) => controller.setValue('updCheck', v),
          ),
          _SectionHeader(l.calculation),
          ListTile(
            title: Text(l.method),
            subtitle: Text(
              '${methodName(l, settings.method)}\n'
              '${methodDetails(l, settings.method)}',
            ),
            isThreeLine: true,
            onTap: () => _pick<CalcMethod>(
              context,
              title: l.method,
              selected: settings.method,
              options: {
                for (final m in CalcMethod.values) m: methodName(l, m),
              },
              subtitles: {
                for (final m in CalcMethod.values) m: methodDetails(l, m),
              },
              onSelected: controller.setMethod,
            ),
          ),
          ListTile(
            title: Text(l.asrMadhab),
            subtitle: Text(
              settings.madhab == AsrMadhab.hanafi
                  ? l.madhabHanafi
                  : l.madhabShafi,
            ),
            onTap: () => _pick<AsrMadhab>(
              context,
              title: l.asrMadhab,
              selected: settings.madhab,
              options: {
                AsrMadhab.shafi: l.madhabShafi,
                AsrMadhab.hanafi: l.madhabHanafi,
              },
              onSelected: controller.setMadhab,
            ),
          ),
          ListTile(
            title: Text(l.hijriAdjustment),
            subtitle: Text(
              '${l.daysShift(_signed(settings.hijriAdjustment))}\n'
              '${l.hijriAdjustmentHint}',
            ),
            isThreeLine: true,
            onTap: () => _pick<int>(
              context,
              title: l.hijriAdjustment,
              selected: settings.hijriAdjustment,
              options: {
                for (var d = -2; d <= 2; d++) d: l.daysShift(_signed(d)),
              },
              onSelected: (d) => controller.setValue('hijriAdj', d),
            ),
          ),
          _SectionHeader(l.adjustments),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
            child: Text(
              l.adjustmentsHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          for (final slot in PrayerSlot.values)
            _AdjustmentRow(
              name: prayerName(l, slot),
              minutes: settings.adjustments[slot] ?? 0,
              label: (v) => l.minutesShort(v),
              onChange: (delta) => controller.changeAdjustment(slot, delta),
            ),
          _SectionHeader(l.backup),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: Text(l.backupSave),
            subtitle: Text(l.backupSaveHint),
            onTap: () => _saveBackup(context, settings),
          ),
          ListTile(
            leading: const Icon(Icons.settings_backup_restore),
            title: Text(l.backupRestore),
            subtitle: Text(l.backupRestoreHint),
            onTap: () => _restoreBackup(context, controller),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static Future<void> _saveBackup(
    BuildContext context,
    AppSettings settings,
  ) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    try {
      final saved = await FilePicker.saveFile(
        fileName:
            'myfaith-${now.year}-${two(now.month)}-${two(now.day)}.json',
        bytes: encodeBackup(settings.toJson(), now: now),
        mimeType: 'application/json',
      );
      if (saved != null) {
        messenger.showSnackBar(SnackBar(content: Text(l.backupSaved)));
      }
    } on Exception catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  static Future<void> _restoreBackup(
    BuildContext context,
    SettingsController controller,
  ) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final files = await FilePicker.pickFiles();
      if (files.isEmpty) return;
      final settings = decodeBackup(await files.first.readAsBytes());
      if (settings == null) {
        messenger.showSnackBar(SnackBar(content: Text(l.backupNotOurs)));
        return;
      }
      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.backupRestore),
          content: Text(l.backupRestoreConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l.backupRestoreAction),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      controller.restore(settings);
      messenger.showSnackBar(SnackBar(content: Text(l.backupRestored)));
    } on Exception catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  static String _signed(int n) => n > 0 ? '+$n' : '$n';

  Future<void> _pick<T>(
    BuildContext context, {
    required String title,
    required T selected,
    required Map<T, String> options,
    Map<T, String> subtitles = const {},
    required void Function(T) onSelected,
  }) async {
    final entry = await showModalBottomSheet<MapEntry<T, String>>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: options.length > 6 ? 0.8 : 0.5,
        builder: (context, scroll) => ListView(
          controller: scroll,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            for (final e in options.entries)
              ListTile(
                title: Text(e.value),
                subtitle:
                    subtitles[e.key] == null ? null : Text(subtitles[e.key]!),
                trailing: e.key == selected ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(e),
              ),
          ],
        ),
      ),
    );
    if (entry != null) onSelected(entry.key);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall
            ?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}

class _AdjustmentRow extends StatelessWidget {
  const _AdjustmentRow({
    required this.name,
    required this.minutes,
    required this.label,
    required this.onChange,
  });

  final String name;
  final int minutes;
  final String Function(String) label;
  final void Function(int delta) onChange;

  @override
  Widget build(BuildContext context) {
    final sign = minutes > 0 ? '+' : (minutes < 0 ? '−' : '');
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 4, 0),
      child: Row(
        children: [
          Expanded(child: Text(name)),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: minutes > -SettingsController.maxAdjustmentMinutes
                ? () => onChange(-1)
                : null,
          ),
          SizedBox(
            width: 72,
            child: Text(
              label('$sign${minutes.abs()}'),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: minutes < SettingsController.maxAdjustmentMinutes
                ? () => onChange(1)
                : null,
          ),
        ],
      ),
    );
  }
}
