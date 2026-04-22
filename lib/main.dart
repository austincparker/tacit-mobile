import 'package:flutter/material.dart';
import 'package:tacit_mobile/api/app_http_client.dart';
import 'package:tacit_mobile/bloc/config_bloc.dart';
import 'package:tacit_mobile/bloc/logging_bloc.dart';
import 'package:tacit_mobile/flavors.dart';
import 'package:tacit_mobile/screens/splash_screen.dart';
import 'package:tacit_mobile/themes/default_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set default flavor if none is set already
  try {
    F.appFlavor;
  } catch (e) {
    F.appFlavor = Flavor.staging;
  }

  await AppHttpClient.initialize();
  await LoggingBloc().initialize();
  await ConfigBloc().initialize();

  runApp(const TacitMobileApp());
}

class TacitMobileApp extends StatelessWidget {
  const TacitMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TACIT Mobile',
      theme: defaultTheme,
      home: const SplashScreen(),
    );
  }
}
