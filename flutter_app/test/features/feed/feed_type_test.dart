import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:materialistic/features/feed/feed_type.dart';
import 'package:materialistic/l10n/app_localizations.dart';

void main() {
  test('every feed type has a unique path and round-trips', () {
    final paths = <String>{};
    for (final type in FeedType.values) {
      expect(paths.add(type.path), isTrue);
      expect(FeedType.fromPath(type.path), type);
    }
  });

  test('feed labels are localized', () {
    final l10n = AppLocalizations(const Locale('en'));
    for (final type in FeedType.values) {
      expect(type.label(l10n), isNotEmpty);
      expect(type.icon, isA<IconData>());
    }
  });

  test('popular windows map to decreasing durations', () {
    final durations = PopularWindow.values.map((w) => w.duration).toList();
    for (var i = 1; i < durations.length; i++) {
      expect(durations[i] > durations[i - 1], isTrue);
    }
  });
}
