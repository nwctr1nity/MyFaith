import 'dart:convert';
import 'dart:typed_data';

/// The whole of the user's data fits in the settings map: the place, the
/// calculation, bookmarks, counters and goals. A backup is that map in a
/// file, with a header that says what the file is.
const backupFormat = 'myfaith-backup';

Uint8List encodeBackup(Map<String, Object?> settings, {DateTime? now}) {
  final text = const JsonEncoder.withIndent('  ').convert({
    'format': backupFormat,
    'version': 1,
    'saved': (now ?? DateTime.now()).toUtc().toIso8601String(),
    'settings': settings,
  });
  return Uint8List.fromList(utf8.encode(text));
}

/// The settings map from a backup file, or null when the file is not one.
Map<String, Object?>? decodeBackup(List<int> bytes) {
  try {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, Object?>) return null;
    if (decoded['format'] != backupFormat) return null;
    final settings = decoded['settings'];
    return settings is Map<String, Object?> ? settings : null;
  } on FormatException {
    return null;
  }
}
