import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../hadith/hadith_screen.dart';
import '../names/names_screen.dart';
import '../../core/content/hadith.dart';
import '../quran/bookmarks_screen.dart';
import '../settings/settings_screen.dart';
import 'alarms_screen.dart';
import 'notifications_screen.dart';
import 'sources_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;

    void open(Widget screen) =>
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => screen));

    return Scaffold(
      appBar: AppBar(title: Text(l.navMore)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _Item(
                  icon: Icons.notifications_active_outlined,
                  title: l.notifications,
                  subtitle: l.notificationsHint,
                  onTap: () => open(const NotificationsScreen()),
                ),
                _Item(
                  icon: Icons.alarm,
                  title: l.alarms,
                  subtitle: l.alarmsHint,
                  onTap: () => open(const AlarmsScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _Item(
                  icon: Icons.format_quote,
                  title: l.hadithOfDay,
                  onTap: () {
                    final now = DateTime.now();
                    open(
                      HadithScreen(
                        initialDay: dayNumber(now.year, now.month, now.day),
                      ),
                    );
                  },
                ),
                _Item(
                  icon: Icons.auto_awesome_outlined,
                  title: l.names99,
                  subtitle: l.names99Hint,
                  onTap: () => open(const NamesScreen()),
                ),
                _Item(
                  icon: Icons.bookmarks_outlined,
                  title: l.bookmarks,
                  onTap: () => open(const BookmarksScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _Item(
                  icon: Icons.tune,
                  title: l.settings,
                  subtitle: l.prayerSettingsHint,
                  onTap: () => open(const SettingsScreen()),
                ),
                _Item(
                  icon: Icons.info_outline,
                  title: l.sources,
                  onTap: () => open(const SourcesScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: scheme.primary),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: Icon(
        Directionality.of(context) == TextDirection.rtl
            ? Icons.chevron_left
            : Icons.chevron_right,
        color: scheme.outline,
      ),
      onTap: onTap,
    );
  }
}
