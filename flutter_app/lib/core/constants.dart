/// Shared application constants.
abstract final class AppConstants {
  static const appName = 'Materialistic';
  static const hnBaseUrl = 'https://hacker-news.firebaseio.com/v0/';
  static const hnWebUrl = 'https://news.ycombinator.com';
  static const algoliaBaseUrl = 'https://hn.algolia.com/api/v1/';
  static const itemWebUrl = '$hnWebUrl/item?id=';
  static const userWebUrl = '$hnWebUrl/user?id=';
  static const pageSize = 20;
  static const maxCommentDepth = 12;
  static const userAgent = 'Materialistic/3.4.0 (Flutter)';

  // Published legal documents. GitHub Pages must serve the repo's /docs
  // directory for these URLs to resolve.
  static const privacyPolicyUrl =
      'https://martynvdijke.github.io/materialistic/privacy.html';
  static const termsOfServiceUrl =
      'https://martynvdijke.github.io/materialistic/terms.html';
  static const sourceCodeUrl = 'https://github.com/martynvdijke/materialistic';

  // Hacker News handles account deletion itself; the app cannot delete an HN
  // account. This FAQ explains the request process (email hn@ycombinator.com).
  static const hnAccountDeletionUrl =
      'https://news.ycombinator.com/newsfaq.html';
}
