import 'package:flutter/material.dart';

import '../core/models/item.dart';
import '../core/utils/time_utils.dart';
import '../l10n/app_localizations.dart';
import 'favorite_button.dart';

class StoryTile extends StatelessWidget {
  const StoryTile({
    super.key,
    required this.item,
    required this.isRead,
    required this.onTap,
    this.onOpenLink,
    this.onComments,
    this.onProfile,
    this.highlighted = false,
    this.swipeActions = false,
    this.onSwipeSave,
    this.onSwipeVote,
  });

  final Item item;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback? onOpenLink;
  final VoidCallback? onComments;
  final VoidCallback? onProfile;
  final bool highlighted;
  final bool swipeActions;
  final Future<void> Function()? onSwipeSave;
  final Future<void> Function()? onSwipeVote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = _StoryTileContent(
      item: item,
      isRead: isRead,
      onTap: onTap,
      onOpenLink: onOpenLink,
      onComments: onComments,
      onProfile: onProfile,
    );
    final decorated = highlighted
        ? ColoredBox(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: content,
          )
        : content;

    if (!swipeActions) return decorated;
    final l10n = AppLocalizations.of(context);
    return Dismissible(
      key: ValueKey('story-${item.id}'),
      direction: DismissDirection.horizontal,
      background: _SwipeBackground(
        alignment: Alignment.centerLeft,
        icon: Icons.arrow_upward,
        label: l10n.upvote,
        color: theme.colorScheme.secondaryContainer,
        foreground: theme.colorScheme.onSecondaryContainer,
      ),
      secondaryBackground: _SwipeBackground(
        alignment: Alignment.centerRight,
        icon: Icons.bookmark_add_outlined,
        label: l10n.save,
        color: theme.colorScheme.tertiaryContainer,
        foreground: theme.colorScheme.onTertiaryContainer,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await onSwipeVote?.call();
        } else {
          await onSwipeSave?.call();
        }
        return false;
      },
      child: decorated,
    );
  }
}

class _StoryTileContent extends StatelessWidget {
  const _StoryTileContent({
    required this.item,
    required this.isRead,
    required this.onTap,
    required this.onOpenLink,
    required this.onComments,
    required this.onProfile,
  });

  final Item item;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback? onOpenLink;
  final VoidCallback? onComments;
  final VoidCallback? onProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final titleColor = isRead ? muted : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title ?? l10n.unknown,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                      height: 1.25,
                      decoration: isRead ? TextDecoration.none : null,
                    ),
                  ),
                ),
                FavoriteButton(item: item),
              ],
            ),
            if (item.domain != null) ...[
              const SizedBox(height: 4),
              InkWell(
                onTap: onOpenLink,
                child: Text(
                  '(${item.domain})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: muted,
                    decoration: TextDecoration.underline,
                    decorationColor: muted,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 14,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${item.score} ${l10n.points}',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                if (item.by != null)
                  InkWell(
                    onTap: onProfile,
                    child: Text(
                      '${l10n.by} ${item.by}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: muted,
                        decoration: TextDecoration.underline,
                        decorationColor: muted,
                      ),
                    ),
                  ),
                Text(
                  formatRelativeTime(item.createdAt, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                InkWell(
                  onTap: onComments,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 14, color: muted),
                      const SizedBox(width: 4),
                      Text(
                        '${item.descendants}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.icon,
    required this.label,
    required this.color,
    required this.foreground,
  });

  final Alignment alignment;
  final IconData icon;
  final String label;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
