import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/models/item.dart';
import '../../core/providers.dart';
import '../../core/utils/url_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/favorite_button.dart';
import '../../widgets/hn_html.dart';

class ItemScreen extends ConsumerStatefulWidget {
  const ItemScreen({super.key, required this.itemId});

  final int itemId;

  @override
  ConsumerState<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends ConsumerState<ItemScreen> {
  Item? _item;
  List<CommentNode> _comments = const [];
  final _collapsed = <int>{};
  bool _loading = true;
  bool _loadingComments = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final item = await ref.read(storyRepositoryProvider).item(widget.itemId);
      if (!mounted) return;
      setState(() {
        _item = item;
        _loading = false;
        _loadingComments = item != null && item.kids.isNotEmpty;
      });
      if (item != null && ref.read(settingsProvider).settings.autoMarkRead) {
        ref.read(databaseProvider).markRead(item.id);
      }
      if (item != null && item.kids.isNotEmpty) {
        final comments = await ref.read(commentRepositoryProvider).load(item);
        if (!mounted) return;
        setState(() {
          _comments = comments;
          _loadingComments = false;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
        _loadingComments = false;
      });
    }
  }

  void _requireLogin() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.loginRequired),
        action: SnackBarAction(
          label: l10n.login,
          onPressed: () => context.push('/login'),
        ),
      ),
    );
  }

  Future<void> _upvote(Item item) async {
    final auth = ref.read(authControllerProvider);
    if (!auth.isLoggedIn) {
      _requireLogin();
      return;
    }
    final success = await auth.vote(item);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? l10n.saved : l10n.postingFailed)),
    );
  }

  Future<void> _share(Item item) async {
    final l10n = AppLocalizations.of(context);
    await SharePlus.instance.share(
      ShareParams(
        text: item.hasUrl
            ? '${item.title}\n${item.url}'
            : '${item.title}\n${item.webUrl}',
        subject: l10n.appName,
      ),
    );
  }

  Future<void> _reply(Item parent) async {
    final auth = ref.read(authControllerProvider);
    if (!auth.isLoggedIn) {
      _requireLogin();
      return;
    }
    final controller = TextEditingController();
    var sending = false;
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final l10n = AppLocalizations.of(context);
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.reply, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  minLines: 3,
                  maxLines: 8,
                  decoration: InputDecoration(hintText: l10n.commentHint),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: sending
                          ? null
                          : () async {
                              setModalState(() => sending = true);
                              final success = await auth.comment(
                                parent,
                                controller.text.trim(),
                              );
                              if (!context.mounted) return;
                              Navigator.pop(context, success);
                            },
                      child: sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.post),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    controller.dispose();
    if (!mounted || sent == null) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(sent ? l10n.commentPosted : l10n.postingFailed)),
    );
    if (sent) _reloadComments();
  }

  Future<void> _reloadComments() async {
    final item = _item;
    if (item == null || item.kids.isEmpty) return;
    setState(() {
      _loadingComments = true;
      _comments = const [];
    });
    final comments = await ref.read(commentRepositoryProvider).load(item);
    if (!mounted) return;
    setState(() {
      _comments = comments;
      _loadingComments = false;
    });
  }

  void _openLink() {
    final item = _item;
    if (item == null || !isHttpUrl(item.url)) return;
    if (ref.read(settingsProvider).settings.externalBrowser) {
      openExternal(item.url);
    } else {
      context.push(
        '/reader?url=${Uri.encodeComponent(item.url!)}&title=${Uri.encodeComponent(item.title ?? '')}',
      );
    }
  }

  List<CommentNode> get _visibleComments {
    final result = <CommentNode>[];
    void walk(List<CommentNode> nodes) {
      for (final node in nodes) {
        result.add(node);
        if (!_collapsed.contains(node.item.id)) walk(node.children);
      }
    }

    walk(_comments);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = _item;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          item?.hasUrl == true ? item!.domain ?? l10n.comments : l10n.comments,
        ),
        actions: [
          if (item != null) FavoriteButton(item: item, compact: false),
          if (item?.hasUrl == true)
            IconButton(
              tooltip: l10n.openInReader,
              icon: const Icon(Icons.article_outlined),
              onPressed: _openLink,
            ),
          if (item != null)
            IconButton(
              tooltip: l10n.share,
              icon: const Icon(Icons.share_outlined),
              onPressed: () => _share(item),
            ),
        ],
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null || _item == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            Text(l10n.error),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: Text(l10n.retry)),
          ],
        ),
      );
    }

    final item = _item!;
    final comments = _visibleComments;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: 1 + (comments.isEmpty ? 1 : comments.length),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _ItemHeader(
              item: item,
              onReply: _reply,
              onUpvote: _upvote,
              onOpenLink: _openLink,
              onShare: _share,
            );
          }
          if (comments.isEmpty) {
            if (_loadingComments) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(l10n.noComments)),
            );
          }
          if (index - 1 >= comments.length) {
            return const SizedBox.shrink();
          }
          final node = comments[index - 1];
          return _CommentTile(
            node: node,
            collapsed: _collapsed.contains(node.item.id),
            onToggle: () {
              setState(() {
                if (!_collapsed.remove(node.item.id)) {
                  _collapsed.add(node.item.id);
                }
              });
            },
            onReply: () => _reply(node.item),
            onUpvote: () => _upvote(node.item),
          );
        },
      ),
    );
  }
}

