@Tags(['accessibility'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_app_base/widgets/buttons/critic_report_button.dart';
import 'package:flutter_test/flutter_test.dart';

import 'accessibility_test_helpers.dart';

void main() {
  group('Button Accessibility Tests', () {
    group('CriticReportButton', () {
      late Widget testWidget;

      setUp(() {
        testWidget = Scaffold(
          appBar: AppBar(
            title: const Text('Test'),
            actions: const [
              CriticReportButton(),
            ],
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

      testWidgets('[Level-A] has tooltip for accessibility', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(
          MaterialApp(
            home: testWidget,
          ),
        );

        final iconButton = find.byType(IconButton);
        expect(iconButton, findsOneWidget);
        AccessibilityTestHelpers.verifyButtonsHaveLabels(tester);

        handle.dispose();
      });
    });
  });
}
