import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';

/// A published version of the app that is newer than the installed one.
class AppUpdate {
  const AppUpdate({required this.version, required this.url});

  /// Like `1.2.0`.
  final String version;

  /// The APK when the release has one, otherwise the release page.
  final String url;
}

/// `1.10.0` is newer than `1.9.3`. Anything unreadable counts as zero.
int compareVersions(String a, String b) {
  List<int> parts(String v) => [
    for (final p in v.replaceFirst(RegExp('^v'), '').split('+').first.split('.'))
      int.tryParse(p) ?? 0,
  ];
  final x = parts(a), y = parts(b);
  for (var i = 0; i < 3; i++) {
    final d = (i < x.length ? x[i] : 0) - (i < y.length ? y[i] : 0);
    if (d != 0) return d;
  }
  return 0;
}

/// Picks the update out of GitHub's "latest release" answer, or null when
/// the installed version is already that one.
AppUpdate? updateFromRelease(Map<String, Object?> release, String installed) {
  final tag = release['tag_name'];
  if (tag is! String || compareVersions(tag, installed) <= 0) return null;
  var url = release['html_url'] as String?;
  final assets = release['assets'];
  if (assets is List) {
    for (final a in assets) {
      if (a is Map && '${a['name']}'.endsWith('.apk')) {
        url = a['browser_download_url'] as String? ?? url;
        break;
      }
    }
  }
  if (url == null) return null;
  return AppUpdate(version: tag.replaceFirst(RegExp('^v'), ''), url: url);
}

/// Looks for a newer release. Tests replace it with a fake.
abstract class UpdateService {
  /// The installed version, like `1.1.0`.
  Future<String> installedVersion();

  /// Null when there is nothing newer or the check could not be made.
  Future<AppUpdate?> check();
}

/// The app is not in a store, so releases on GitHub are where a newer
/// version appears.
class GitHubUpdateService implements UpdateService {
  static const _latest =
      'https://api.github.com/repos/nwctr1nity/MyFaith/releases/latest';

  @override
  Future<String> installedVersion() async =>
      (await PackageInfo.fromPlatform()).version;

  @override
  Future<AppUpdate?> check() async {
    if (kIsWeb) return null;
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final installed = await installedVersion();
      final request = await client.getUrl(Uri.parse(_latest));
      request.headers
        ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
        ..set(HttpHeaders.userAgentHeader, 'MyFaith');
      final response =
          await request.close().timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return null;
      final body = await utf8.decodeStream(response);
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, Object?>) return null;
      return updateFromRelease(decoded, installed);
    } on Object {
      // No connection, or the answer was not what we expect.
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
