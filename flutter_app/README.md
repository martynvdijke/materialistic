# Materialistic Flutter

Flutter rewrite of Materialistic, targeting Android parity first. The Flutter
app is the shipping Android client; the legacy native app in `../app` is kept
as a reference implementation and CI build artifact.

## Status

Implemented: feed browsing (top/new/best/ask/show/jobs/popular), story and
comment views, voting, replying, submitting, Algolia search with history,
profiles, favorites with export, login/create account/logout, the reader with
ad blocking, deep links, share-to-submit, seven themes, text/font/line-spacing
settings, long-comment limits, default story view, updated-story highlighting,
swipe actions, and English, Spanish and Simplified Chinese localization.

Not yet wired: one-time import of favorites, read history and credentials from
the native app, offline feed/article caching, custom-tab mode and per-thread
comment display modes. Deferred by design: home-screen widget, background sync,
offline archive, PDF viewer and iOS.

## Requirements

- Flutter 3.47 or newer (Dart 3.13)
- JDK 17 for Android builds
- Android SDK with API 36

The Flutter app uses the application id `xyz.vandijke.materialistic`, while
the legacy native app used `io.github.hidroh.materialistic`, so both can be
installed side by side. Local data is not migrated between them; uninstalling
either app removes only its own data.

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

An end-to-end test exercises live Hacker News and Algolia data on an Android
emulator or device:

```sh
JAVA_HOME=/opt/jdk17 flutter test integration_test/app_test.dart -d emulator-5554
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
