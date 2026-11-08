import 'package:flutter/services.dart';

/// Receives Android ACTION_SEND text from the native activity.
class ShareIntentService {
  static const _channel = MethodChannel(
    'xyz.vandijke.materialistic/share_intent',
  );

  static Future<String?> initialText() async {
    try {
      return await _channel.invokeMethod<String>('getInitialShare');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  static void listen(void Function(String text) onText) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'sharedText' && call.arguments is String) {
        onText(call.arguments as String);
      }
    });
  }

  static ({String? url, String? text, String? title}) parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return (url: null, text: null, title: null);
    final match = RegExp(r'https?://\S+').firstMatch(trimmed);
    if (match == null) {
      return (url: null, text: trimmed, title: null);
    }
    final url = match.group(0)!;
    final title = trimmed.replaceFirst(url, '').trim();
    return (url: url, text: null, title: title.isEmpty ? null : title);
  }
}
