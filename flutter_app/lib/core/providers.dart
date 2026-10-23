import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/app_database.dart';
import 'network/algolia_api.dart';
import 'network/hn_api.dart';
import 'network/hn_auth_service.dart';
import 'settings/settings_controller.dart';
import '../../features/account/auth_controller.dart';
import '../../features/feed/story_repository.dart';
import '../../features/item/comment_repository.dart';

/// Overridden in `main` with an already-loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences not initialized'),
);

final settingsProvider = ChangeNotifierProvider<SettingsController>(
  (ref) => SettingsController(ref.watch(sharedPreferencesProvider)),
);

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final hnApiProvider = Provider<HnApi>((ref) => HnApi());

final algoliaApiProvider = Provider<AlgoliaApi>((ref) => AlgoliaApi());

final storyRepositoryProvider = Provider<StoryRepository>(
  (ref) => StoryRepository(
    hnApi: ref.watch(hnApiProvider),
    algoliaApi: ref.watch(algoliaApiProvider),
  ),
);

final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(hnApi: ref.watch(hnApiProvider)),
);

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  final controller = AuthController(
    HnAuthService(),
    ref.watch(secureStorageProvider),
    ref.watch(sharedPreferencesProvider),
  );
  controller.restore();
  return controller;
});
