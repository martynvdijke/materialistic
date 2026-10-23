# Materialistic Flutter Migration Design

- **Date:** 2026-10-23
- **Status:** Approved direction, pending spec review
- **Decision:** Phased full rewrite in Flutter, Android first
- **Last native release:** commit `20898729` (versionCode 79, versionName 3.3)

## 1. Summary

Materialistic is a 138-file, ~19,500-line native Android app with substantial
platform integration. This design replaces it with a Flutter app while keeping
the existing native app buildable until the Flutter app reaches core feature
parity.

The first Flutter release targets Android only and keeps the same application
ID at cutover so it can upgrade in place, retain the Play Store listing, and
read existing local data for a one-time migration. iOS follows after Android
parity and is not part of the first release.

## 2. Goals

- Ship an Android Flutter client with parity for browsing, searching, reading,
  commenting, voting, submitting, favorites, login, and settings.
- Preserve existing favorites, read history, readable articles, credentials,
  and user preferences across the upgrade.
- Keep the native app working and shippable until cutover.
- Establish an architecture that extends to iOS without rewriting the domain
  or data layers.
- Keep the app free of analytics/tracking and preserve its offline-friendly,
  privacy-respecting behavior.

## 3. Non-goals for the first Flutter release

- iOS release.
- Home-screen widgets.
- Android sync adapter and background download service.
- Offline article/comment archive and its notifications.
- Multi-window launch behavior and volume-key navigation.
- PDF.js-based PDF viewing.
- Feature redesign. Visual direction stays recognizably Materialistic.

These are tracked as post-parity work, not silently dropped.

## 4. Current system inventory

- **Source:** 131 Java + 7 Kotlin files, ~19,500 LOC, 59 layouts.
- **Feeds:** top, new, best, ask, show, jobs, popular, favorites, search.
- **Item:** story/article view, comment tree, thread preview, user profile.
- **Actions:** login/create account/logout, upvote, reply, submit, favorite,
  share, mark read.
- **Reader:** internal WebView with ad blocking, custom tabs/external browser,
  readability extraction, font/line-height controls, PDF.js.
- **Storage:** Room database `materialistic.db` with `saved`, `read`, and
  `readable` tables; `SharedPreferences` for settings; Android
  `AccountManager` for credentials.
- **Platform:** sync adapter (`:sync` process), content providers, app widget,
  JobScheduler refresh, notifications, deep links, share target, search
  suggestions.
- **APIs:** Hacker News Firebase API, Algolia search API, Hacker News HTML
  endpoints for auth/actions, Mercury readability endpoint.
- **Locales:** English, Spanish, Simplified Chinese.

## 5. Repository layout

```
app/                         Existing native Android app (frozen at parity)
flutter_app/                 New Flutter client
  lib/
    app/                     App shell, router, theme, localization
    core/                    Network, storage, result types, utilities
    features/
      feed/
      item/
      comments/
      search/
      favorites/
      account/
      submit/
      settings/
      profile/
  test/                      Unit and widget tests
  integration_test/          End-to-end flows
  assets/                    Fonts, ad-block hosts, fixtures
docs/
  migration/                 Parity matrix, migration notes
  superpowers/specs/         This design and future specs
```

The native app remains the reference implementation. No new features are added
to it during the migration except release-critical fixes.

## 6. Flutter architecture

### Stack

| Concern | Choice | Reason |
|---|---|---|
| State and DI | Riverpod | Testable async state, no global singletons |
| Navigation | `go_router` | Declarative routes, deep links, typed navigation |
| HTTP | Dio | Interceptors, timeouts, test adapters |
| Cookies | `cookie_jar` + Dio adapter | HN web actions and login flow |
| Models | `freezed` + `json_serializable` | Immutable models and fixtures |
| Local database | Drift | Typed SQLite, migrations, legacy import |
| Settings | `shared_preferences` | Small key/value settings |
| Credentials | `flutter_secure_storage` | Migrated from `AccountManager` |
| Localization | `flutter_localizations` + ARB | en, es, zh-CN parity |
| HTML rendering | `flutter_html` (sanitized) | Comments and story text |
| Reader/web | `flutter_inappwebview` | Ad blocking, Readability.js fallback |
| External links | `url_launcher` + custom tabs | Browser parity |
| Sharing | `share_plus`, `receive_sharing_intent` | Share and submit flows |

