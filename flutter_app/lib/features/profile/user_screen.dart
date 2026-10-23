import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/item.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/hn_html.dart';
import '../../widgets/story_tile.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key, required this.username});

  final String username;

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  UserProfile? _user;
  List<Item> _stories = const [];
  bool _loading = true;
  bool _loadingStories = true;
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
      final user = await ref.read(hnApiProvider).fetchUser(widget.username);
      if (!mounted) return;
      setState(() {
        _user = user;
        _loading = false;
      });
      final ids = await ref
          .read(storyRepositoryProvider)
          .userStoryIds(widget.username);
      final stories = await ref.read(storyRepositoryProvider).items(ids);
      if (!mounted) return;
      setState(() {
        _stories = stories;
        _loadingStories = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
        _loadingStories = false;
      });
    }
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.account),
        content: Text(l10n.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authControllerProvider).logout();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        actions: [
          if (auth.username == widget.username)
            IconButton(
              tooltip: l10n.logout,
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || _user == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_off_outlined, size: 48),
                  const SizedBox(height: 12),
                  Text(l10n.error),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _load, child: Text(l10n.retry)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          child: Text(
                            widget.username.isEmpty
                                ? '?'
                                : widget.username.substring(0, 1).toUpperCase(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.username,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${l10n.karma}: ${_user!.karma}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: muted,
                                ),
                              ),
                              Text(
                                '${l10n.joined}: ${_user!.created == 0 ? l10n.unknown : DateFormat.yMMMd().format(_user!.createdAt)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_user!.about != null && _user!.about!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: HnHtml(html: _user!.about!),
                    ),
                  const Divider(height: 24),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      l10n.submitted,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_loadingStories)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_stories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(child: Text(l10n.noResults)),
                    )
                  else
                    for (final story in _stories) ...[
                      StoryTile(
                        item: story,
                        isRead: false,
                        onTap: () => context.push('/item/${story.id}'),
                        onComments: () => context.push('/item/${story.id}'),
                        onOpenLink: story.hasUrl
                            ? () => context.push(
                                '/reader?url=${Uri.encodeComponent(story.url!)}&title=${Uri.encodeComponent(story.title ?? '')}',
                              )
                            : null,
                        onProfile: null,
                      ),
                      const Divider(height: 1),
                    ],
                ],
              ),
            ),
    );
  }
}
