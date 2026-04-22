@Tags(['accessibility'])
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/screens/login_screen.dart';
import 'package:flutter_app_base/screens/main_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks/mocks.dart';
import 'accessibility_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
    final firebaseCrashlytics = MockFirebaseCrashlytics();
    final firebaseAnalytics = MockFirebaseAnalytics();
    when(() => firebaseCrashlytics.setUserIdentifier(any()))
        .thenAnswer((_) async {});
    when(() => firebaseAnalytics.setUserId(id: any(named: 'id')))
        .thenAnswer((_) async {});
    await AuthBloc.reset(
      firebaseCrashlytics: firebaseCrashlytics,
      firebaseAnalytics: firebaseAnalytics,
    );
  });

  setUp(AccessibilityTestHelpers.initializeFlavor);

  group('Screen Accessibility Tests', () {
    // TODO: Unskip when CachedNetworkImage platform channels are mocked.
    // CachedNetworkImage uses platform channels unavailable in widget tests,
    // causing MissingPluginException. Requires a mock image provider or
    // platform channel stub to run.
    group('LoginScreen', () {
      testWidgets(
        '[Level-A] meets labeled tap target guideline',
        skip: true,
        (WidgetTester tester) async {
          await AccessibilityTestHelpers.testScreenMeetsLevelAGuidelines(
            tester,
            const LoginScreen(),
            pumpDelay: const Duration(milliseconds: 100),
          );
        },
      );

      testWidgets(
        '[Level-AA] meets contrast and tap target size guidelines',
        skip: true,
        (WidgetTester tester) async {
          await AccessibilityTestHelpers.testScreenMeetsLevelAAGuidelines(
            tester,
            const LoginScreen(),
            pumpDelay: const Duration(milliseconds: 100),
          );
        },
      );
    });

    group('MainScreen', () {
      testWidgets('[Level-A] meets labeled tap target guideline',
          (WidgetTester tester) async {
        await AccessibilityTestHelpers.testScreenMeetsLevelAGuidelines(
          tester,
          const MainScreen(),
          pumpDelay: const Duration(milliseconds: 100),
        );
      });

      testWidgets('[Level-AA] meets contrast and tap target size guidelines',
          (WidgetTester tester) async {
        await AccessibilityTestHelpers.testScreenMeetsLevelAAGuidelines(
          tester,
          const MainScreen(),
          pumpDelay: const Duration(milliseconds: 100),
        );
      });
    });
  });
}