Exact package versions are resolved during scaffolding and pinned in
`pubspec.lock`; this document does not pin versions that will drift.

### Layers

Each feature has three layers:

- **Presentation:** widgets and Riverpod controllers/notifiers. No direct HTTP
  or database access.
- **Domain:** immutable entities, repository interfaces, and small use cases
  where orchestration is non-trivial.
- **Data:** remote data sources, Drift DAOs, DTO mapping, and repository
  implementations.

Cross-feature dependencies go through `core/` or domain interfaces, never
through another feature's widgets. This keeps feed, item, and account work
independently testable and prevents a second monolith.

### App shell

- `MaterialApp.router` with `go_router`.
- Adaptive drawer on compact screens and a navigation rail on wide screens,
  matching the existing drawer/multi-pane intent.
- Route structure covers feeds, item/comments, search, favorites, profile,
  submit, settings, login, about.
- Deep links map `news.ycombinator.com/item?id=...`,
  `news.ycombinator.com/user?id=...`, and in-app item/user URLs to routes.
- Android share intent opens the submit flow with title/URL prefilled.

## 7. Feature parity matrix

### Required for the first Flutter release

| Area | Requirement |
|---|---|
| Feeds | Top, new, best, ask, show, jobs, popular; pull-to-refresh; pagination as needed |
| Feed state | Read/unread state, highlight updated stories, swipe favorite/vote |
| Item | Story text, link, metadata, score, author, time, domain |
| Comments | Threaded tree, collapse/expand, thread lines, long-comment truncation, color-coded usernames |
| Search | Algolia search, recent sort, in-app search history; no system search provider |
| Profiles | User karma, created date, about, submissions |
| Favorites | Add/remove/clear, filter, export to share sheet |
| History | Read state and viewed-story behavior |
| Account | Login, create account, logout, credential persistence |
| Actions | Upvote, reply, submit story, share |
| Reader | Internal article view, reader/readability mode, ad blocking, external/custom-tab option |
| Settings | Theme (incl. auto day/night), text size, fonts, line spacing, comment display, launch screen, swipe actions, external browser/custom tabs, lazy loading, color coding, thread indicator, auto-mark-read |
| Localization | English, Spanish, Simplified Chinese |
| Accessibility | Scalable text, semantic labels, contrast in light/dark themes |
| Links | Item/user deep links, share target, browser fallback |
| Data | Import favorites, read history, readable content, settings, credentials |

### Deferred to post-parity

- Home-screen widget and its refresh job.
- Sync adapter, background downloads, download progress notifications.
- Offline archive for comments/articles/readability.
- Multi-window launch targeting and volume-key scrolling.
- PDF.js viewer (open PDFs externally or in the system WebView instead).
- Android search-suggestion provider.

## 8. Data layer

### Remote APIs

- **Hacker News Firebase:** story ID lists, items, users. Base URL
  `https://hacker-news.firebaseio.com/v0/`.
- **Algolia:** story search and popular feeds. Base URL
  `https://hn.algolia.com/api/v1/`.
- **Hacker News web:** `https://news.ycombinator.com/` for login, account
  creation, voting, replying, and submitting. These endpoints are unofficial
  and must stay behind a dedicated client with fixture tests.
- **Readability:** keep the existing configurable Mercury-compatible endpoint.
  If extraction fails or no token exists, fall back to Readability.js in a
  hidden WebView and cache the result.

### Caching and offline behavior

- Feed ID lists and item JSON are cached in Drift with a short TTL (5 minutes
  for feeds, 10 minutes for items) and served on network failure.
