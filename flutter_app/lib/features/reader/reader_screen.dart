import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/url_utils.dart';
import '../../l10n/app_localizations.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key, required this.url, this.title});

  final String url;
  final String? title;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  InAppWebViewController? _controller;
  final Set<String> _blockedHosts = {};
  double _progress = 0;
  bool _readerMode = true;

  @override
  void initState() {
    super.initState();
    _loadHosts();
  }

  Future<void> _loadHosts() async {
    final content = await rootBundle.loadString('assets/pgl.yoyo.org.txt');
    final hosts = content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toSet();
    if (mounted) setState(() => _blockedHosts.addAll(hosts));
  }

  bool _isBlocked(Uri uri) {
    final host = uri.host;
    if (host.isEmpty) return false;
    if (_blockedHosts.contains(host)) return true;
    for (final blocked in _blockedHosts) {
      if (host.endsWith('.$blocked')) return true;
    }
    return false;
  }

  Future<void> _applyReaderMode() async {
    if (!_readerMode || _controller == null) return;
    await _controller!.evaluateJavascript(
      source:
          '''
(function() {
  if (document.getElementById('materialistic-reader')) return;
  var candidate = document.querySelector('article') ||
      document.querySelector('main') ||
      document.querySelector('[role="main"]');
  if (!candidate) return;
  var content = candidate.innerHTML;
  document.head.innerHTML = '<meta name="viewport" content="width=device-width, initial-scale=1">';
  document.body.innerHTML = '<div id="materialistic-reader">' + content + '</div>';
  var style = document.createElement('style');
  style.textContent = `
    body { margin: 0; background: transparent; }
    #materialistic-reader { max-width: 720px; margin: 0 auto; padding: 20px 18px 48px;
      font-family: Georgia, serif; font-size: 18px; line-height: 1.65;
      color: ${_readerTextColor()}; }
    #materialistic-reader img, #materialistic-reader video, #materialistic-reader iframe {
      max-width: 100% !important; height: auto !important; }
    #materialistic-reader pre { overflow-x: auto; }
    #materialistic-reader a { color: ${_readerLinkColor()}; }
  `;
  document.head.appendChild(style);
})();
''',
    );
  }

  String _readerTextColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? '#EDE1D7'
        : '#1F1B16';
  }

  String _readerLinkColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? '#FF9A5C'
        : '#C2410C';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final url = Uri.tryParse(widget.url);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title?.isNotEmpty == true
              ? widget.title!
              : url?.host ?? l10n.reading,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: _readerMode ? l10n.original : l10n.openInReader,
            icon: Icon(_readerMode ? Icons.article : Icons.article_outlined),
            onPressed: () {
              setState(() => _readerMode = !_readerMode);
              _controller?.reload();
            },
          ),
          IconButton(
            tooltip: l10n.openBrowser,
            icon: const Icon(Icons.open_in_new),
            onPressed: () async {
              final parsed = parseHttpUrl(widget.url);
              if (parsed != null) {
                await launchUrl(parsed, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
        bottom: _progress < 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(value: _progress),
              )
            : null,
      ),
      body: url == null
          ? Center(child: Text(l10n.invalidUrl))
          : InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useShouldInterceptRequest: true,
                supportZoom: true,
                useWideViewPort: true,
                loadWithOverviewMode: true,
                transparentBackground: false,
                allowsBackForwardNavigationGestures: true,
              ),
              onWebViewCreated: (controller) => _controller = controller,
              shouldInterceptRequest: (controller, request) async {
                if (_isBlocked(request.url)) {
                  return WebResourceResponse(
                    data: Uint8List(0),
                    contentType: 'text/plain',
                    statusCode: 204,
                  );
                }
                return null;
              },
              onProgressChanged: (controller, progress) {
                if (mounted) setState(() => _progress = progress / 100);
              },
              onLoadStop: (controller, url) => _applyReaderMode(),
            ),
    );
  }
}
