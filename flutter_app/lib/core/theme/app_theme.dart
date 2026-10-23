import 'package:flutter/material.dart';

import '../settings/settings_controller.dart';

/// Builds the seven color families inherited from the native app.
abstract final class AppTheme {
  static const _hnOrange = Color(0xFFFF6600);

  static ThemeData build({required ThemeStyle style, required AppFont font}) {
    final light = switch (style) {
      ThemeStyle.light || ThemeStyle.system => true,
      ThemeStyle.dark || ThemeStyle.black || ThemeStyle.solarizedDark => false,
      ThemeStyle.sepia || ThemeStyle.green || ThemeStyle.solarized => true,
    };

    final scheme = switch (style) {
      ThemeStyle.light || ThemeStyle.system => _lightScheme(),
      ThemeStyle.dark => _darkScheme(),
      ThemeStyle.black => _blackScheme(),
      ThemeStyle.sepia => _sepiaScheme(),
      ThemeStyle.green => _greenScheme(),
      ThemeStyle.solarized => _solarizedScheme(dark: false),
      ThemeStyle.solarizedDark => _solarizedScheme(dark: true),
    };

    final background = switch (style) {
      ThemeStyle.black => Colors.black,
      ThemeStyle.sepia => const Color(0xFFF4ECD8),
      ThemeStyle.green => const Color(0xFFE8F5E9),
      ThemeStyle.solarized => const Color(0xFFFDF6E3),
      ThemeStyle.solarizedDark => const Color(0xFF002B36),
      _ => scheme.surface,
    };
    final textColor = scheme.onSurface;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: light ? Brightness.light : Brightness.dark,
      scaffoldBackgroundColor: background,
      fontFamily: font.family,
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
        fontFamily: font.family,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontFamily: font.family,
        ),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: background,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        space: 1,
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: textColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide.none,
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
      ),
    );
  }

  static ColorScheme _lightScheme() {
    final scheme = ColorScheme.fromSeed(seedColor: _hnOrange);
    return scheme.copyWith(
      primary: _hnOrange,
      onPrimary: Colors.white,
      surface: const Color(0xFFFDFBF7),
      onSurface: const Color(0xFF1F1B16),
      surfaceContainerHighest: const Color(0xFFF0E9E1),
      outlineVariant: const Color(0xFFE3D9CE),
    );
  }

  static ColorScheme _darkScheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _hnOrange,
      brightness: Brightness.dark,
    );
    return scheme.copyWith(
      primary: const Color(0xFFFF9A5C),
      onPrimary: const Color(0xFF4A2000),
      surface: const Color(0xFF161310),
      onSurface: const Color(0xFFEDE1D7),
      surfaceContainerHighest: const Color(0xFF2B2621),
      outlineVariant: const Color(0xFF3A332C),
    );
  }

  static ColorScheme _blackScheme() {
    final scheme = _darkScheme();
    return scheme.copyWith(
      surface: Colors.black,
      onSurface: const Color(0xFFE8E8E8),
      surfaceContainerHighest: const Color(0xFF1A1A1A),
      outlineVariant: const Color(0xFF2A2A2A),
      primary: const Color(0xFFFF9A5C),
    );
  }

  static ColorScheme _sepiaScheme() {
    return ColorScheme.fromSeed(
      seedColor: const Color(0xFF8D6E63),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF7A5C3E),
      onPrimary: Colors.white,
      surface: const Color(0xFFF4ECD8),
      onSurface: const Color(0xFF4E3B2A),
      surfaceContainerHighest: const Color(0xFFE9DFC8),
      outlineVariant: const Color(0xFFD8CBB1),
    );
  }

  static ColorScheme _greenScheme() {
    return ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D32),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF2E7D32),
      surface: const Color(0xFFF1F8F1),
      onSurface: const Color(0xFF1B2E1C),
      surfaceContainerHighest: const Color(0xFFDDEDDD),
      outlineVariant: const Color(0xFFC3DDC3),
    );
  }

  static ColorScheme _solarizedScheme({required bool dark}) {
    if (dark) {
      return ColorScheme.fromSeed(
        seedColor: const Color(0xFF268BD2),
        brightness: Brightness.dark,
      ).copyWith(
        primary: const Color(0xFF6FC3E8),
        onPrimary: const Color(0xFF002B36),
        surface: const Color(0xFF002B36),
        onSurface: const Color(0xFF93A1A1),
        surfaceContainerHighest: const Color(0xFF073642),
        outlineVariant: const Color(0xFF0F4B58),
      );
    }
    return ColorScheme.fromSeed(
      seedColor: const Color(0xFF268BD2),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF1E6FA8),
      surface: const Color(0xFFFDF6E3),
      onSurface: const Color(0xFF586E75),
      surfaceContainerHighest: const Color(0xFFEEE8D5),
      outlineVariant: const Color(0xFFE0D8C0),
    );
  }
}
