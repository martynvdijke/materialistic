import '../../core/constants.dart';
import '../../core/models/item.dart';
import '../../core/network/hn_api.dart';

/// Builds comment trees from flat Hacker News items.
class CommentRepository {
  CommentRepository({required this.hnApi});

  final HnApi hnApi;
  int _loaded = 0;

  Future<List<CommentNode>> load(Item story) async {
    _loaded = 0;
    return _loadChildren(story.kids, 0);
  }

  Future<List<CommentNode>> _loadChildren(List<int> ids, int depth) async {
    if (ids.isEmpty || depth > AppConstants.maxCommentDepth) return const [];
    final items = await hnApi.fetchItems(ids);
    final visible = items
        .where(
          (item) =>
              !item.deleted &&
              !item.dead &&
              (item.hasText || item.kids.isNotEmpty),
        )
        .toList(growable: false);
    if (visible.isEmpty) return const [];

    final nodes = await Future.wait(
      visible.map((item) async {
        if (_loaded >= 600) {
          return CommentNode(item: item, depth: depth);
        }
        _loaded++;
        final children = await _loadChildren(item.kids, depth + 1);
        return CommentNode(item: item, children: children, depth: depth);
      }),
    );
    return nodes;
  }
}
