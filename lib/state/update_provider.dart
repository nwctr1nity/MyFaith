import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/update_service.dart';
import 'app_settings.dart';

final updateServiceProvider =
    Provider<UpdateService>((ref) => GitHubUpdateService());

/// The newer version to offer, or null. Asked once per app start, and only
/// when the user has left the check on.
final appUpdateProvider = FutureProvider<AppUpdate?>((ref) async {
  final enabled = ref.watch(settingsProvider.select((s) => s.checkUpdates));
  if (!enabled) return null;
  final update = await ref.watch(updateServiceProvider).check();
  if (update == null) return null;
  final skipped = ref.watch(settingsProvider.select((s) => s.skippedUpdate));
  return update.version == skipped ? null : update;
});

final installedVersionProvider = FutureProvider<String?>((ref) async {
  try {
    return await ref.watch(updateServiceProvider).installedVersion();
  } on Object {
    return null;
  }
});
