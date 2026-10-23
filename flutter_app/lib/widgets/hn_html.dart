import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import '../core/utils/url_utils.dart';

/// Renders the small HTML subset returned by the Hacker News API.
class HnHtml extends StatelessWidget {
  const HnHtml({super.key, required this.html, this.fontSize});

  final String html;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodySize = fontSize ?? theme.textTheme.bodyMedium?.fontSize ?? 14;
    return Html(
      data: html,
      style: {
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          color: theme.colorScheme.onSurface,
          fontSize: FontSize(bodySize),
          lineHeight: LineHeight.number(1.45),
        ),
        'p': Style(margin: Margins.only(top: 8, bottom: 8)),
        'a': Style(
          color: theme.colorScheme.primary,
          textDecoration: TextDecoration.none,
        ),
        'pre': Style(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          padding: HtmlPaddings.all(8),
          fontFamily: 'monospace',
        ),
        'code': Style(fontFamily: 'monospace'),
        'blockquote': Style(
          margin: Margins.only(left: 8),
          padding: HtmlPaddings.only(left: 8),
          border: Border(
            left: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
      },
      onLinkTap: (url, attributes, element) async {
        if (url == null) return;
        final resolved = url.startsWith('/')
            ? '${AppConstants.hnWebUrl}$url'
            : url;
        final uri = parseHttpUrl(resolved);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        }
      },
    );
  }
}
