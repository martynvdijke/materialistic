import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/feed/feed_type.dart';

enum ThemeStyle {
  system('system'),
  light('light'),
  dark('dark'),
  black('black'),
  sepia('sepia'),
  green('green'),
  solarized('solarized'),
  solarizedDark('solarized_dark');

  const ThemeStyle(this.value);
  final String value;

  static ThemeStyle fromValue(String? value) => values.firstWhere(
    (theme) => theme.value == value,
    orElse: () => ThemeStyle.light,
  );
}

enum AppFont {
  system('', null),
  droidSans('DroidSans.ttf', 'Droid Sans'),
  droidSerif('DroidSerif.ttf', 'Droid Serif'),
  libreBaskerville('LibreBaskerville-Regular.ttf', 'Libre Baskerville'),
  robotoSlab('RobotoSlab-Regular.ttf', 'Roboto Slab');

  const AppFont(this.value, this.family);
  final String value;
  final String? family;

  static AppFont fromValue(String? value) => values.firstWhere(
    (font) => font.value == value,
    orElse: () => AppFont.system,
  );
}

enum TextSize {
  extraSmall(-1, 0.85),
  small(0, 0.95),
  normal(1, 1.0),
  large(2, 1.15),
  extraLarge(3, 1.3);

  const TextSize(this.value, this.scale);
  final int value;
  final double scale;

  static TextSize fromValue(int? value) => values.firstWhere(
    (size) => size.value == value,
    orElse: () => TextSize.normal,
  );
}

enum LaunchScreen {
  top('top'),
  best('best'),
  popular('popular'),
  newest('new'),
  show('show'),
  ask('ask'),
  jobs('jobs'),
  favorites('saved'),
  last('last');

  const LaunchScreen(this.value);
  final String value;

  FeedType? get feedType => switch (this) {
    LaunchScreen.top => FeedType.top,
    LaunchScreen.best => FeedType.best,
    LaunchScreen.popular => FeedType.popular,
    LaunchScreen.newest => FeedType.newest,
    LaunchScreen.show => FeedType.show,
    LaunchScreen.ask => FeedType.ask,
    LaunchScreen.jobs => FeedType.jobs,
    LaunchScreen.favorites => null,
    LaunchScreen.last => null,
  };

  static LaunchScreen fromValue(String? value) => values.firstWhere(
    (screen) => screen.value == value,
    orElse: () => LaunchScreen.top,
  );
}

@immutable
class AppSettings {
  const AppSettings({
    this.theme = ThemeStyle.light,
    this.autoDayNight = false,
    this.textSize = TextSize.normal,
    this.font = AppFont.system,
    this.launchScreen = LaunchScreen.top,
    this.externalBrowser = false,
    this.colorCode = true,
    this.threadIndicator = true,
    this.swipeActions = true,
    this.autoMarkRead = true,
    this.lazyLoad = true,
    this.popularWindow = PopularWindow.day,
  });

  final ThemeStyle theme;
  final bool autoDayNight;
  final TextSize textSize;
  final AppFont font;
  final LaunchScreen launchScreen;
  final bool externalBrowser;
  final bool colorCode;
  final bool threadIndicator;
  final bool swipeActions;
  final bool autoMarkRead;
  final bool lazyLoad;
  final PopularWindow popularWindow;

  AppSettings copyWith({
    ThemeStyle? theme,
    bool? autoDayNight,
    TextSize? textSize,
    AppFont? font,
    LaunchScreen? launchScreen,
    bool? externalBrowser,
    bool? colorCode,
    bool? threadIndicator,
    bool? swipeActions,
    bool? autoMarkRead,
    bool? lazyLoad,
    PopularWindow? popularWindow,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      autoDayNight: autoDayNight ?? this.autoDayNight,
      textSize: textSize ?? this.textSize,
      font: font ?? this.font,
      launchScreen: launchScreen ?? this.launchScreen,
      externalBrowser: externalBrowser ?? this.externalBrowser,
      colorCode: colorCode ?? this.colorCode,
      threadIndicator: threadIndicator ?? this.threadIndicator,
      swipeActions: swipeActions ?? this.swipeActions,
      autoMarkRead: autoMarkRead ?? this.autoMarkRead,
      lazyLoad: lazyLoad ?? this.lazyLoad,
      popularWindow: popularWindow ?? this.popularWindow,
    );
  }
}

