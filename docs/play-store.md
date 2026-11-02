# Google Play submission notes

These notes describe how the Play Console declarations should match the code in
this repository. They are not a substitute for the Play Console’s current
wording; review the Console prompts at submission time.

## App identity

- App name: **Materialistic for Hacker News**
- Flutter publishing package: `xyz.vandijke.materialistic`
- Native build package in this repository: `io.github.hidroh.materialistic`
- Target SDK: 36 (`targetSdk = 36` in the native app; Flutter uses
  `flutter.targetSdkVersion`, which CI builds against Android SDK 36)
- Privacy policy: <https://martynvdijke.github.io/materialistic/privacy.html>
- Terms: <https://martynvdijke.github.io/materialistic/terms.html>

GitHub Pages must be enabled for the repository and configured to serve the
`/docs` directory. If the repository is moved or renamed, update the URL
constants in `app/build.gradle` (`PRIVACY_POLICY_URL`, `TERMS_OF_SERVICE_URL`,
`LICENSES_URL`) and `flutter_app/lib/core/constants.dart`
(`privacyPolicyUrl`, `termsOfServiceUrl`).

## Data safety

The app has no developer-operated backend. The publisher does not receive or
store app data. Local data stays on the device. The only off-device transfers
are direct requests to third-party services selected or used by the user.

Recommended answers:

### Does your app collect or share any of the required user data types?

**Yes.** The app transmits data to third parties for app functionality, even
though the developer receives none of it.

Declare at least:

| Play data type | When | Purpose | Shared with | Optional? | Encrypted in transit? |
| --- | --- | --- | --- | --- | --- |
| Personal info → User IDs (Hacker News username) | Only when the user logs in or performs an account action | App functionality | Hacker News | Yes | Yes (HTTPS) |
| Personal info → Passwords / credentials (if offered by the Console; otherwise describe under the closest “other personal info” option) | Only when the user logs in or performs an account action | App functionality | Hacker News | Yes | Yes (HTTPS) |
| App activity → In-app search history (search query) | When the user searches | App functionality | Algolia | Yes (search is user-initiated) | Yes (HTTPS) |
| App activity → Other user-generated content (feedback title/body) | Only when the user submits feedback | App functionality / support | GitHub (public issue) | Yes | Yes (HTTPS) |
| App info and performance → Other app performance data (device manufacturer/model, Android SDK level, app version) | Only when the user submits feedback | App functionality / support | GitHub (public issue) | Yes | Yes (HTTPS) |

Notes:

- Favorites, read history, and local search history are stored only on the
  device (Drift database / SharedPreferences). They are not collected by the
  developer and are not declared as collected.
- The optional reader sends an article URL to Mercury only if the reader is
  configured and the user opens an article in it. If that build is shipped,
  declare the URL transfer as app functionality and shared with Mercury.
- The app has no advertising SDK, no developer analytics, no crash-reporting
  SDK, and no tracking. It does not sell data.
- If Play treats a user-initiated transfer to a third-party service as not
  “collection”, the policy still discloses it. Keep the policy and the Console
  consistent.

### Is all user data encrypted in transit?

**Yes.** All network endpoints used by the app are HTTPS. The native app’s
network security config sets `cleartextTrafficPermitted="false"`.

### Can users request that their data be deleted?

**Yes, for local data.** In-app actions delete local favorites, read history,
search history, and stored credentials; uninstalling the app removes all local
data. The developer holds no server-side data to delete.

There is no developer account system. Hacker News account data is controlled by
Hacker News and must be deleted through Hacker News. The app cannot delete a
Hacker News account. The privacy policy explains this and links to the Hacker
News FAQ and `hn@ycombinator.com`.

### Account deletion URL

Play’s account deletion requirement applies when an app allows users to create
an account with the developer. This app does not create developer accounts; it
only authenticates an existing Hacker News account and stores the credentials
on-device. The developer has no backend account record and cannot delete an
HN account.

For that reason no developer account-deletion URL is required. If a reviewer
asks for one anyway, point to the “Deleting your data and your Hacker News
account” section of the privacy policy, which explains local deletion and the
HN process. Do not add a fake deletion endpoint or claim that the app can delete
HN accounts.

## App access

- Login is optional. Public feeds, comments, search, favorites, and reading work
  without an account.
- Voting, commenting, and submitting require a Hacker News login.
- For review, either explain that login is optional or provide a dedicated HN
  test account in the Play Console “App access” instructions. Never commit test
  credentials to the repository.

## Content rating

- Complete the IARC questionnaire.
- The app displays unmoderated, user-generated Hacker News content and opens
  arbitrary external websites. It has no ads, gambling, or in-app purchases.
- Expect a Teen / 12+ type rating because of user-generated content and external
  web content; the final rating comes from IARC.

## Ads, target audience, and families

- Ads: **No**, the app contains no ads.
- Target audience: **18+** recommended. At minimum, do not target children
  under 16; the privacy notice says the app is not directed to children under
  16.
- Families policy: not applicable; do not opt in to the Families programme.
- News app declaration: this is a client for a third-party community site, not
  a news publisher. Answer the Console’s questions factually if prompted.

## Permissions and technical declarations

- `INTERNET`, `ACCESS_NETWORK_STATE`, and notifications (native) are used for
  normal app operation.
- Native `AUTHENTICATE_ACCOUNTS` and `GET_ACCOUNTS` are limited to API 22 and
  below for the Android account store.
- No location, camera, microphone, contacts, SMS, call log, or advertising ID
  permissions.
- No foreground service, no accessibility service, no VPN service.
- The native app sets `allowBackup="false"`; Flutter does the same. Local
  credentials and history are not included in Android cloud backup.
- The native About screen links to the fork’s privacy policy and terms; the
  Flutter Settings screen links to the same documents and provides a “Delete
  local account data” action.

## Release checklist

1. Replace the `[PRIVACY CONTACT ...]` placeholders in `PRIVACY-POLICY.txt`,
   `docs/privacy.html`, and `docs/terms.html` with a monitored address.
2. Enable GitHub Pages for `/docs` and verify the privacy and terms URLs return
   200.
3. Verify the Play Data safety answers above against the exact build being
   uploaded.
4. Confirm the listing does not claim analytics, crash reporting, or a developer
   account system.
5. Build and test:
   - `cd flutter_app && flutter analyze && flutter test`
   - `./gradlew test lintDebug`
