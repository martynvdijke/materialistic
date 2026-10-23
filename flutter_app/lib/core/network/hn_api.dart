import 'package:dio/dio.dart';

import '../constants.dart';
import '../models/item.dart';
import '../utils/semaphore.dart';

/// Client for the official Hacker News Firebase API.
class HnApi {
  HnApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConstants.hnBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              headers: {'User-Agent': AppConstants.userAgent},
            ),
          );

  final Dio _dio;
  final Semaphore _semaphore = Semaphore(10);
  final Map<int, Item> _itemCache = {};
  final Map<String, UserProfile> _userCache = {};

  Future<List<int>> fetchFeedIds({required String endpoint}) async {
    final response = await _dio.get<List<dynamic>>(endpoint);
    return (response.data ?? const [])
        .whereType<num>()
        .map((value) => value.toInt())
        .toList(growable: false);
  }

  Future<Item?> fetchItem(int id) async {
    final cached = _itemCache[id];
    if (cached != null) return cached;
    final response = await _semaphore.run(
      () => _dio.get<Map<String, dynamic>>('item/$id.json'),
    );
    final item = Item.fromJson(response.data);
    if (item != null) _itemCache[id] = item;
    return item;
  }

  Future<List<Item>> fetchItems(Iterable<int> ids) async {
    final items = await Future.wait(ids.map(fetchItem));
    return items.whereType<Item>().toList(growable: false);
  }

  Future<UserProfile?> fetchUser(String id) async {
    final cached = _userCache[id];
    if (cached != null) return cached;
    final response = await _semaphore.run(
      () => _dio.get<Map<String, dynamic>>(
        'user/$id.json',
        queryParameters: {'id': id},
      ),
    );
    final user = UserProfile.fromJson(response.data);
    if (user != null) _userCache[id] = user;
    return user;
  }

  void clearItems() => _itemCache.clear();
}
