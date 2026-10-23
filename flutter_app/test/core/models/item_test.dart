import 'package:flutter_test/flutter_test.dart';
import 'package:materialistic/core/models/item.dart';

void main() {
  group('Item.fromJson', () {
    test('parses a story with kids', () {
      final item = Item.fromJson({
        'id': 42,
        'title': 'A story',
        'url': 'https://www.example.com/path',
        'by': 'alice',
        'type': 'story',
        'score': 120,
        'descendants': 3,
        'time': 1700000000,
        'kids': [1, 2, '3', null],
        'dead': false,
        'deleted': false,
      })!;

      expect(item.id, 42);
      expect(item.title, 'A story');
      expect(item.domain, 'example.com');
      expect(item.score, 120);
      expect(item.descendants, 3);
      expect(item.kids, [1, 2, 3]);
      expect(item.isStory, isTrue);
      expect(item.hasUrl, isTrue);
      expect(item.webUrl, 'https://news.ycombinator.com/item?id=42');
    });

    test('returns null without an id', () {
      expect(Item.fromJson(null), isNull);
      expect(Item.fromJson({'title': 'no id'}), isNull);
    });

    test('accepts numeric strings and defaults missing fields', () {
      final item = Item.fromJson({
        'id': '7',
        'score': '12',
        'time': '1700000000',
      })!;

      expect(item.id, 7);
      expect(item.score, 12);
      expect(item.time, 1700000000);
      expect(item.kids, isEmpty);
      expect(item.dead, isFalse);
      expect(item.deleted, isFalse);
    });

    test('round-trips through JSON', () {
      const original = Item(
        id: 1,
        title: 'Title',
        url: 'https://example.com',
        by: 'bob',
        type: 'comment',
        text: 'Hello',
        parent: 2,
        kids: [3],
      );
      final copy = Item.fromJson(original.toJson())!;
      expect(copy.toJson(), original.toJson());
      expect(copy.isComment, isTrue);
      expect(copy.parent, 2);
    });
  });

  group('CommentNode', () {
    test('counts descendants recursively', () {
      const leaf = CommentNode(item: Item(id: 1));
      const parent = CommentNode(item: Item(id: 2), children: [leaf, leaf]);
      expect(parent.totalCount, 3);
    });
  });

  group('UserProfile.fromJson', () {
    test('parses profile data', () {
      final user = UserProfile.fromJson({
        'id': 'alice',
        'created': 1,
        'karma': 5,
        'about': '<p>hi</p>',
        'submitted': [1, '2', 3],
      })!;
      expect(user.id, 'alice');
      expect(user.karma, 5);
      expect(user.submitted, [1, 2, 3]);
    });

    test('returns null when id is missing', () {
      expect(UserProfile.fromJson({'karma': 1}), isNull);
    });
  });
}
