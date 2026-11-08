import 'package:flutter_test/flutter_test.dart';
import 'package:materialistic/core/share_intent.dart';

void main() {
  test('extracts a shared link and trailing title', () {
    final parsed = ShareIntentService.parse(
      'A shared story https://example.com/article?x=1',
    );
    expect(parsed.url, 'https://example.com/article?x=1');
    expect(parsed.title, 'A shared story');
    expect(parsed.text, isNull);
  });

  test('treats text without a link as submission text', () {
    final parsed = ShareIntentService.parse('Ask HN: what are you building?');
    expect(parsed.url, isNull);
    expect(parsed.text, 'Ask HN: what are you building?');
    expect(parsed.title, isNull);
  });

  test('ignores blank shares', () {
    final parsed = ShareIntentService.parse('   ');
    expect(parsed.url, isNull);
    expect(parsed.text, isNull);
    expect(parsed.title, isNull);
  });
}
