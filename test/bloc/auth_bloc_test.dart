import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/firebase_options.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  late MockFirebaseCrashlytics firebaseCrashlytics;
  late MockFirebaseAnalytics firebaseAnalytics;

  setUp(() async {
    await Firebase.initializeApp();
    firebaseCrashlytics = MockFirebaseCrashlytics();
    firebaseAnalytics = MockFirebaseAnalytics();
    when(() => firebaseCrashlytics.setUserIdentifier(any()))
        .thenAnswer((_) async {});
    when(() => firebaseAnalytics.setUserId(id: any(named: 'id')))
        .thenAnswer((_) async {});
  });

  group('AuthBloc', () {
    test('dispose does not throw when called on a freshly constructed instance',
        () async {
      // This tests the late final → nullable fix. Previously, _userSubscription
      // was late final — calling _dispose before the constructor body completed
      // would throw LateInitializationError.
      final bloc = await AuthBloc.reset(
        firebaseCrashlytics: firebaseCrashlytics,
        firebaseAnalytics: firebaseAnalytics,
      );
      expect(bloc, isNotNull);

      // Immediately reset (which calls _dispose on the instance) — should not throw
      final bloc2 = await AuthBloc.reset(
        firebaseCrashlytics: firebaseCrashlytics,
        firebaseAnalytics: firebaseAnalytics,
      );
      expect(bloc2, isNotNull);
    });

    test(
        'Firebase identifiers are skipped when Firebase is not configured',
        () async {
      expect(DefaultFirebaseOptions.isConfigured, isFalse);

      await AuthBloc.reset(
        firebaseCrashlytics: firebaseCrashlytics,
        firebaseAnalytics: firebaseAnalytics,
      );

      // The isConfigured guard in the constructor listener should prevent
      // setUserIdentifier and setUserId from being called when unconfigured.
      // Since we passed mock instances, if the guard works, the mocks
      // won't be invoked by the stream listener's emission of null.
      //
      // BehaviorSubject emits its current value (null) to new subscribers,
      // but the isConfigured check should prevent the Firebase calls.
      verifyNever(() => firebaseCrashlytics.setUserIdentifier(any()));
      verifyNever(() => firebaseAnalytics.setUserId(id: any(named: 'id')));
    });
  });
}
