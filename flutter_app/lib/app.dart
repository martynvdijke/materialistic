import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
import 'core/router.dart';
import 'core/settings/settings_controller.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class MaterialisticApp extends ConsumerWidget {
  const MaterialisticApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(settingsProvider);
    final settings = controller.settings;
    final themeMode = switch (settings.theme) {
      ThemeStyle.system => ThemeMode.system,
      ThemeStyle.light ||
      ThemeStyle.sepia ||
      ThemeStyle.green ||
      ThemeStyle.solarized =>
        settings.autoDayNight ? ThemeMode.system : ThemeMode.light,
      _ => ThemeMode.dark,
    };

    return MaterialApp.router(
      title: 'Materialistic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(
        style: _lightVariant(settings.theme),
        font: settings.font,
      ),
      darkTheme: AppTheme.build(
        style: _darkVariant(settings.theme),
        font: settings.font,
      ),
      themeMode: themeMode,
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(settings.textSize.scale),
          ),
          child: _DeepLinkListener(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }

  ThemeStyle _lightVariant(ThemeStyle style) => switch (style) {
    ThemeStyle.dark ||
    ThemeStyle.black ||
    ThemeStyle.solarizedDark => ThemeStyle.light,
    _ => style,
  };

  ThemeStyle _darkVariant(ThemeStyle style) => switch (style) {
    ThemeStyle.light || ThemeStyle.sepia || ThemeStyle.green => ThemeStyle.dark,
    ThemeStyle.solarized => ThemeStyle.solarizedDark,
    _ => style,
  };
}

class _DeepLinkListener extends ConsumerStatefulWidget {
  const _DeepLinkListener({required this.child});

  final Widget child;

  @override
  ConsumerState<_DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends ConsumerState<_DeepLinkListener> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  @override
  void initState() {
    super.initState();
    _appLinks.getInitialLink().then(_handle).catchError((_) {});
    _subscription = _appLinks.uriLinkStream.listen(_handle, onError: (_) {});
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _handle(Uri? uri) {
    if (uri == null || !mounted) return;
    final router = ref.read(routerProvider);

    if (uri.host == 'news.ycombinator.com' && uri.path == '/item') {
      final id = uri.queryParameters['id'];
      if (id != null) router.push('/item/$id');
      return;
    }
    if (uri.host == 'news.ycombinator.com' && uri.path == '/user') {
      final id = uri.queryParameters['id'];
      if (id != null) router.push('/user/$id');
      return;
    }
    if (uri.scheme == 'materialistic') {
      if (uri.host == 'item' && uri.pathSegments.isNotEmpty) {
        router.push('/item/${uri.pathSegments.first}');
      } else if (uri.host == 'user' && uri.pathSegments.isNotEmpty) {
        router.push('/user/${uri.pathSegments.first}');
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
