import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// The story lists exposed by the app.
enum FeedType {
  top,
  newest,
  best,
  ask,
  show,
  jobs,
  popular;

  String get path => switch (this) {
    FeedType.top => 'top',
    FeedType.newest => 'new',
    FeedType.best => 'best',
    FeedType.ask => 'ask',
    FeedType.show => 'show',
    FeedType.jobs => 'jobs',
    FeedType.popular => 'popular',
  };

  String label(AppLocalizations l10n) => switch (this) {
    FeedType.top => l10n.top,
    FeedType.newest => l10n.newest,
    FeedType.best => l10n.best,
    FeedType.ask => l10n.ask,
    FeedType.show => l10n.show,
    FeedType.jobs => l10n.jobs,
    FeedType.popular => l10n.popular,
  };

  IconData get icon => switch (this) {
    FeedType.top => Icons.trending_up,
    FeedType.newest => Icons.schedule,
    FeedType.best => Icons.star_outline,
    FeedType.ask => Icons.help_outline,
    FeedType.show => Icons.visibility_outlined,
    FeedType.jobs => Icons.work_outline,
    FeedType.popular => Icons.local_fire_department_outlined,
  };

  static FeedType fromPath(String value) => values.firstWhere(
    (type) => type.path == value,
    orElse: () => FeedType.top,
  );
}

/// Popular stories time window.
enum PopularWindow {
  day,
  week,
  month,
  year;

  Duration get duration => switch (this) {
    PopularWindow.day => const Duration(days: 1),
    PopularWindow.week => const Duration(days: 7),
    PopularWindow.month => const Duration(days: 30),
    PopularWindow.year => const Duration(days: 365),
  };

  String label(AppLocalizations l10n) => switch (this) {
    PopularWindow.day => l10n.lastDay,
    PopularWindow.week => l10n.lastWeek,
    PopularWindow.month => l10n.lastMonth,
    PopularWindow.year => l10n.lastYear,
  };
}