/// Reads and persists preferences using the same keys as the native app.
class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs) : _settings = _load(_prefs);

  final SharedPreferences _prefs;
  AppSettings _settings;

  AppSettings get settings => _settings;

  ThemeStyle effectiveTheme(Brightness platformBrightness) {
    if (_settings.theme == ThemeStyle.system) {
      return platformBrightness == Brightness.dark
          ? ThemeStyle.dark
          : ThemeStyle.light;
    }
    if (_settings.autoDayNight &&
        platformBrightness == Brightness.dark &&
        (_settings.theme == ThemeStyle.light ||
            _settings.theme == ThemeStyle.sepia ||
            _settings.theme == ThemeStyle.green ||
            _settings.theme == ThemeStyle.solarized)) {
      return switch (_settings.theme) {
        ThemeStyle.sepia => ThemeStyle.sepia,
        ThemeStyle.green => ThemeStyle.green,
        ThemeStyle.solarized => ThemeStyle.solarizedDark,
        _ => ThemeStyle.dark,
      };
    }
    return _settings.theme;
  }

  static AppSettings _load(SharedPreferences prefs) {
    return AppSettings(
      theme: ThemeStyle.fromValue(prefs.getString('pref_theme')),
      autoDayNight: prefs.getBool('pref_daynight_auto') ?? false,
      textSize: TextSize.fromValue(
        int.tryParse(prefs.getString('pref_text_size') ?? '0'),
      ),
      font: AppFont.fromValue(prefs.getString('pref_font')),
      launchScreen: LaunchScreen.fromValue(
        prefs.getString('pref_launch_screen'),
      ),
      externalBrowser: prefs.getBool('pref_external') ?? false,
      colorCode: prefs.getBool('pref_color_code') ?? true,
      threadIndicator: prefs.getBool('pref_thread_indicator') ?? true,
      swipeActions: prefs.getBool('pref_list_swipe_left') ?? true,
      autoMarkRead: prefs.getBool('pref_auto_viewed') ?? true,
      lazyLoad: prefs.getBool('pref_lazy_load') ?? true,
      popularWindow: _popularWindow(prefs.getString('pref_popular_range')),
    );
  }

  static PopularWindow _popularWindow(String? value) => switch (value) {
    'last_week' => PopularWindow.week,
    'last_month' => PopularWindow.month,
    'last_year' => PopularWindow.year,
    _ => PopularWindow.day,
  };

  static String _popularValue(PopularWindow window) => switch (window) {
    PopularWindow.day => 'last_24h',
    PopularWindow.week => 'last_week',
    PopularWindow.month => 'last_month',
    PopularWindow.year => 'last_year',
  };

  Future<void> setTheme(ThemeStyle value) async {
    _settings = _settings.copyWith(theme: value);
    notifyListeners();
    await _prefs.setString('pref_theme', value.value);
  }

  Future<void> setAutoDayNight(bool value) async {
    _settings = _settings.copyWith(autoDayNight: value);
    notifyListeners();
    await _prefs.setBool('pref_daynight_auto', value);
  }

  Future<void> setTextSize(TextSize value) async {
    _settings = _settings.copyWith(textSize: value);
    notifyListeners();
    await _prefs.setString('pref_text_size', '${value.value}');
  }

  Future<void> setFont(AppFont value) async {
    _settings = _settings.copyWith(font: value);
    notifyListeners();
    await _prefs.setString('pref_font', value.value);
  }

  Future<void> setLaunchScreen(LaunchScreen value) async {
    _settings = _settings.copyWith(launchScreen: value);
    notifyListeners();
    await _prefs.setString('pref_launch_screen', value.value);
  }

  Future<void> setExternalBrowser(bool value) async {
    _settings = _settings.copyWith(externalBrowser: value);
    notifyListeners();
    await _prefs.setBool('pref_external', value);
  }

  Future<void> setColorCode(bool value) async {
    _settings = _settings.copyWith(colorCode: value);
    notifyListeners();
    await _prefs.setBool('pref_color_code', value);
  }

  Future<void> setThreadIndicator(bool value) async {
    _settings = _settings.copyWith(threadIndicator: value);
    notifyListeners();
    await _prefs.setBool('pref_thread_indicator', value);
  }

  Future<void> setSwipeActions(bool value) async {
    _settings = _settings.copyWith(swipeActions: value);
    notifyListeners();
    await _prefs.setBool('pref_list_swipe_left', value);
  }

  Future<void> setAutoMarkRead(bool value) async {
    _settings = _settings.copyWith(autoMarkRead: value);
    notifyListeners();
    await _prefs.setBool('pref_auto_viewed', value);
  }

  Future<void> setLazyLoad(bool value) async {
    _settings = _settings.copyWith(lazyLoad: value);
    notifyListeners();
    await _prefs.setBool('pref_lazy_load', value);
  }

  Future<void> setPopularWindow(PopularWindow value) async {
    _settings = _settings.copyWith(popularWindow: value);
    notifyListeners();
    await _prefs.setString('pref_popular_range', _popularValue(value));
  }
}
