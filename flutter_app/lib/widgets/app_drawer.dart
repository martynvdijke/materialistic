import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../features/feed/feed_type.dart';
import '../l10n/app_localizations.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key, required this.currentFeed});

  final FeedType currentFeed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final auth = ref.watch(authControllerProvider);

    void closeThenGo(String location, {bool push = false}) {
      Scaffold.of(context).closeDrawer();
      if (push) {
        context.push(location);
      } else {
        context.go(location);
      }
    }

    return NavigationDrawer(
      selectedIndex: currentFeed.index,
      onDestinationSelected: (index) {
        closeThenGo('/feed/${FeedType.values[index].path}');
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.appName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Hacker News',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        for (final type in FeedType.values)
          NavigationDrawerDestination(
            icon: Icon(type.icon),
            selectedIcon: Icon(type.icon),
            label: Text(type.label(l10n)),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Divider(),
        ),
        ListTile(
          leading: const Icon(Icons.bookmark_border),
          title: Text(l10n.favorites),
          onTap: () => closeThenGo('/favorites', push: true),
        ),
        ListTile(
          leading: const Icon(Icons.search),
          title: Text(l10n.search),
          onTap: () => closeThenGo('/search', push: true),
        ),
        ListTile(
          leading: const Icon(Icons.add_circle_outline),
          title: Text(l10n.submit),
          onTap: () => closeThenGo('/submit', push: true),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Divider(),
        ),
        if (auth.isLoggedIn)
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(auth.username ?? l10n.account),
            subtitle: Text(l10n.profile),
            onTap: () => closeThenGo('/user/${auth.username}', push: true),
          )
        else
          ListTile(
            leading: const Icon(Icons.login),
            title: Text(l10n.login),
            onTap: () => closeThenGo('/login', push: true),
          ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: Text(l10n.settings),
          onTap: () => closeThenGo('/settings', push: true),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.about),
          onTap: () {
            Scaffold.of(context).closeDrawer();
            showAboutDialog(
              context: context,
              applicationName: l10n.appName,
              applicationVersion: '3.4.0',
              applicationLegalese: 'Apache License 2.0',
            );
          },
        ),
      ],
    );
  }
}
