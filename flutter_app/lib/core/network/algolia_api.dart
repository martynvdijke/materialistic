import 'package:dio/dio.dart';

import '../constants.dart';

/// Client for Algolia's Hacker News search API.
class AlgoliaApi {
  AlgoliaApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConstants.algoliaBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              headers: {'User-Agent': AppConstants.userAgent},
            ),
          );

  final Dio _dio;

  Future<List<int>> search({
    String query = '',
    bool byDate = false,
    int page = 0,
    int hitsPerPage = 100,
    String tags = 'story',
    String? numericFilters,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      byDate ? 'search_by_date' : 'search',
      queryParameters: {
        if (query.trim().isNotEmpty) 'query': query.trim(),
        'tags': tags,
        'page': page,
        'hitsPerPage': hitsPerPage,
        'attributesToRetrieve': 'objectID',
        'numericFilters': ?numericFilters,
      },
    );
    final hits = response.data?['hits'];
    if (hits is! List) return const [];
    return hits
        .whereType<Map>()
        .map((hit) => int.tryParse('${hit['objectID']}'))
        .whereType<int>()
        .toList(growable: false);
  }

  Future<List<int>> popular({
    required Duration window,
    int page = 0,
    int hitsPerPage = 100,
  }) {
    final since =
        DateTime.now().subtract(window).millisecondsSinceEpoch ~/ 1000;
    return search(
      page: page,
      hitsPerPage: hitsPerPage,
      numericFilters: 'created_at_i>$since',
    );
  }

  Future<List<int>> userStories(String username) {
    return search(tags: 'author_$username', hitsPerPage: 100);
  }
}
