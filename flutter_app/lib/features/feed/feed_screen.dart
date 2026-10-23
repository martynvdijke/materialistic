import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/item.dart';
import '../../core/providers.dart';
import '../../core/utils/url_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/story_tile.dart';
import 'feed_type.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key, required this.feedType});

  final FeedType feedType;

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _items = <Item>[];
  final _scrollController = ScrollController();
  late final Stream<Set<int>> _readStream;
  bool _loading = false;
  bool _hasMore = true;
  bool _firstLoad = true;
  Object? _error;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _readStream = ref.read(databaseProvider).watchReadIds();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFirstPage());
  }

  @override
  void didUpdateWidget(covariant FeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.feedType != widget.feedType) {
      _reload();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 600) {
      _loadNextPage();
    }
  }

  Future<List<Item>> _fetchPage(int page) {
    final repo = ref.read(storyRepositoryProvider);
    final hn = ref.read(hnApiProvider);
    final algolia = ref.read(algoliaApiProvider);
    final window = ref.read(settingsProvider).settings.popularWindow;
    return switch (widget.feedType) {
      FeedType.top => repo.loadFeedPage(
        key: 'top',
        loadIds: () => hn.fetchFeedIds(endpoint: 'topstories.json'),
        page: page,
      ),
      FeedType.newest => repo.loadFeedPage(
        key: 'new',
        loadIds: () => hn.fetchFeedIds(endpoint: 'newstories.json'),
        page: page,
      ),
      FeedType.best => repo.loadFeedPage(
        key: 'best',
        loadIds: () => hn.fetchFeedIds(endpoint: 'beststories.json'),
        page: page,
      ),
      FeedType.ask => repo.loadFeedPage(
        key: 'ask',
        loadIds: () => hn.fetchFeedIds(endpoint: 'askstories.json'),
        page: page,
      ),
      FeedType.show => repo.loadFeedPage(
        key: 'show',
        loadIds: () => hn.fetchFeedIds(endpoint: 'showstories.json'),
        page: page,
      ),
      FeedType.jobs => repo.loadFeedPage(
        key: 'jobs',
        loadIds: () => hn.fetchFeedIds(endpoint: 'jobstories.json'),
        page: page,
      ),
      FeedType.popular => repo.loadFeedPage(
        key: 'popular-${window.name}',
        loadIds: () => algolia.popular(window: window.duration),
        page: page,
      ),
    };
  }

  Future<void> _loadFirstPage() => _loadPage(0, replace: true);

  Future<void> _loadNextPage() {
    if (_loading || !_hasMore || _firstLoad) return Future.value();
    return _loadPage(_page, replace: false);
  }

  Future<void> _loadPage(int page, {required bool replace}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      if (replace) _error = null;
    });
    try {
      final items = await _fetchPage(page);
      if (!mounted) return;
      setState(() {
        if (replace) _items.clear();
        _items.addAll(items);
        _page = page + 1;
        _hasMore = items.length >= 20;
        _firstLoad = false;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _firstLoad = false;
        if (replace || _items.isEmpty) _error = error;
      });
      if (!replace && _items.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).error),
            action: SnackBarAction(
              label: AppLocalizations.of(context).retry,
              onPressed: _loadNextPage,
            ),
          ),
        );
      }
    }
  }

  Future<void> _reload() async {
    ref.read(storyRepositoryProvider).invalidate();
    setState(() {
      _items.clear();
      _page = 0;
      _hasMore = true;
      _firstLoad = true;
      _error = null;
    });
    await _loadPage(0, replace: true);
  }

  void _openItem(Item item) {
    if (ref.read(settingsProvider).settings.autoMarkRead) {
      ref.read(databaseProvider).markRead(item.id);
    }
    context.push('/item/${item.id}');
  }

  void _openLink(Item item) {
    final settings = ref.read(settingsProvider).settings;
    if (!isHttpUrl(item.url)) return;
    if (settings.externalBrowser) {
      openExternal(item.url);
    } else {
      context.push(
        '/reader?url=${Uri.encodeComponent(item.url!)}&title=${Uri.encodeComponent(item.title ?? '')}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider).settings;
    final title = widget.feedType.label(l10n);

    return Scaffold(
      drawer: AppDrawer(currentFeed: widget.feedType),
      appBar: AppBar(
        title: widget.feedType == FeedType.popular
            ? PopupMenuButton<PopularWindow>(
                tooltip: title,
                initialValue: settings.popularWindow,
                onSelected: (window) async {
                  await ref.read(settingsProvider).setPopularWindow(window);
                  await _reload();
                },
                itemBuilder: (context) => [
                  for (final window in PopularWindow.values)
                    PopupMenuItem(
                      value: window,
                      child: Text(window.label(l10n)),
                    ),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              )
            : Text(title),
        actions: [
          IconButton(
            tooltip: l10n.search,
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          PopupMenuButton<String>(
            tooltip: l10n.more,
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  _reload();
                case 'settings':
                  context.push('/settings');
                case 'login':
                  context.push('/login');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'refresh', child: Text(l10n.retry)),
              PopupMenuItem(value: 'settings', child: Text(l10n.settings)),
            ],
          ),
        ],
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_firstLoad && _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return _ErrorView(
        message: l10n.noConnection,
        retryLabel: l10n.retry,
        onRetry: _reload,
      );
    }
    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
            Center(child: Text(l10n.noResults)),
          ],
        ),
      );
    }

    return StreamBuilder<Set<int>>(
      stream: _readStream,
      builder: (context, snapshot) {
        final readIds = snapshot.data ?? const <int>{};
        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _items.length + 1,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index == _items.length) {
                return _Footer(loading: _loading, hasMore: _hasMore);
              }
              final item = _items[index];
              return StoryTile(
                item: item,
                isRead: readIds.contains(item.id),
                onTap: () => _openItem(item),
                onComments: () => _openItem(item),
                onOpenLink: item.hasUrl ? () => _openLink(item) : null,
                onProfile: item.by == null
                    ? null
                    : () => context.push('/user/${item.by}'),
              );
            },
          ),
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.loading, required this.hasMore});

  final bool loading;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (!hasMore) return const SizedBox(height: 32);
    return const SizedBox(height: 32);
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}
