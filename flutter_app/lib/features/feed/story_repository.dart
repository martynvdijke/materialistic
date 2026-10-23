import '../../core/constants.dart';
import '../../core/models/item.dart';
import '../../core/network/algolia_api.dart';
import '../../core/network/hn_api.dart';

/// Loads feed and item data, mixing the Firebase and Algolia APIs.
class StoryRepository {
  StoryRepository({required this.hnApi, required this.algoliaApi});

  final HnApi hnApi;
  final AlgoliaApi algoliaApi;

  final Map<String, _CachedIds> _feedIds = {};
  static const _feedIdsTtl = Duration(minutes: 2);

  Future<List<int>> feedIds(
    String key,
    Future<List<int>> Function() load,
  ) async {
    final cached = _feedIds[key];
    if (cached != null && !cached.isStale) return cached.ids;
    final ids = await load();
    _feedIds[key] = _CachedIds(ids);
    return ids;
  }

  Future<List<Item>> loadFeedPage({
    required String key,
    required Future<List<int>> Function() loadIds,
    required int page,
    int pageSize = AppConstants.pageSize,
  }) async {
    final ids = await feedIds(key, loadIds);
    final start = page * pageSize;
    if (start >= ids.length) return const [];
    final end = (start + pageSize).clamp(0, ids.length);
    return hnApi.fetchItems(ids.sublist(start, end));
  }

  Future<Item?> item(int id) => hnApi.fetchItem(id);

  Future<List<Item>> items(Iterable<int> ids) => hnApi.fetchItems(ids);

  Future<List<int>> searchIds({
    required String query,
    required bool byDate,
    required int page,
  }) {
    return algoliaApi.search(query: query, byDate: byDate, page: page);
  }

  Future<List<int>> userStoryIds(String username) {
    return algoliaApi.userStories(username);
  }

  void invalidate() {
    _feedIds.clear();
    hnApi.clearItems();
  }
}

class _CachedIds {
  _CachedIds(this.ids) : loadedAt = DateTime.now();

  final List<int> ids;
  final DateTime loadedAt;

  bool get isStale =>
      DateTime.now().difference(loadedAt) > StoryRepository._feedIdsTtl;
}
