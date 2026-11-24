import 'package:share_plus/share_plus.dart';

/// The text handed to other apps: the parts, then the app's name.
String shareText(Iterable<String?> parts) => [
  for (final p in parts)
    if (p != null && p.trim().isNotEmpty) p.trim(),
  'MyFaith',
].join('\n\n');

/// Opens the system sheet for sending [text] to another app.
Future<void> shareOut(String text) =>
    SharePlus.instance.share(ShareParams(text: text));
