import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/item.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Favorites, ReadItems, ReadableItems, SearchHistory])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<FavoriteRow>> watchFavorites() {
    return (select(
      favorites,
    )..orderBy([(table) => OrderingTerm.desc(table.time)])).watch();
  }

  Future<List<FavoriteRow>> allFavorites() => select(favorites).get();

  Future<FavoriteRow?> findFavorite(int itemId) {
    return (select(
      favorites,
    )..where((table) => table.itemId.equals(itemId))).getSingleOrNull();
  }

  Future<bool> isFavorite(int itemId) async =>
      await findFavorite(itemId) != null;

  Future<void> addFavorite(Item item) {
    final companion = FavoritesCompanion.insert(
      itemId: item.id,
      title: Value(item.title ?? ''),
      url: Value(item.url),
      time: Value(item.time),
    );
    return into(favorites).insert(
      companion,
      onConflict: DoUpdate(
        (_) => FavoritesCompanion(
          title: Value(item.title ?? ''),
          url: Value(item.url),
          time: Value(item.time),
        ),
        target: [favorites.itemId],
      ),
    );
  }

  Future<void> removeFavorite(int itemId) {
    return (delete(
      favorites,
    )..where((table) => table.itemId.equals(itemId))).go();
  }

  Future<void> clearFavorites() => delete(favorites).go();

  Future<void> markRead(int itemId) {
    return into(readItems).insert(
      ReadItemsCompanion.insert(itemId: itemId),
      mode: InsertMode.insertOrIgnore,
      onConflict: DoNothing(target: [readItems.itemId]),
    );
  }

  Future<bool> isRead(int itemId) async {
    final row = await (select(
      readItems,
    )..where((table) => table.itemId.equals(itemId))).getSingleOrNull();
    return row != null;
  }

  Stream<Set<int>> watchReadIds() {
    return select(readItems)
        .watch()
        .map((rows) => rows.map((row) => row.itemId).toSet());
  }

  Future<void> clearRead() => delete(readItems).go();

  Future<void> saveReadable(int itemId, String content) {
    return into(readableItems).insertOnConflictUpdate(
      ReadableItemsCompanion.insert(itemId: Value(itemId), content: content),
    );
  }

  Future<String?> readable(int itemId) async {
    final row = await (select(
      readableItems,
    )..where((table) => table.itemId.equals(itemId))).getSingleOrNull();
    return row?.content;
  }

  Stream<List<SearchHistoryRow>> watchSearchHistory({int limit = 10}) {
    return (select(searchHistory)
          ..orderBy([(table) => OrderingTerm.desc(table.time)])
          ..limit(limit))
        .watch();
  }

  Future<void> addSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return Future.value();
    final now = DateTime.now().millisecondsSinceEpoch;
    return into(searchHistory).insert(
      SearchHistoryCompanion.insert(query: trimmed, time: Value(now)),
      onConflict: DoUpdate(
        (_) => SearchHistoryCompanion(time: Value(now)),
        target: [searchHistory.query],
      ),
    );
  }

  Future<void> removeSearch(String query) {
    return (delete(
      searchHistory,
    )..where((table) => table.query.equals(query))).go();
  }

  Future<void> clearSearchHistory() => delete(searchHistory).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'materialistic_flutter.db'));
    return NativeDatabase.createInBackground(file);
  });
}
