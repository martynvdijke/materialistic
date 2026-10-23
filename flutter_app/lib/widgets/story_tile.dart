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
