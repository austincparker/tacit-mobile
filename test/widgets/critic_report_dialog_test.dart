import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/bloc/critic_bloc.dart';
import 'package:flutter_app_base/widgets/critic_report_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventiv_critic_flutter/modal/bug_report.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  late MockCritic mockCritic;

  setUpAll(() async {
    await Firebase.initializeApp();
    registerFallbackValue(BugReport());
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

  setUp(() async {
    mockCritic = MockCritic();
    await CriticBloc.reset(critic: mockCritic);
  });

  tearDownAll(() async {
    await CriticBloc.reset();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return const CriticReportDialog();
                  },
                );
              },
              child: const Text('Show Dialog'),
            );
          },
        ),
      ),
    );
  }

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();
  }

  testWidgets('CriticReportDialog displays description TextField',
      (WidgetTester tester) async {
    await openDialog(tester);
    expect(find.byType(TextField), findsOne);
  });

  testWidgets(
      'CriticReportDialog displays Cancel button and closes dialog when tapped',
      (WidgetTester tester) async {
    await openDialog(tester);

    expect(find.text('Cancel'), findsOne);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(CriticReportDialog), findsNothing);
  });

  testWidgets(
      'CriticReportDialog displays Submit button and calls _submitReport when tapped',
      (WidgetTester tester) async {
    when(() => mockCritic.submitReport(any())).thenAnswer((_) async {
      return BugReport();
    });

    await openDialog(tester);
    expect(find.text('Submit'), findsOne);

    // runAsync is required because createReport() performs real file I/O
    // (writing logs to a temp file). Flutter's test framework fakes async by
    // default, which blocks real I/O. The delay gives the I/O time to finish.
    // Two pumps follow: the first processes the setState from the future
    // completing, the second advances the animation/snackbar timer.
    await tester.runAsync(() async {
      await tester.tap(find.text('Submit'));
      await Future.delayed(const Duration(seconds: 2));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    verify(() => mockCritic.submitReport(any())).called(1);
  });

  testWidgets(
      'CriticReportDialog displays CircularProgressIndicator when _submitting is true',
      (WidgetTester tester) async {
    final completer = Completer<BugReport>();
    when(() => mockCritic.submitReport(any())).thenAnswer((_) {
      return completer.future;
    });

    await openDialog(tester);

    // Tap and let I/O run up to submitReport (which blocks on completer)
    await tester.runAsync(() async {
      await tester.tap(find.text('Submit'));
      await Future.delayed(const Duration(seconds: 2));
    });
    await tester.pump(const Duration(milliseconds: 100));

    // Check if CircularProgressIndicator is displayed
    expect(find.byType(CircularProgressIndicator), findsOne);

    // Clean up
    completer.complete(BugReport());
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets(
      'CriticReportDialog displays success SnackBar after successful report submission',
      (WidgetTester tester) async {
    when(() => mockCritic.submitReport(any())).thenAnswer((_) async {
      return BugReport();
    });

    await openDialog(tester);

    await tester.runAsync(() async {
      await tester.tap(find.text('Submit'));
      await Future.delayed(const Duration(seconds: 2));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Report submitted successfully'), findsOne);
  });

  testWidgets(
      'CriticReportDialog displays error SnackBar after failed report submission',
      (WidgetTester tester) async {
    when(() => mockCritic.submitReport(any()))
        .thenThrow(Exception('Test error'));

    await openDialog(tester);

    await tester.runAsync(() async {
      await tester.tap(find.text('Submit'));
      await Future.delayed(const Duration(seconds: 2));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.text('Error submitting report: Exception: Test error'),
      findsOne,
    );
  });
}
