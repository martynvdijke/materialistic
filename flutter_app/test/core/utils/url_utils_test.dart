import 'package:flutter_test/flutter_test.dart';
import 'package:materialistic/core/utils/url_utils.dart';

void main() {
  group('isHttpUrl', () {
    test('accepts absolute http and https URLs', () {
      expect(isHttpUrl('https://example.com'), isTrue);
      expect(isHttpUrl('http://example.com/path?q=1'), isTrue);
    });

    test('rejects anything else', () {
      expect(isHttpUrl(null), isFalse);
      expect(isHttpUrl(''), isFalse);
      expect(isHttpUrl('example.com'), isFalse);
      expect(isHttpUrl('mailto:a@example.com'), isFalse);
      expect(isHttpUrl('https://'), isFalse);
    });
  });

  group('normalizeUrl', () {
    test('keeps absolute URLs and trims whitespace', () {
      expect(normalizeUrl(' https://example.com '), 'https://example.com');
      expect(normalizeUrl('http://example.com'), 'http://example.com');
    });

    test('adds https to bare hosts', () {
      expect(normalizeUrl('example.com'), 'https://example.com');
      expect(normalizeUrl('example.com/a b'), 'https://example.com/a b');
    });

    test('leaves empty input empty', () {
      expect(normalizeUrl('   '), '');
    });
  });
}
