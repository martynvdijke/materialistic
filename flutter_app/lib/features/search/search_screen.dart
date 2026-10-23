import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/models/item.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/story_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _results = <Item>[];
  late final Stream<List<SearchHistoryRow>> _historyStream;
  String _query = '';
  bool _byDate = false;
  bool _loading = false;
  bool _searched = false;
  bool _hasMore = true;
  int _page = 0;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _historyStream = ref.read(databaseProvider).watchSearchHistory();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 600) _loadMore();
  }

  Future<void> _search(String value, {bool reset = true}) async {
    final query = value.trim();
    if (query.isEmpty) return;
    if (reset) {
      setState(() {
        _query = query;
        _results.clear();
        _page = 0;
        _hasMore = true;
        _searched = true;
        _error = null;
      });
      await ref.read(databaseProvider).addSearch(query);
    }
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final ids = await ref
          .read(storyRepositoryProvider)
          .searchIds(query: _query, byDate: _byDate, page: _page);
      final items = await ref.read(storyRepositoryProvider).items(ids);
      if (!mounted) return;
      setState(() {
        _results.addAll(items);
        _page++;
        _hasMore = ids.isNotEmpty;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  void _loadMore() {
    if (_loading || !_hasMore || !_searched) return;
    _search(_query, reset: false);
  }

  Future<void> _toggleSort() async {
    setState(() => _byDate = !_byDate);
    if (_searched) await _search(_query);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
            filled: false,
          ),
          onSubmitted: _search,
        ),
        actions: [
          IconButton(
            tooltip: _byDate ? l10n.sortRecent : l10n.sortRelevant,
            icon: Icon(_byDate ? Icons.schedule : Icons.sort),
            onPressed: _toggleSort,
          ),
          IconButton(
            tooltip: l10n.search,
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => _search(_controller.text),
          ),
        ],
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (!_searched) {
      return StreamBuilder<List<SearchHistoryRow>>(
        stream: _historyStream,
        builder: (context, snapshot) {
          final history = snapshot.data ?? const [];
          if (history.isEmpty) {
            return Center(child: Text(l10n.emptyHistory));
          }
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.searchHistory,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.read(databaseProvider).clearSearchHistory(),
                      child: Text(l10n.clearSearchHistory),
                    ),
                  ],
                ),
              ),
              for (final row in history)
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(row.query),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: l10n.delete,
                    onPressed: () =>
                        ref.read(databaseProvider).removeSearch(row.query),
                  ),
                  onTap: () {
                    _controller.text = row.query;
                    _search(row.query);
                  },
                ),
            ],
          );
        },
      );
    }

    if (_loading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            Text(l10n.noConnection),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _search(_query),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(child: Text(l10n.noResults));
    }

    return ListView.separated(
      controller: _scrollController,
      itemCount: _results.length + 1,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == _results.length) {
          return _loading
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox(height: 24);
        }
        final item = _results[index];
        return StoryTile(
          item: item,
          isRead: false,
          onTap: () => context.push('/item/${item.id}'),
          onComments: () => context.push('/item/${item.id}'),
          onOpenLink: item.hasUrl
              ? () => context.push(
                  '/reader?url=${Uri.encodeComponent(item.url!)}&title=${Uri.encodeComponent(item.title ?? '')}',
                )
              : null,
          onProfile: item.by == null
              ? null
              : () => context.push('/user/${item.by}'),
        );
      },
    );
  }
}
