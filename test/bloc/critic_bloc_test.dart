import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/bloc/critic_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventiv_critic_flutter/modal/bug_report.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  late MockFirebaseCrashlytics firebaseCrashlytics;
  late MockFirebaseAnalytics firebaseAnalytics;

  setUpAll(() async {
    await Firebase.initializeApp();
    registerFallbackValue(BugReport());
    firebaseCrashlytics = MockFirebaseCrashlytics();
    firebaseAnalytics = MockFirebaseAnalytics();
    when(() => firebaseCrashlytics.setUserIdentifier(any()))
        .thenAnswer((_) async {});
    when(() => firebaseAnalytics.setUserId(id: any(named: 'id')))
        .thenAnswer((_) async {});
    await AuthBloc.reset(
      firebaseCrashlytics: firebaseCrashlytics,
      firebaseAnalytics: firebaseAnalytics,
    );
  });

  tearDownAll(() async {
    await CriticBloc.reset();
  });

  test('Create report with correct description', () async {
    // Setup
    final mockCritic = MockCritic();
    await CriticBloc.reset(critic: mockCritic);
    final criticBloc = CriticBloc();
    const description = 'Test description';

    // Mock the submitReport method
    when(() => mockCritic.submitReport(any())).thenAnswer(
      (_) async => BugReport(
        description: description,
        stepsToReproduce: '',
        userIdentifier: 'test',
      ),
    );

    // Call the createReport method
    await criticBloc.createReport(description: description);

    // Verify that the submitReport method was called with the correct description
    verify(
      () => mockCritic.submitReport(
        any(
          that: isA<BugReport>().having(
            (report) => report.description,
            'description',
            description,
          ),
        ),
      ),
    ).called(1);
  });
}