- Favorites, read state, readable content, and search history are durable.
- Network failures surface a retryable error state and, where cached data
  exists, a non-blocking offline banner.
- No background refresh in v1; refresh happens on screen open and pull-to-refresh.

### Drift schema

New database: `materialistic_flutter.db`.

| Table | Key | Purpose |
|---|---|---|
| `favorites` | `item_id` | Saved story metadata and save time |
| `read_items` | `item_id` | Viewed story IDs and timestamps |
| `readable_articles` | `item_id` | Extracted reader HTML and fetch time |
| `cached_items` | `item_id` | Last-known item JSON and fetch time |
| `cached_feeds` | `feed` | Ordered story IDs and fetch time |
| `search_history` | `query` | Recent queries and last-used time |

Legacy `saved`, `read`, and `readable` tables are read-only migration sources.

## 9. Authentication and user actions

The native app stores credentials as an Android account (`AccountManager`,
account type `io.github.hidroh.materialistic`) and posts `acct`/`pw` with each
vote, reply, or submit request.

Flutter will:

1. On first launch, read the migrated username/password through a one-time
   MethodChannel call to `AccountManager`.
2. Store credentials in `flutter_secure_storage`.
3. Perform login and account creation by posting the same form fields to
   `/login`, preserving the existing success/failure semantics.
4. Keep an in-memory cookie jar for the submit flow, where HN returns an
   `fnid` and `set-cookie` before the final post.
5. Never log credentials or include them in crash reports.
6. Leave legacy accounts in place until the Flutter release is proven, so a
   rollback to the native app still works.

The client presents HN errors in user-facing language (wrong password,
duplicate submission, rate limiting) rather than raw HTML.

## 10. Reader and web content

- Internal article view uses a WebView with the existing host blocklist
  (`pgl.yoyo.org.txt`) applied at request time.
- Reader mode tries the configured extraction endpoint, then Readability.js in
  a hidden WebView. Extracted HTML is sanitized and rendered natively.
- Font family, font size, and line height from settings apply to the reader.
- External-browser and custom-tab preferences are honored; custom tabs fall
  back to the system browser when unavailable.
- Login-only flows use the same WebView cookie jar where possible.

## 11. Migration from the native app

Cutover requirements:

- Same `applicationId`: `io.github.hidroh.materialistic`.
- Same release signing key as the current Play listing.
- `versionCode` starts at 100 (current is 79).
- Flutter database uses a new filename; the legacy database is never modified.

First-launch migration steps, guarded by a persisted `migration_completed`
flag:

1. Open legacy `materialistic.db` read-only and copy `saved`, `read`, and
   `readable` rows into the new Drift tables in one transaction.
2. Read native `SharedPreferences` through a MethodChannel and map known keys
   to Flutter settings. Unknown or obsolete keys are ignored.
3. Read matching `AccountManager` accounts and copy credentials into secure
   storage.
4. Mark migration complete only after all steps succeed. Partial failure keeps
   the flag unset and retries on next launch without deleting legacy data.
5. Keep legacy data for at least one release cycle. A later release may remove
   it after a documented cleanup.

Developer builds use an `io.github.hidroh.materialistic.dev` suffix so native
and Flutter builds can coexist. Production migration is tested only with the
release package and signing configuration.

## 12. UX, theming, and localization

- Preserve the existing theme families — light, dark, black, sepia, green,
  solarized, and solarized dark — and use Material 3 components while keeping
  Materialistic's typography, spacing, and density.
- Centralize theme tokens in `app/theme/`; no hard-coded colors in feature
  widgets.
- Support system, light, dark, and auto day/night modes.
- Font choices retain the current bundled fonts (Droid Serif, Roboto Slab,
  Libre Baskerville) plus the system default.
- Comments support configurable line height, max lines, color-coded usernames,
  thread indicators, and collapse state.
