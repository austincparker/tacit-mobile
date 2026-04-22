@Tags(['accessibility'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_app_base/widgets/app_bars/default_app_bar.dart';
import 'package:flutter_test/flutter_test.dart';

import 'accessibility_test_helpers.dart';

void main() {
  group('AppBar Accessibility Tests', () {
    group('DefaultAppBar', () {
      late Widget testWidget;

      setUp(() {
        testWidget = Scaffold(
          appBar: const DefaultAppBar(
            title: 'Test Screen',
          ),
          body: const Center(
            child: Text('Test content'),
          ),
        );
      });

      testWidgets('[Level-A] meets labeled tap target guideline', (WidgetTester tester) async {
        await AccessibilityTestHelpers.testScreenMeetsLevelAGuidelines(
          tester,
          testWidget,
        );
      });

      testWidgets('[Level-AA] meets contrast and tap target size guidelines', (WidgetTester tester) async {
        await AccessibilityTestHelpers.testScreenMeetsLevelAAGuidelines(
          tester,
          testWidget,
        );
      });

      testWidgets('[Level-A] title has proper header semantics', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(
          MaterialApp(
            home: testWidget,
          ),
        );

        final titleText = find.text('Test Screen');
        expect(titleText, findsOneWidget);

        final titleSemantics = tester.getSemantics(titleText);
        expect(titleSemantics, matchesSemantics(isHeader: true));

        handle.dispose();
      });

      testWidgets('[Level-A] actions are accessible', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(
          MaterialApp(
            home: testWidget,
          ),
        );

        AccessibilityTestHelpers.verifyButtonsHaveLabels(tester);

        handle.dispose();
      });
    });
  });
}
