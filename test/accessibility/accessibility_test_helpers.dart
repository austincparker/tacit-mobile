import 'package:flutter/material.dart';
import 'package:flutter_app_base/flavors.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class for accessibility testing utilities
class AccessibilityTestHelpers {
  /// Initialize flavor for tests (only if not already initialized)
  static void initializeFlavor() {
    try {
      F.appFlavor;
    } catch (_) {
      F.appFlavor = Flavor.staging;
    }
  }

  /// Verify WCAG 2.2 Level A guidelines only
  /// - labeledTapTargetGuideline (WCAG 1.1.1 Non-text Content)
  static Future<void> verifyLevelAGuidelines(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  }

  /// Verify WCAG 2.2 Level AA guidelines only
  /// - textContrastGuideline (WCAG 1.4.3 Contrast Minimum)
  /// - androidTapTargetGuideline (WCAG 2.5.8 Target Size)
  /// - iOSTapTargetGuideline (WCAG 2.5.8 Target Size)
  static Future<void> verifyLevelAAGuidelines(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  }

  /// Private helper that handles semantics setup, widget pumping, verification,
  /// and cleanup. All public test methods delegate to this.
  static Future<void> _testWidgetAccessibility(
    WidgetTester tester,
    Widget widget, {
    bool wrapInScaffold = true,
    Duration? pumpDelay,
    required Future<void> Function(WidgetTester) verify,
  }) async {
    final handle = tester.ensureSemantics();

    final home = wrapInScaffold ? Scaffold(body: widget) : widget;

    await tester.pumpWidget(
      MaterialApp(home: home),
    );

    if (pumpDelay != null) {
      await tester.pump();
      await tester.pump(pumpDelay);
    } else {
      await tester.pump();
    }

    await verify(tester);

    handle.dispose();
  }

  /// Test a widget meets Level A guidelines
  static Future<void> testMeetsLevelAGuidelines(
    WidgetTester tester,
    Widget widget, {
    Duration? pumpDelay,
  }) =>
      _testWidgetAccessibility(
        tester,
        widget,
        pumpDelay: pumpDelay,
        verify: verifyLevelAGuidelines,
      );

  /// Test a screen meets Level A guidelines
  static Future<void> testScreenMeetsLevelAGuidelines(
    WidgetTester tester,
    Widget screen, {
    Duration? pumpDelay,
  }) =>
      _testWidgetAccessibility(
        tester,
        screen,
        wrapInScaffold: false,
        pumpDelay: pumpDelay,
        verify: verifyLevelAGuidelines,
      );

  /// Test a widget meets Level AA guidelines
  static Future<void> testMeetsLevelAAGuidelines(
    WidgetTester tester,
    Widget widget, {
    Duration? pumpDelay,
  }) =>
      _testWidgetAccessibility(
        tester,
        widget,
        pumpDelay: pumpDelay,
        verify: verifyLevelAAGuidelines,
      );

  /// Test a screen meets Level AA guidelines
  static Future<void> testScreenMeetsLevelAAGuidelines(
    WidgetTester tester,
    Widget screen, {
    Duration? pumpDelay,
  }) =>
      _testWidgetAccessibility(
        tester,
        screen,
        wrapInScaffold: false,
        pumpDelay: pumpDelay,
        verify: verifyLevelAAGuidelines,
      );

  /// Verify all buttons have proper semantic labels
  static void verifyButtonsHaveLabels(WidgetTester tester) {
    final buttons = find.byType(TextButton);
    if (buttons.evaluate().isEmpty) {
      return; // No buttons to check
    }

    final buttonCount = buttons.evaluate().length;
    for (var i = 0; i < buttonCount; i++) {
      final buttonFinder = buttons.at(i);
      final semantics = tester.getSemantics(buttonFinder);
      expect(
        semantics.label,
        isNotEmpty,
        reason: 'All buttons must have labels',
      );
    }
  }

  /// Verify all text fields have proper semantic properties
  static void verifyTextFieldsHaveLabels(WidgetTester tester) {
    final textFields = find.byType(TextField);
    if (textFields.evaluate().isEmpty) {
      return; // No text fields to check
    }

    final fieldCount = textFields.evaluate().length;
    for (var i = 0; i < fieldCount; i++) {
      final fieldFinder = textFields.at(i);
      final semantics = tester.semantics.find(fieldFinder);
      expect(
        semantics.label,
        isNotEmpty,
        reason: 'All text fields must have labels',
      );
    }
  }

  /// Verify all images have proper semantic labels
  static void verifyImagesHaveLabels(WidgetTester tester, {Type? imageType}) {
    // Check for Image widgets (or specified image type like CachedNetworkImage)
    final images = imageType != null ? find.byType(imageType) : find.byType(Image);
    if (images.evaluate().isEmpty) {
      return; // No images to check
    }

    final imageCount = images.evaluate().length;
    for (var i = 0; i < imageCount; i++) {
      final imageFinder = images.at(i);
      final semantics = tester.getSemantics(imageFinder);
      expect(
        semantics.label,
        isNotEmpty,
        reason: 'All images must have semantic labels',
      );
      expect(
        semantics,
        matchesSemantics(isImage: true),
        reason: 'All images must have image role',
      );
    }
  }
}
