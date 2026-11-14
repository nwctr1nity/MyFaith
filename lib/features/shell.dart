import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../state/notification_sync.dart';
import 'home/home_screen.dart';
import 'more/more_screen.dart';
import 'qibla/qibla_screen.dart';
import 'quran/quran_screen.dart';
import 'salawat/salawat_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  int _index = 0;
  final _visited = <int>{0};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Replan on launch: the schedule only reaches a few days ahead.
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  /// Asks for the notification permission as soon as the app opens: an
  /// adhan app is of little use without it. Android shows its dialog only
  /// while the permission is still undecided.
  Future<void> _start() async {
    final service = ref.read(notificationServiceProvider);
    try {
      if (!(await service.permissions()).notifications) {
        await service.requestNotifications();
      }
    } on Exception {
      // The notifications screen reports what is missing.
    }
    if (mounted) ref.read(notificationSyncProvider).schedule();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(notificationSyncProvider).schedule();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Keeps the sync alive and listening to settings changes.
    ref.watch(notificationSyncProvider);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        // A tab is built on its first visit and then kept, so it holds
        // its scroll position without slowing down the launch.
        children: [
          const HomeScreen(),
          _visited.contains(1) ? const QuranScreen() : const SizedBox(),
          // The compass is only read while its tab is open.
          _visited.contains(2)
              ? QiblaScreen(active: _index == 2)
              : const SizedBox(),
          _visited.contains(3) ? const SalawatScreen() : const SizedBox(),
          _visited.contains(4) ? const MoreScreen() : const SizedBox(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() {
          _index = i;
          _visited.add(i);
        }),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.access_time),
            selectedIcon: const Icon(Icons.access_time_filled),
            label: l.navPrayer,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: l.navQuran,
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore),
            label: l.navQibla,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: l.navSalawat,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            label: l.navMore,
          ),
        ],
      ),
    );
  }
}
