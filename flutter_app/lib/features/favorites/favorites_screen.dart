import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final _filter = TextEditingController();

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  Future<void> _export(List<FavoriteRow> rows) async {
    if (rows.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(row.title);
      if (row.url != null && row.url!.isNotEmpty) buffer.writeln(row.url);
      buffer.writeln('https://news.ycombinator.com/item?id=${row.itemId}');
      buffer.writeln();
    }
    await SharePlus.instance.share(
      ShareParams(text: buffer.toString(), subject: l10n.exportFavorites),
    );
  }

  Future<void> _clear() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearFavorites),
        content: Text(l10n.clearFavorites),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(databaseProvider).clearFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return StreamBuilder<List<FavoriteRow>>(
      stream: ref.read(databaseProvider).watchFavorites(),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const <FavoriteRow>[];
        final query = _filter.text.toLowerCase();
        final filtered = query.isEmpty
            ? rows
            : rows
                  .where(
                    (row) =>
                        row.title.toLowerCase().contains(query) ||
                        (row.url?.toLowerCase().contains(query) ?? false),
                  )
                  .toList(growable: false);
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.favorites),
            actions: [
              IconButton(
                tooltip: l10n.exportFavorites,
                icon: const Icon(Icons.ios_share),
                onPressed: rows.isEmpty ? null : () => _export(rows),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'clear') _clear();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'clear',
                    child: Text(l10n.clearFavorites),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              if (rows.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: _filter,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: l10n.search,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _filter.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _filter.clear();
                                setState(() {});
                              },
                            ),
                    ),
                  ),
                ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          rows.isEmpty ? l10n.emptyFavorites : l10n.noResults,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final row = filtered[index];
                          return ListTile(
                            title: Text(
                              row.title.isEmpty ? l10n.unknown : row.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              row.url ?? '${l10n.story} ${row.itemId}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              tooltip: l10n.removeFavorite,
                              icon: const Icon(Icons.bookmark_remove_outlined),
                              onPressed: () => ref
                                  .read(databaseProvider)
                                  .removeFavorite(row.itemId),
                            ),
                            onTap: () => context.push('/item/${row.itemId}'),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
