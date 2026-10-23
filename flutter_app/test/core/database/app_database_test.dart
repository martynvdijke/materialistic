import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:materialistic/core/database/app_database.dart';
import 'package:materialistic/core/models/item.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('stores, lists and removes favorites', () async {
    const item = Item(id: 10, title: 'Story', url: 'https://example.com');
    await db.addFavorite(item);

    expect(await db.isFavorite(10), isTrue);
    expect(await db.findFavorite(10), isNotNull);
    expect((await db.allFavorites()).single.title, 'Story');

    await db.removeFavorite(10);
    expect(await db.isFavorite(10), isFalse);
  });

  test('updates a favorite in place', () async {
    await db.addFavorite(const Item(id: 10, title: 'Old'));
    await db.addFavorite(const Item(id: 10, title: 'New'));
    final favorites = await db.allFavorites();
    expect(favorites, hasLength(1));
    expect(favorites.single.title, 'New');
  });

  test('tracks read items and clears them', () async {
    await db.markRead(1);
    await db.markRead(1);
    await db.markRead(2);
    expect(await db.isRead(1), isTrue);
    expect(await db.watchReadIds().first, {1, 2});

    await db.clearRead();
    expect(await db.isRead(1), isFalse);
  });

  test('stores readable content by item', () async {
    await db.saveReadable(5, '<p>content</p>');
    expect(await db.readable(5), '<p>content</p>');

    await db.saveReadable(5, '<p>updated</p>');
    expect(await db.readable(5), '<p>updated</p>');
  });

  test('deduplicates search history and clears it', () async {
    await db.addSearch('flutter');
    await db.addSearch('  flutter  ');
    await db.addSearch('dart');

    final history = await db.watchSearchHistory().first;
    expect(history.map((row) => row.query), containsAll(['flutter', 'dart']));
    expect(history.where((row) => row.query == 'flutter'), hasLength(1));

    await db.removeSearch('dart');
    expect((await db.watchSearchHistory().first).map((row) => row.query), [
      'flutter',
    ]);

    await db.clearSearchHistory();
    expect(await db.watchSearchHistory().first, isEmpty);
  });
}
