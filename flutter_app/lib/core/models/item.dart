import 'package:flutter/foundation.dart';

/// A Hacker News item, which may be a story, comment, job or poll.
@immutable
class Item {
  const Item({
    required this.id,
    this.title,
    this.url,
    this.text,
    this.by,
    this.type,
    this.score = 0,
    this.descendants = 0,
    this.time = 0,
    this.kids = const [],
    this.dead = false,
    this.deleted = false,
    this.parent,
  });

  final int id;
  final String? title;
  final String? url;
  final String? text;
  final String? by;
  final String? type;
  final int score;
  final int descendants;
  final int time;
  final List<int> kids;
  final bool dead;
  final bool deleted;
  final int? parent;

  bool get isStory => type == 'story' || type == 'job' || type == 'poll';
  bool get isComment => type == 'comment';
  bool get hasText => text != null && text!.trim().isNotEmpty;
  bool get hasUrl => url != null && url!.trim().isNotEmpty;

  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(time * 1000);

  /// Host name without the `www.` prefix.
  String? get domain {
    final value = url;
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    final host = uri?.host;
    if (host == null || host.isEmpty) return null;
    return host.startsWith('www.') ? host.substring(4) : host;
  }

  String get webUrl => 'https://news.ycombinator.com/item?id=$id';

  static Item? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = _asInt(json['id']);
    if (id == null) return null;
    return Item(
      id: id,
      title: _asString(json['title']),
      url: _asString(json['url']),
      text: _asString(json['text']),
      by: _asString(json['by']),
      type: _asString(json['type']),
      score: _asInt(json['score']) ?? 0,
      descendants: _asInt(json['descendants']) ?? 0,
      time: _asInt(json['time']) ?? 0,
      kids: _asIntList(json['kids']),
      dead: json['dead'] == true,
      deleted: json['deleted'] == true,
      parent: _asInt(json['parent']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'url': url,
    'text': text,
    'by': by,
    'type': type,
    'score': score,
    'descendants': descendants,
    'time': time,
    'kids': kids,
    'dead': dead,
    'deleted': deleted,
    'parent': parent,
  };

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  static String? _asString(Object? value) {
    if (value == null) return null;
    final text = '$value';
    return text.isEmpty ? null : text;
  }

  static List<int> _asIntList(Object? value) {
    if (value is! List) return const [];
    return value.map(_asInt).whereType<int>().toList(growable: false);
  }
}

/// A Hacker News public user profile.
@immutable
class UserProfile {
  const UserProfile({
    required this.id,
    this.created = 0,
    this.karma = 0,
    this.about,
    this.submitted = const [],
  });

  final String id;
  final int created;
  final int karma;
  final String? about;
  final List<int> submitted;

  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(created * 1000);

  static UserProfile? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = json['id'];
    if (id is! String) return null;
    return UserProfile(
      id: id,
      created: (json['created'] as num?)?.toInt() ?? 0,
      karma: (json['karma'] as num?)?.toInt() ?? 0,
      about: json['about'] as String?,
      submitted:
          (json['submitted'] as List?)
              ?.map(
                (value) =>
                    value is num ? value.toInt() : int.tryParse('$value'),
              )
              .whereType<int>()
              .toList(growable: false) ??
          const [],
    );
  }
}

/// A node in a comment tree.
@immutable
class CommentNode {
  const CommentNode({
    required this.item,
    this.children = const [],
    this.depth = 0,
  });

  final Item item;
  final List<CommentNode> children;
  final int depth;

  int get totalCount =>
      1 + children.fold(0, (total, child) => total + child.totalCount);
}
