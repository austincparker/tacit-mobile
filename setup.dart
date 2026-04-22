#!/usr/bin/env dart

import 'dart:io';
import 'setup/rename_project.dart' as rename;
import 'setup/setup_firebase.dart' as firebase;

String _promptForInput(String prompt, String? defaultValue) {
  if (defaultValue != null) {
    stdout.write('$prompt [$defaultValue]: ');
  } else {
    stdout.write('$prompt: ');
  }

  final input = stdin.readLineSync()?.trim();
  if (input == null || input.isEmpty) {
    return defaultValue ?? '';
  }
  return input;
}

void _printUsage() {
  // ignore: avoid_print
  print('Flutter App Base Setup');
  // ignore: avoid_print
  print('======================');
  // ignore: avoid_print
  print('');
  // ignore: avoid_print
  print('Usage: ./setup.dart [OPTIONS]');
  // ignore: avoid_print
  print('');
  // ignore: avoid_print
  print('Options:');
  // ignore: avoid_print
  print('  --app-name NAME               New app name (PascalCase, e.g., MyAwesomeApp)');
  // ignore: avoid_print
  print('  --project-id ID               Firebase project ID');
  // ignore: avoid_print
  print('  --display-name NAME           Firebase project display name');
  // ignore: avoid_print
  print('  --android-package ID          Android package ID (e.g., com.company.app)');
  // ignore: avoid_print
  print('  --ios-bundle ID               iOS bundle ID (e.g., com.company.app)');
  // ignore: avoid_print
  print('  --use-existing                Use existing Firebase project');
  // ignore: avoid_print
  print('  --create-new                  Create new Firebase project');
  // ignore: avoid_print
  print('  --skip-firebase               Skip Firebase setup');
  // ignore: avoid_print
  print('  --skip-rename                 Skip app renaming');
  // ignore: avoid_print
  print('  --quiet, -q                   Suppress verbose output (skip messages)');
  // ignore: avoid_print
  print('  --help                        Show this help message');
  // ignore: avoid_print
  print('');
  // ignore: avoid_print
  print('Examples:');
  // ignore: avoid_print
  print('  ./setup.dart --app-name MyApp --project-id my-firebase-project --create-new');
  // ignore: avoid_print
  print('  ./setup.dart --app-name MyApp --android-package com.mycompany.myapp --ios-bundle com.mycompany.myapp');
  // ignore: avoid_print
  print('  ./setup.dart --app-name MyApp --skip-firebase');
  // ignore: avoid_print
  print('  ./setup.dart (interactive mode)');
}

