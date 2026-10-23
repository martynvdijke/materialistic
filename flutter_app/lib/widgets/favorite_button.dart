import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/item.dart';
import '../core/providers.dart';
import '../l10n/app_localizations.dart';

class FavoriteButton extends ConsumerStatefulWidget {
  const FavoriteButton({super.key, required this.item, this.compact = true});

  final Item item;
  final bool compact;

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton> {
  bool? _favorite;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) _load();
  }

  Future<void> _load() async {
    final value = await ref.read(databaseProvider).isFavorite(widget.item.id);
    if (mounted) setState(() => _favorite = value);
  }

  Future<void> _toggle() async {
    final database = ref.read(databaseProvider);
    final isFavorite = await database.isFavorite(widget.item.id);
    if (isFavorite) {
      await database.removeFavorite(widget.item.id);
    } else {
      await database.addFavorite(widget.item);
    }
    if (!mounted) return;
    setState(() => _favorite = !isFavorite);
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFavorite ? l10n.favoriteRemoved : l10n.favoriteAdded),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorite = _favorite ?? false;
    final l10n = AppLocalizations.of(context);
    return IconButton(
      tooltip: favorite ? l10n.removeFavorite : l10n.addFavorite,
      visualDensity: widget.compact ? VisualDensity.compact : null,
      icon: Icon(favorite ? Icons.bookmark : Icons.bookmark_border),
      color: favorite ? Theme.of(context).colorScheme.primary : null,
      onPressed: _toggle,
    );
  }
}
