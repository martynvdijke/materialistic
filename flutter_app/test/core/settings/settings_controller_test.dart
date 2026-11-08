import 'package:flutter_test/flutter_test.dart';
import 'package:materialistic/core/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('matches native preference defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = SettingsController(preferences);

    expect(controller.settings.autoMarkRead, isFalse);
    expect(controller.settings.colorCode, isTrue);
    expect(controller.settings.threadIndicator, isTrue);
    expect(controller.settings.highlightUpdated, isTrue);
    expect(controller.settings.adBlock, isTrue);
    expect(controller.settings.lazyLoad, isTrue);
    expect(controller.settings.lineSpacing, LineSpacing.normal);
    expect(controller.settings.maxCommentLines, CommentMaxLines.full);
    expect(controller.settings.storyDisplay, StoryDisplay.article);
  });

  test('loads legacy preference keys', () async {
    SharedPreferences.setMockInitialValues({
      'pref_line_height': '1.2',
      'pref_max_lines': '4',
      'pref_story_display': 'readability',
      'pref_highlight_updated': false,
      'pref_ad_block': false,
      'pref_auto_viewed': true,
    });
    final preferences = await SharedPreferences.getInstance();
    final controller = SettingsController(preferences);

    expect(controller.settings.lineSpacing, LineSpacing.cozy);
    expect(controller.settings.maxCommentLines, CommentMaxLines.four);
    expect(controller.settings.storyDisplay, StoryDisplay.readability);
    expect(controller.settings.highlightUpdated, isFalse);
    expect(controller.settings.adBlock, isFalse);
    expect(controller.settings.autoMarkRead, isTrue);
  });

  test('persists changed display preferences', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = SettingsController(preferences);

    await controller.setLineSpacing(LineSpacing.comfortable);
    await controller.setMaxCommentLines(CommentMaxLines.three);
    await controller.setStoryDisplay(StoryDisplay.comments);
    await controller.setHighlightUpdated(false);
    await controller.setAdBlock(false);

    final reloaded = SettingsController(preferences);
    expect(reloaded.settings.lineSpacing, LineSpacing.comfortable);
    expect(reloaded.settings.maxCommentLines, CommentMaxLines.three);
    expect(reloaded.settings.storyDisplay, StoryDisplay.comments);
    expect(reloaded.settings.highlightUpdated, isFalse);
    expect(reloaded.settings.adBlock, isFalse);
  });
}
