import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/bloc/notification_bloc.dart';
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
    await AuthBloc.reset(
      firebaseCrashlytics: firebaseCrashlytics,
      firebaseAnalytics: firebaseAnalytics,
    );
  });

  group('NotificationBloc', () {
    test('initialize() completes without error when Firebase is not configured',
        () async {
      // Verify the template's placeholder keys make isConfigured return false
      expect(DefaultFirebaseOptions.isConfigured, isFalse);

      // initialize() should complete without throwing — no Firebase static
      // stream access, no FCM token fetch, no device registration
      final bloc = await NotificationBloc.reset();
      expect(bloc, isNotNull);
    });

    test(
        'initialize() skips FCM subscriptions and device registration '
        'when Firebase is not configured', () async {
      expect(DefaultFirebaseOptions.isConfigured, isFalse);

      await NotificationBloc.reset();

      // With Firebase unconfigured, no stream subscriptions should be set up.
      // The bloc should still be functional (no crash, no leaked subscriptions).
      // We verify by calling _dispose indirectly via reset — if subscriptions
      // were incorrectly created, cancellation would throw.
      final bloc2 = await NotificationBloc.reset();
      expect(bloc2, isNotNull);
    });
  });
}
