import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:materialistic/main.dart' as app;
import 'package:materialistic/widgets/story_tile.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('browse, open comments, search and open settings', (
    tester,
  ) async {
    app.main();

    await _waitFor(
      tester,
      find.byType(StoryTile),
      timeout: const Duration(seconds: 90),
    );
    expect(find.text('Top'), findsOneWidget);
    expect(find.byType(StoryTile), findsWidgets);

    // Open the first story and wait for its comment header.
    await tester.tap(find.byType(StoryTile).first);
    await _waitFor(
      tester,
      find.text('Upvote'),
      timeout: const Duration(seconds: 60),
    );
    expect(find.text('Reply'), findsWidgets);
    expect(find.text('Share'), findsWidgets);

    // Back to the feed.
    await tester.pageBack();
    await _waitFor(tester, find.byType(StoryTile));

    // Search against the live Algolia API.
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'flutter');
    await tester.tap(find.byTooltip('Search'));
    await _waitFor(
      tester,
      find.byType(StoryTile),
      timeout: const Duration(seconds: 90),
    );
    expect(find.byType(StoryTile), findsWidgets);

    // Back to the feed, then open settings.
    await tester.pageBack();
    await _waitFor(tester, find.byType(StoryTile));
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('APPEARANCE'), findsOneWidget);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();
    expect(find.text('APPEARANCE'), findsOneWidget);
  });
}

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  throw TestFailure('Timed out waiting for $finder');
}
