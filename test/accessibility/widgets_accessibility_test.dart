@Tags(['accessibility'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_app_base/widgets/login_form.dart';
import 'package:flutter_test/flutter_test.dart';

import 'accessibility_test_helpers.dart';

void main() {
  group('Widget Accessibility Tests', () {
    group('LoginForm', () {
      testWidgets('[Level-A] meets labeled tap target guideline', (WidgetTester tester) async {
        await AccessibilityTestHelpers.testMeetsLevelAGuidelines(
          tester,
          const LoginForm(),
        );
      });

      testWidgets('[Level-AA] meets contrast and tap target size guidelines', (WidgetTester tester) async {
        await AccessibilityTestHelpers.testMeetsLevelAAGuidelines(
          tester,
          const LoginForm(),
        );
      });

      testWidgets('[Level-A] has proper semantic properties', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LoginForm(),
            ),
          ),
        );

        // Verify text fields have proper semantics
        AccessibilityTestHelpers.verifyTextFieldsHaveLabels(tester);

        // Verify login button has proper semantics
        final loginButton = find.byType(TextButton);
        expect(loginButton, findsOneWidget);

        final buttonSemantics = tester.getSemantics(loginButton);
        expect(
          buttonSemantics.label,
          equals('Login'),
          reason: 'Login button must have "Login" label',
        );

        handle.dispose();
      });
    });
  });
}
