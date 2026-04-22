@Tags(['accessibility'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/critic_bloc.dart';
import 'package:flutter_app_base/widgets/critic_report_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

import 'accessibility_test_helpers.dart';

void main() {
  group('Dialog Accessibility Tests', () {
    setUp(() async {
      await CriticBloc.reset();
    });

    tearDown(() async {
      await CriticBloc.reset();
    });

    group('CriticReportDialog', () {
      Future<void> showTestDialog(WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (BuildContext context) {
                  return TextButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return const CriticReportDialog();
                        },
                      );
                    },
                    child: const Text('Show Dialog'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();
      }

      testWidgets('[Level-A] meets labeled tap target guideline',
          (WidgetTester tester) async {
        final handle = tester.ensureSemantics();

        await showTestDialog(tester);

        await AccessibilityTestHelpers.verifyLevelAGuidelines(tester);

        handle.dispose();
      });

      testWidgets('[Level-AA] meets contrast and tap target size guidelines',
          (WidgetTester tester) async {
        final handle = tester.ensureSemantics();

        await showTestDialog(tester);

        await AccessibilityTestHelpers.verifyLevelAAGuidelines(tester);

        handle.dispose();
      });

      testWidgets('[Level-A] text field has proper semantic properties',
          (WidgetTester tester) async {
        final handle = tester.ensureSemantics();

        await showTestDialog(tester);

        AccessibilityTestHelpers.verifyTextFieldsHaveLabels(tester);

        handle.dispose();
      });

      testWidgets('[Level-A] all buttons have proper semantic labels',
          (WidgetTester tester) async {
        final handle = tester.ensureSemantics();

        await showTestDialog(tester);

        final buttons = find.byType(TextButton);
        expect(buttons, findsNWidgets(3));
        AccessibilityTestHelpers.verifyButtonsHaveLabels(tester);

        handle.dispose();
      });
    });
  });
}
