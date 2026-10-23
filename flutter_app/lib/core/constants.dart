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
}
