import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers.dart';
import '../../core/settings/settings_controller.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.watch(settingsProvider);
    final settings = controller.settings;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          _SectionHeader(l10n.appearance),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.theme),
            subtitle: Text(_themeLabel(settings.theme, l10n)),
            onTap: () => _pickTheme(context, controller, l10n),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.brightness_6_outlined),
            title: Text(l10n.system),
            subtitle: Text(l10n.general),
            value: settings.autoDayNight,
            onChanged: controller.setAutoDayNight,
          ),
          ListTile(
            leading: const Icon(Icons.format_size),
            title: Text(l10n.textSize),
            subtitle: Text(_textSizeLabel(settings.textSize, l10n)),
            onTap: () => _pickTextSize(context, controller, l10n),
          ),
          ListTile(
            leading: const Icon(Icons.font_download_outlined),
            title: Text(l10n.font),
            subtitle: Text(_fontLabel(settings.font, l10n)),
            onTap: () => _pickFont(context, controller, l10n),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: Text(l10n.launchScreen),
            subtitle: Text(_launchLabel(settings.launchScreen, l10n)),
            onTap: () => _pickLaunch(context, controller, l10n),
          ),
          const Divider(),
          _SectionHeader(l10n.behavior),
          SwitchListTile(
            secondary: const Icon(Icons.open_in_browser),
            title: Text(l10n.externalBrowser),
            value: settings.externalBrowser,
            onChanged: controller.setExternalBrowser,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.color_lens_outlined),
            title: Text(l10n.colorCode),
            value: settings.colorCode,
            onChanged: controller.setColorCode,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.account_tree_outlined),
            title: Text(l10n.threadIndicator),
            value: settings.threadIndicator,
            onChanged: controller.setThreadIndicator,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.swipe),
            title: Text(l10n.swipeActions),
            value: settings.swipeActions,
            onChanged: controller.setSwipeActions,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.visibility_outlined),
            title: Text(l10n.autoMarkRead),
            value: settings.autoMarkRead,
            onChanged: controller.setAutoMarkRead,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.downloading_outlined),
            title: Text(l10n.lazyLoad),
            value: settings.lazyLoad,
            onChanged: controller.setLazyLoad,
          ),
          const Divider(),
          _SectionHeader(l10n.data),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(l10n.clearReadHistory),
            onTap: () async {
              await ref.read(databaseProvider).clearRead();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(l10n.saved)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.search_off),
            title: Text(l10n.clearSearchHistory),
            onTap: () async {
              await ref.read(databaseProvider).clearSearchHistory();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(l10n.saved)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_border),
            title: Text(l10n.clearFavorites),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text(l10n.clearFavorites),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.delete),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(databaseProvider).clearFavorites();
              }
            },
          ),
          const Divider(),
          _SectionHeader(l10n.about),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.version),
            subtitle: const Text('3.4.0 (100)'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(l10n.sourceCode),
            subtitle: const Text('github.com/hidroh/materialistic'),
            onTap: () => launchUrl(
              Uri.parse('https://github.com/hidroh/materialistic'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(MaterialLocalizations.of(context).licensesPageTitle),
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.appName,
              applicationVersion: '3.4.0',
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _themeLabel(ThemeStyle value, AppLocalizations l10n) =>
      switch (value) {
        ThemeStyle.system => l10n.system,
        ThemeStyle.light => l10n.light,
        ThemeStyle.dark => l10n.dark,
        ThemeStyle.black => l10n.black,
        ThemeStyle.sepia => l10n.sepia,
        ThemeStyle.green => l10n.green,
        ThemeStyle.solarized => l10n.solarized,
        ThemeStyle.solarizedDark => l10n.solarizedDark,
      };

  String _textSizeLabel(TextSize value, AppLocalizations l10n) =>
      switch (value) {
        TextSize.extraSmall => l10n.extraSmall,
        TextSize.small => l10n.small,
        TextSize.normal => l10n.normal,
        TextSize.large => l10n.large,
        TextSize.extraLarge => l10n.extraLarge,
      };

  String _fontLabel(AppFont value, AppLocalizations l10n) => switch (value) {
    AppFont.system => l10n.fontDefault,
    AppFont.droidSans => 'Droid Sans',
    AppFont.droidSerif => l10n.fontSerif,
    AppFont.libreBaskerville => l10n.fontBaskerville,
    AppFont.robotoSlab => l10n.fontSlab,
  };

  String _launchLabel(LaunchScreen value, AppLocalizations l10n) {
    if (value == LaunchScreen.favorites) return l10n.favorites;
    if (value == LaunchScreen.last) return l10n.lastScreen;
    return value.feedType?.label(l10n) ?? l10n.top;
  }

  Future<void> _pickTheme(
    BuildContext context,
    SettingsController controller,
    AppLocalizations l10n,
  ) async {
    final selected = await _showPicker<ThemeStyle>(
      context,
      title: l10n.theme,
      values: ThemeStyle.values,
      current: controller.settings.theme,
      label: (value) => _themeLabel(value, l10n),
    );
    if (selected != null) await controller.setTheme(selected);
  }

  Future<void> _pickTextSize(
    BuildContext context,
    SettingsController controller,
    AppLocalizations l10n,
  ) async {
    final selected = await _showPicker<TextSize>(
      context,
      title: l10n.textSize,
      values: TextSize.values,
      current: controller.settings.textSize,
      label: (value) => _textSizeLabel(value, l10n),
    );
    if (selected != null) await controller.setTextSize(selected);
  }

  Future<void> _pickFont(
    BuildContext context,
    SettingsController controller,
    AppLocalizations l10n,
  ) async {
    final selected = await _showPicker<AppFont>(
      context,
      title: l10n.font,
      values: AppFont.values,
      current: controller.settings.font,
      label: (value) => _fontLabel(value, l10n),
    );
    if (selected != null) await controller.setFont(selected);
  }

  Future<void> _pickLaunch(
    BuildContext context,
    SettingsController controller,
    AppLocalizations l10n,
  ) async {
    final selected = await _showPicker<LaunchScreen>(
      context,
      title: l10n.launchScreen,
      values: LaunchScreen.values,
      current: controller.settings.launchScreen,
      label: (value) => _launchLabel(value, l10n),
    );
    if (selected != null) await controller.setLaunchScreen(selected);
  }

  Future<T?> _showPicker<T>(
    BuildContext context, {
    required String title,
    required List<T> values,
    required T current,
    required String Function(T value) label,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          RadioGroup<T>(
            groupValue: current,
            onChanged: (selected) => Navigator.pop(context, selected),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final value in values)
                  RadioListTile<T>(value: value, title: Text(label(value))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