class _ItemHeader extends StatelessWidget {
  const _ItemHeader({
    required this.item,
    required this.onReply,
    required this.onUpvote,
    required this.onOpenLink,
    required this.onShare,
  });

  final Item item;
  final ValueChanged<Item> onReply;
  final ValueChanged<Item> onUpvote;
  final VoidCallback onOpenLink;
  final ValueChanged<Item> onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title ?? l10n.unknown,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
          if (item.domain != null) ...[
            const SizedBox(height: 4),
            InkWell(
              onTap: onOpenLink,
              child: Text(
                item.domain!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: Text(
                  '${item.score} ${l10n.points} ${l10n.by} ${item.by ?? l10n.unknown}',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ),
              const Spacer(),
              Text(
                item.descendants == 1
                    ? '1 ${l10n.comments}'
                    : '${item.descendants} ${l10n.comments}',
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
          ),
          if (item.hasText) ...[
            const SizedBox(height: 14),
            HnHtml(html: item.text!),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            children: [
              TextButton.icon(
                onPressed: () => onUpvote(item),
                icon: const Icon(Icons.arrow_upward, size: 18),
                label: Text(l10n.upvote),
              ),
              TextButton.icon(
                onPressed: () => onReply(item),
                icon: const Icon(Icons.reply, size: 18),
                label: Text(l10n.reply),
              ),
              TextButton.icon(
                onPressed: () => onShare(item),
                icon: const Icon(Icons.share_outlined, size: 18),
                label: Text(l10n.share),
              ),
            ],
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.node,
    required this.collapsed,
    required this.onToggle,
    required this.onReply,
    required this.onUpvote,
  });

  final CommentNode node;
  final bool collapsed;
  final VoidCallback onToggle;
  final VoidCallback onReply;
  final VoidCallback onUpvote;

  @override
  Widget build(BuildContext context) {
    final item = node.item;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final depth = node.depth.clamp(0, 8);
    final color = _usernameColor(theme, item.by ?? '');
    final muted = theme.colorScheme.onSurfaceVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (depth > 0)
            SizedBox(
              width: depth * 10.0,
              child: Row(
                children: [
                  for (var i = 0; i < depth; i++)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 5),
                        width: 1,
                        color: i == depth - 1
                            ? theme.colorScheme.primary.withValues(alpha: 0.35)
                            : theme.colorScheme.outlineVariant,
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: onToggle,
                    child: Row(
                      children: [
                        Text(
                          item.by ?? l10n.unknown,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _age(item, l10n),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                        if (collapsed) ...[
                          const SizedBox(width: 8),
                          Text(
                            '[+${node.totalCount}]',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!collapsed) ...[
                    const SizedBox(height: 4),
                    HnHtml(html: item.text ?? ''),
                    Row(
                      children: [
                        TextButton(onPressed: onReply, child: Text(l10n.reply)),
                        TextButton(
                          onPressed: onUpvote,
                          child: Text(l10n.upvote),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _age(Item item, AppLocalizations l10n) {
    final difference = DateTime.now().difference(item.createdAt);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}${l10n.minutesAgo}';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}${l10n.hoursAgo}';
    }
    return '${difference.inDays}${l10n.daysAgo}';
  }

  Color _usernameColor(ThemeData theme, String username) {
    final hash = username.codeUnits.fold<int>(0, (value, unit) => value + unit);
    final colors = [
      const Color(0xFFE57373),
      const Color(0xFFFFB74D),
      const Color(0xFF81C784),
      const Color(0xFF4FC3F7),
      const Color(0xFF9575CD),
      const Color(0xFFF06292),
      const Color(0xFF4DB6AC),
    ];
    return colors[hash % colors.length];
  }
}