void main(List<String> arguments) async {
  // Parse command line arguments
  String? appName;
  String? projectId;
  String? displayName;
  String? androidPackage;
  String? iosBundle;
  bool? useExisting;
  var skipFirebase = false;
  var skipRename = false;
  var showHelp = false;
  var quietMode = false;

  for (var i = 0; i < arguments.length; i++) {
    final arg = arguments[i];
    if (arg == '--app-name' && i + 1 < arguments.length) {
      appName = arguments[i + 1];
      i++; // Skip next argument as it's the value
    } else if (arg == '--project-id' && i + 1 < arguments.length) {
      projectId = arguments[i + 1];
      i++; // Skip next argument as it's the value
    } else if (arg == '--display-name' && i + 1 < arguments.length) {
      displayName = arguments[i + 1];
      i++; // Skip next argument as it's the value
    } else if (arg == '--android-package' && i + 1 < arguments.length) {
      androidPackage = arguments[i + 1];
      i++; // Skip next argument as it's the value
    } else if (arg == '--ios-bundle' && i + 1 < arguments.length) {
      iosBundle = arguments[i + 1];
      i++; // Skip next argument as it's the value
    } else if (arg == '--use-existing') {
      useExisting = true;
    } else if (arg == '--create-new') {
      useExisting = false;
    } else if (arg == '--skip-firebase') {
      skipFirebase = true;
    } else if (arg == '--skip-rename') {
      skipRename = true;
    } else if (arg == '--help') {
      showHelp = true;
    } else if (arg == '--quiet' || arg == '-q') {
      quietMode = true;
    }
  }

  if (showHelp) {
    _printUsage();
    return;
  }

  // ignore: avoid_print
  print('Flutter App Base Setup');
  // ignore: avoid_print
  print('======================');
  // ignore: avoid_print
  print('');

  // Step 1: Rename project (if not skipped)
  if (!skipRename) {
    // ignore: avoid_print
    print('Step 1: Project Renaming');
    // ignore: avoid_print
    print('------------------------');

    if (appName == null) {
      appName = _promptForInput('Enter new app name (PascalCase, e.g., MyAwesomeApp)', null);

      if (appName.isEmpty) {
        // ignore: avoid_print
        print('App name is required');
        exit(1);
      }
    }

    // ignore: avoid_print
    print('Renaming app to $appName...');
    final renameArgs = [appName];
    if (quietMode) {
      renameArgs.add('--quiet');
    }
    rename.main(renameArgs);
    // ignore: avoid_print
    print('✓ Project renamed successfully!');
    // ignore: avoid_print
    print('');
  } else {
    // ignore: avoid_print
    print('Step 1: Project Renaming (SKIPPED)');
    // ignore: avoid_print
    print('');
  }

  // Step 2: Firebase setup (if not skipped)
  if (!skipFirebase) {
    // ignore: avoid_print
    print('Step 2: Firebase Setup');
    // ignore: avoid_print
    print('----------------------');

    // Build Firebase arguments
    final firebaseArgs = <String>[];
    if (projectId != null) {
      firebaseArgs.addAll(['--project-id', projectId]);
    }
    if (displayName != null) {
      firebaseArgs.addAll(['--display-name', displayName]);
    }
    if (androidPackage != null) {
      firebaseArgs.addAll(['--android-package', androidPackage]);
    }
    if (iosBundle != null) {
      firebaseArgs.addAll(['--ios-bundle', iosBundle]);
    }
    if (useExisting ?? false) {
      firebaseArgs.add('--use-existing');
    } else if (useExisting != null && !useExisting) {
      firebaseArgs.add('--create-new');
    }

    await firebase.FirebaseSetup.run(firebaseArgs.isNotEmpty ? firebaseArgs : null);
    // ignore: avoid_print
    print('✓ Firebase setup completed!');
    // ignore: avoid_print
    print('');
  } else {
    // ignore: avoid_print
    print('Step 2: Firebase Setup (SKIPPED)');
    // ignore: avoid_print
    print('');
  }

  // ignore: avoid_print
  print('🎉 Setup complete!');
  // ignore: avoid_print
  print('');
  // ignore: avoid_print
  print('Next steps:');
  // ignore: avoid_print
  print('1. Run: fvm flutter clean && fvm flutter pub get');
  // ignore: avoid_print
  print('2. Test your app: fvm flutter run');
  if (!skipFirebase) {
    // ignore: avoid_print
    print('3. Verify Firebase integration works correctly');
  }
  // ignore: avoid_print
  print('');
  // ignore: avoid_print
  print('');
  // ignore: avoid_print
  print('CI/CD Setup');
  // ignore: avoid_print
  print('===========');
  // ignore: avoid_print
  print('');
  // ignore: avoid_print
  print('PR checks (test, analyze, build) run automatically.');
  // ignore: avoid_print
  print('Deploy workflows auto-detect configured secrets and skip gracefully');
  // ignore: avoid_print
  print('when signing credentials are not set up. Configure per-platform:');
  // ignore: avoid_print
  print('');
  // ignore: avoid_print
  print('  # iOS (TestFlight) — requires Apple Developer account');
  // ignore: avoid_print
  print('  gh variable set PILOT_APPLE_ID --body "<apple-app-id>"');
  // ignore: avoid_print
  print('  gh variable set PILOT_USERNAME --body "<apple-id-email>"');
  // ignore: avoid_print
  print('  gh variable set PILOT_TEAM_ID --body "<app-store-connect-team-id>"');
  // ignore: avoid_print
  print('  gh variable set PILOT_DEV_PORTAL_TEAM_ID --body "<developer-portal-team-id>"');
  // ignore: avoid_print
  print('  gh secret set FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD --body "<value>"');
  // ignore: avoid_print
  print('  gh secret set KEYCHAIN_PASSWORD --body "<value>"');
  // ignore: avoid_print
  print('  gh secret set MATCH_GIT_BASIC_AUTHORIZATION --body "<value>"');
  // ignore: avoid_print
  print('  gh secret set MATCH_PASSWORD --body "<value>"');
  // ignore: avoid_print
  print('');
  // ignore: avoid_print
  print('  # Android — requires signing keystore');
  // ignore: avoid_print
  print('  gh variable set ANDROID_KEY_ALIAS --body "<key-alias>"');
  // ignore: avoid_print
  print('  # macOS:');
  // ignore: avoid_print
  print(r'  gh secret set ANDROID_KEYSTORE --body "$(base64 -i path/to/keystore.jks)"');
  // ignore: avoid_print
  print('  # Linux:');
  // ignore: avoid_print
  print(r'  gh secret set ANDROID_KEYSTORE --body "$(base64 -w 0 path/to/keystore.jks)"');
  // ignore: avoid_print
  print('  gh secret set ANDROID_STORE_PASSWORD --body "<value>"');
  // ignore: avoid_print
  print('  gh secret set ANDROID_KEY_PASSWORD --body "<value>"');
  // ignore: avoid_print
  print('');
  // ignore: avoid_print
  print('  # Android — Firebase App Distribution (if using)');
  // ignore: avoid_print
  print('  gh secret set FIREBASE_TOKEN --body "<value>"');
  // ignore: avoid_print
  print('');
  // ignore: avoid_print
  print('  # Android — Google Play Store (if using)');
  // ignore: avoid_print
  print(r'  gh secret set SUPPLY_JSON_KEY_DATA --body "$(cat service-account.json)"');
}
