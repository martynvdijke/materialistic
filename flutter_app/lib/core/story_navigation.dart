import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import 'models/item.dart';
import 'providers.dart';
import 'settings/settings_controller.dart';
import 'utils/url_utils.dart';

/// Opens a story according to the user's default-open preference.
Future<void> openStory(BuildContext context, WidgetRef ref, Item item) async {
  final settings = ref.read(settingsProvider).settings;
  if (settings.autoMarkRead) {
    await ref.read(databaseProvider).markRead(item.id);
  }

  if (settings.storyDisplay == StoryDisplay.comments || !item.hasUrl) {
    if (context.mounted) context.push('/item/${item.id}');
    return;
  }

  if (settings.externalBrowser) {
    await openExternal(item.url);
    return;
  }

  if (!context.mounted) return;
  final readability = settings.storyDisplay == StoryDisplay.readability;
  context.push(
    '/reader?url=${Uri.encodeComponent(item.url!)}'
    '&title=${Uri.encodeComponent(item.title ?? '')}'
    '&reader=$readability',
  );
}

/// Opens the linked article regardless of the default-open preference.
Future<void> openStoryLink(
  BuildContext context,
  WidgetRef ref,
  Item item, {
  bool? readability,
}) async {
  if (!item.hasUrl) return;
  final settings = ref.read(settingsProvider).settings;
  if (settings.externalBrowser) {
    await openExternal(item.url);
    return;
  }
  if (!context.mounted) return;
  final useReader =
      readability ?? settings.storyDisplay == StoryDisplay.readability;
  context.push(
    '/reader?url=${Uri.encodeComponent(item.url!)}'
    '&title=${Uri.encodeComponent(item.title ?? '')}'
    '&reader=$useReader',
  );
}

/// Opens the comments for a story regardless of the default-open setting.
void openComments(BuildContext context, Item item) {
  context.push('/item/${item.id}');
}

Future<void> toggleFavorite(
  BuildContext context,
  WidgetRef ref,
  Item item,
) async {
  final database = ref.read(databaseProvider);
  final isFavorite = await database.isFavorite(item.id);
  if (isFavorite) {
    await database.removeFavorite(item.id);
  } else {
    await database.addFavorite(item);
  }
  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(isFavorite ? l10n.favoriteRemoved : l10n.favoriteAdded),
    ),
  );
}

Future<void> upvoteStory(BuildContext context, WidgetRef ref, Item item) async {
  final auth = ref.read(authControllerProvider);
  if (!auth.isLoggedIn) {
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
    return;
  }

  final success = await auth.vote(item);
  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(success ? l10n.saved : l10n.postingFailed)),
  );
}