- All strings live in ARB files. No user-facing text in widgets.
- Respect system text scaling; test at 200% font size.
- Provide semantics for icon-only actions, vote state, and comment controls.

## 13. Error handling

- Typed failures: network, timeout, parse, auth, rate-limit, not-found.
- Screens render loading, empty, error, and cached-content states explicitly.
- Action failures (vote/reply/submit) surface a snackbar or inline error and
  never silently succeed.
- HN HTML parser failures are reported as a generic "Hacker News changed its
  response" error and logged without credentials.
- No automatic retries for writes; reads may retry once on transient failure.
- Crash reporting is opt-in or omitted entirely; no third-party analytics.

## 14. Testing and verification

- **Unit:** JSON mapping, HTML form parsing (`fnid`/error extraction), feed and
  item repositories, cache TTL, settings mapping, legacy DB import.
- **Widget:** feed list, item header, comment tree collapse, login form,
  settings changes, empty/error/offline states.
- **Golden:** light/dark/reader themes at phone and tablet widths.
- **Integration:** mocked HTTP server covering login, vote, reply, submit,
  search, and pagination. No automated writes to the live HN site.
- **Manual:** login with a real HN account on a device, vote/reply/submit,
  custom tabs, deep links, upgrade-over-native migration, rollback.
- **CI:** `flutter analyze`, `flutter test`, `flutter build apk --debug`, plus
  the existing native `assembleDebug` job while both apps exist.

Verification limitations: this environment has no emulator or device, so
runtime and visual checks require one before release.

## 15. Release and cutover

1. Internal builds under the dev application ID for side-by-side testing.
2. Release-candidate builds under the production ID, installed over the native
   app on a test device, verifying data migration and rollback.
3. Internal testing track, then closed beta, then staged rollout.
4. Keep the native source tagged and buildable for at least one release cycle.
5. After rollout, remove native-only code only in a separate, explicit change.

## 16. Milestones

1. **Foundation:** Flutter project, flavors, router, theme, network client,
   Drift schema, fixtures, CI.
2. **Read parity:** feeds, item, comments, profiles, search, browser, read state.
3. **Write parity:** auth, vote, reply, submit, favorites, reader, settings,
   export.
4. **Migration and platform:** legacy data import, deep links, share target,
   localization, accessibility pass.
5. **Cutover:** release signing, upgrade testing, beta, staged rollout.
6. **Post-parity:** widgets, sync/offline archive, notifications, PDF handling,
   iOS.

## 17. Risks

| Risk | Mitigation |
|---|---|
| HN HTML endpoints change | Isolate parser, fixture tests, clear user-facing errors |
| Mercury endpoint unavailable | Readability.js fallback and configurable endpoint |
| Signing key unavailable | Confirm key before cutover; cannot upgrade in place without it |
| Legacy data migration corrupts data | Copy-only import, transaction, idempotent retry, keep legacy DB |
| Flutter WebView/adblock parity gaps | Test against real articles; allow external browser |
| No device in current environment | Require device/emulator verification before beta |
| Two apps during migration | Freeze native features, track parity matrix, set cutover criteria |

## 18. Acceptance criteria

The first Flutter release is ready when:

- Every "Required" row in the parity matrix passes on a physical Android device.
- A production-signed Flutter build upgrades over the native app and imports
  favorites, read history, readable content, settings, and credentials.
- Login, vote, reply, submit, favorite, and export succeed against live HN.
- Deep links and share-to-submit work.
- `flutter analyze`, `flutter test`, and release build pass in CI.
- No credentials appear in logs, errors, or crash output.
- All theme families pass visual review at phone and tablet sizes.

## 19. Open questions

- Confirm the release keystore and Play Console access before cutover.
- Decide whether to keep Android `AccountManager` integration after migration
  or fully replace it with secure storage (current plan: migrate, then retire).
- Confirm whether the existing Mercury token is still valid; if not, ship only
  the Readability.js fallback.
- Decide whether PDF links should open externally or get a dedicated viewer
  after parity.
