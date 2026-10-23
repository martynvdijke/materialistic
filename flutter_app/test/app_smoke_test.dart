import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:materialistic/app.dart';
import 'package:materialistic/core/database/app_database.dart';
import 'package:materialistic/core/models/item.dart';
import 'package:materialistic/core/network/hn_api.dart';
import 'package:materialistic/core/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() => initializeDateFormatting('en'));

  testWidgets('opens the top feed and renders a story', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          databaseProvider.overrideWithValue(database),
          hnApiProvider.overrideWithValue(_FakeHnApi()),
        ],
        child: const MaterialisticApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Top'), findsOneWidget);
    expect(find.text('Flutter on Hacker News'), findsOneWidget);
    expect(find.text('(example.com)'), findsOneWidget);

    // Let Drift's stream-cancel timer fire before the test checks for leaks.
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
  });
}

class _FakeHnApi extends HnApi {
  @override
  Future<List<int>> fetchFeedIds({required String endpoint}) async => [1];

  @override
  Future<List<Item>> fetchItems(Iterable<int> ids) async => [
    Item(
      id: 1,
      title: 'Flutter on Hacker News',
      url: 'https://example.com/story',
      by: 'alice',
      type: 'story',
      score: 42,
      descendants: 3,
      time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    ),
  ];

  @override
  Future<Item?> fetchItem(int id) async => (await fetchItems([id])).first;
}
