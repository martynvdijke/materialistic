import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../settings/settings_controller.dart';

bool isHttpUrl(String? value) {
  final uri = Uri.tryParse(value ?? '');
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
}

Uri? parseHttpUrl(String? value) {
  if (!isHttpUrl(value)) return null;
  return Uri.parse(value!);
}

String normalizeUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return trimmed;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  return 'https://$trimmed';
}

Future<bool> openExternal(String? url) async {
  final uri = parseHttpUrl(url);
  if (uri == null) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<bool> openBrowser(
  BuildContext context,
  String? url, {
  required AppSettings settings,
}) async {
  final uri = parseHttpUrl(url);
  if (uri == null) return false;
  return launchUrl(
    uri,
    mode: settings.externalBrowser
        ? LaunchMode.externalApplication
        : LaunchMode.inAppBrowserView,
  );
}
