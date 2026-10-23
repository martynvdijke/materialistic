import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers.dart';
import 'settings/settings_controller.dart';
import '../features/account/login_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/feed/feed_screen.dart';
import '../features/feed/feed_type.dart';
import '../features/item/item_screen.dart';
import '../features/profile/user_screen.dart';
import '../features/reader/reader_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/submit/submit_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final settings = ref.read(settingsProvider).settings;
  final initialLocation = switch (settings.launchScreen) {
    LaunchScreen.favorites => '/favorites',
    LaunchScreen.last => '/feed/top',
    final screen => '/feed/${screen.feedType?.path ?? FeedType.top.path}',
  };

  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/feed/top'),
      GoRoute(
        path: '/feed/:type',
        builder: (context, state) => FeedScreen(
          feedType: FeedType.fromPath(state.pathParameters['type'] ?? 'top'),
        ),
      ),
      GoRoute(
        path: '/item/:id',
        builder: (context, state) => ItemScreen(
          itemId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/submit',
        builder: (context, state) => const SubmitScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/user/:username',
        builder: (context, state) =>
            UserScreen(username: state.pathParameters['username'] ?? ''),
      ),
      GoRoute(
        path: '/reader',
        builder: (context, state) => ReaderScreen(
          url: state.uri.queryParameters['url'] ?? '',
          title: state.uri.queryParameters['title'],
        ),
      ),
    ],
    errorBuilder: (context, state) => const FeedScreen(feedType: FeedType.top),
  );
});
