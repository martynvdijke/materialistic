import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';

import 'app.dart';
import 'core/providers.dart';
import 'src/telemetry/telemetry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    initializeDateFormatting('en'),
    initializeDateFormatting('es'),
    initializeDateFormatting('zh_CN'),
  ]);
  final tempDirectory = await getTemporaryDirectory();
  sqlite3.tempDirectory = tempDirectory.path;
  final preferences = await SharedPreferences.getInstance();

  // Telemetry is configured at build time with --dart-define; it is a no-op
  // unless an OTLP endpoint was compiled in. Never block startup on it.
  unawaited(Telemetry.instance.start());

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const MaterialisticApp(),
    ),
  );
}
