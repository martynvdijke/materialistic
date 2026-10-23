import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:materialistic/core/utils/time_utils.dart';
import 'package:materialistic/l10n/app_localizations.dart';

void main() {
  setUpAll(() => initializeDateFormatting('en'));

  final l10n = AppLocalizations(const Locale('en'));

  test('formats very recent times as just now', () {
    expect(
      formatRelativeTime(
        DateTime.now().subtract(const Duration(seconds: 10)),
        l10n,
      ),
      l10n.justNow,
    );
  });

  test('formats minutes, hours and days', () {
    expect(
      formatRelativeTime(
        DateTime.now().subtract(const Duration(minutes: 5)),
        l10n,
      ),
      '5 ${l10n.minutesAgo}',
    );
    expect(
      formatRelativeTime(
        DateTime.now().subtract(const Duration(hours: 3)),
        l10n,
      ),
      '3 ${l10n.hoursAgo}',
    );
    expect(
      formatRelativeTime(
        DateTime.now().subtract(const Duration(days: 6)),
        l10n,
      ),
      '6 ${l10n.daysAgo}',
    );
  });

  test('falls back to an absolute date after a week', () {
    final date = DateTime.now().subtract(const Duration(days: 30));
    final formatted = formatRelativeTime(date, l10n);
    expect(formatted, isNot(contains(l10n.daysAgo)));
  });
}
