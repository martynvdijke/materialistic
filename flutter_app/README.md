# Materialistic Flutter

Flutter rewrite of Materialistic, targeting Android parity first. The native
app in `../app` remains the shipping implementation until cutover.

## Status

Implemented: feed browsing (top/new/best/ask/show/jobs/popular), story and
comment views, voting, replying, submitting, Algolia search with history,
profiles, favorites with export, login/create account/logout, the reader with
ad blocking, deep links, seven themes, text/font settings, and English,
Spanish and Simplified Chinese localization.

Not yet wired: one-time import of favorites, read history and credentials from
the native app. Deferred by design: home-screen widget, background sync,
offline archive, PDF viewer and iOS.

## Requirements

- Flutter 3.47 or newer (Dart 3.13)
- JDK 17 for Android builds
- Android SDK with API 36

The Android build uses the same application id (`io.github.hidroh.materialistic`)
as the native app, so install it on a separate device/emulator or uninstall one
before testing the other.

## Build and test

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

If your default Java is not a full JDK 17 (for example a JRE-only OpenJDK 11),
set `JAVA_HOME` for Gradle:

```sh
JAVA_HOME=/opt/jdk17 flutter build apk --debug
```

## Structure

```
lib/
  app.dart                 app shell, themes, localization, deep links
  core/                    API clients, Drift database, models, settings
  features/                feed, item/comments, search, favorites, account,
                           submit, profile, reader, settings
  l10n/                    hand-maintained en/es/zh-CN strings
  widgets/                 shared story, drawer, HTML and favorite widgets
```

Riverpod provides state, go_router navigation, Dio the HTTP clients, and Drift
the local database (`materialistic_flutter.db`).

## Dependency notes

- `flutter_inappwebview` is pinned to the 6.2 beta line because 6.1.x uses a
  ProGuard default that Android Gradle Plugin 9 rejects.
- `html` is pinned to 0.15.6 because `flutter_html` 3.0.0 imports an API removed
  in 0.15.7.
