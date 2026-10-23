import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

String formatRelativeTime(DateTime date, AppLocalizations l10n) {
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 1) return l10n.justNow;
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} ${l10n.minutesAgo}';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours} ${l10n.hoursAgo}';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays} ${l10n.daysAgo}';
  }
  return DateFormat.yMMMd(l10n.locale.toString()).format(date);
}

String formatAbsoluteTime(DateTime date) {
  return DateFormat.yMMMd().add_jm().format(date);
}
