import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/api/app_http_client.dart';
import 'package:flutter_app_base/bloc/config_bloc.dart';
import 'package:flutter_app_base/bloc/critic_bloc.dart';
import 'package:flutter_app_base/bloc/logging_bloc.dart';
import 'package:flutter_app_base/firebase_options.dart';
import 'package:flutter_app_base/flavors.dart';
import 'package:flutter_app_base/screens/splash_screen.dart';
import 'package:flutter_app_base/themes/default_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set default flavor if none is set already
  try {
    F.appFlavor;
  } catch (e) {
    F.appFlavor = Flavor.staging;
  }

  // Initialize Firebase only if configured
  if (DefaultFirebaseOptions.isConfigured) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatformForFlavor);
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
    }
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  } else {
    debugPrint('⚠️ Firebase not configured - skipping initialization. '
        'Update firebase_options.dart with your Firebase credentials.');
  }

  await AppHttpClient.initialize();
  await LoggingBloc().initialize();
  await ConfigBloc().initialize();
  // TODO: Uncomment this when you implement notifications
  // await NotificationBloc().initialize();
  await CriticBloc().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App Base',
      theme: defaultTheme,
      home: const SplashScreen(),
    );
  }
}
