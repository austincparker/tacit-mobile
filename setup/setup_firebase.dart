#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

class FirebaseSetup {
  static const String _reset = '\x1B[0m';
  static const String _green = '\x1B[32m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _bold = '\x1B[1m';

  static void _print(String message, [String color = _reset]) {
    print('$color$message$_reset');
  }

  static void _printHeader(String message) {
    _print('\n$_bold$_blue═══ $message ═══$_reset');
  }

  static void _printSuccess(String message) {
    _print('✓ $message', _green);
  }

  static void _printError(String message) {
    _print('✗ $message', _red);
  }

  static void _printWarning(String message) {
    _print('⚠ $message', _yellow);
  }

  static void _printInfo(String message) {
    _print('ℹ $message', _blue);
  }

  static Future<bool> _runCommand(String command, List<String> args, {String? workingDirectory}) async {
    try {
      final result = await Process.run(command, args, workingDirectory: workingDirectory);
      if (result.exitCode != 0) {
        _printError('Command failed: $command ${args.join(' ')}');
        _printError('Error: ${result.stderr}');
        return false;
      }
      return true;
    } catch (e) {
      _printError('Failed to run command: $command ${args.join(' ')}');
      _printError('Error: $e');
      return false;
    }
  }

  static Future<String?> _runCommandWithOutput(String command, List<String> args, {String? workingDirectory}) async {
    try {
      final result = await Process.run(command, args, workingDirectory: workingDirectory);
      if (result.exitCode != 0) {
        _printError('Command failed: $command ${args.join(' ')}');
        _printError('Error: ${result.stderr}');
        return null;
      }
      return result.stdout.toString().trim();
    } catch (e) {
      _printError('Failed to run command: $command ${args.join(' ')}');
      _printError('Error: $e');
      return null;
    }
  }

  static String _getUserInput(String prompt, [String? defaultValue]) {
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

  static Future<bool> _checkFirebaseCLI() async {
    _printInfo('Checking Firebase CLI installation...');
    final result = await Process.run('firebase', ['--version']);
    if (result.exitCode != 0) {
      _printError('Firebase CLI not found. Please install it first:');
      _printInfo('npm install -g firebase-tools');
      return false;
    }
    _printSuccess('Firebase CLI found');
    return true;
  }

  static Future<bool> _checkFirebaseLogin() async {
    _printInfo('Checking Firebase login status...');
    
    // Check if we can access user information (indicates successful login)
    final result = await Process.run('firebase', ['login:list', '--json']);
    if (result.exitCode != 0) {
      _printWarning('Not logged in to Firebase. Please login:');
      _printInfo('firebase login');
      return false;
    }
    
    try {
      // Try to parse the JSON output to verify we have a valid login
      final output = result.stdout.toString().trim();
      if (output.isEmpty || output == '[]') {
        _printWarning('No Firebase accounts found. Please login:');
        _printInfo('firebase login');
        return false;
      }
      _printSuccess('Firebase login verified');
      return true;
    } catch (e) {
      _printWarning('Could not verify Firebase login. Please ensure you are logged in:');
      _printInfo('firebase login');
      return false;
    }
  }

  static Future<String?> _createFirebaseProject(String projectId, String displayName) async {
    _printInfo('Creating Firebase project: $projectId');
    
    // First check if project already exists
    _printInfo('Checking if project already exists...');
    final listResult = await _runCommandWithOutput('firebase', ['projects:list']);
    if (listResult != null) {
      // Parse the text output to check if project exists
      if (listResult.contains(projectId)) {
        _printWarning('Project $projectId already exists. Using existing project.');
        return projectId;
      }
    }
    
    final success = await _runCommand('firebase', [
      'projects:create',
      projectId,
      '--display-name',
      displayName,
    ]);
    
    if (!success) {
      _printError('Failed to create Firebase project.');
      _printError('Common causes:');
      _printError('- Project ID already exists (must be globally unique)');
      _printError('- Billing not enabled on your Google Cloud account');
      _printError('- Insufficient permissions');
      _printError('- Reached project creation limits');
      _printInfo('');
      _printInfo('Try using a different project ID or create the project manually:');
      _printInfo('https://console.firebase.google.com/');
      return null;
    }
    
    _printSuccess('Firebase project created: $projectId');
    return projectId;
  }

  static Future<String?> _lookupFirebaseApp(String projectId, String platform, String appId) async {
    _printInfo('Looking up existing Firebase $platform app: $appId');
    
    // Use the apps:list command with detailed information
    final result = await _runCommandWithOutput('firebase', [
      'apps:list',
      platform,
      '--project',
      projectId,
    ]);
    
    if (result == null) {
      return null;
    }
    
    // The Firebase CLI doesn't show package/bundle IDs in the list output
    // We need to check each app individually using apps:sdkconfig
    final lines = result.split('\n');
    final firebaseAppIds = <String>[];
    
    // Extract all Firebase app IDs from the list
    for (final line in lines) {
      final appIdMatch = RegExp(r'1:\d+:(?:android|ios):\w+').firstMatch(line);
      if (appIdMatch != null) {
        firebaseAppIds.add(appIdMatch.group(0)!);
      }
    }
    
    // Check each app to see if it matches our package/bundle ID
    for (final firebaseAppId in firebaseAppIds) {
      _printInfo('Checking Firebase app ID: $firebaseAppId');
      
      // Try to get config to see if this app matches our package/bundle ID
      final configResult = await Process.run('firebase', [
        'apps:sdkconfig',
        platform,
        firebaseAppId,
        '--project',
        projectId,
      ]);
      
      if (configResult.exitCode == 0) {
        final configOutput = configResult.stdout.toString();
        // For Android, look for package_name in the JSON
        // For iOS, look for bundle_id in the plist
        if ((platform == 'android' && configOutput.contains('"package_name": "$appId"')) ||
            (platform == 'ios' && configOutput.contains('<string>$appId</string>'))) {
          _printSuccess('Found existing Firebase $platform app: $appId (Firebase ID: $firebaseAppId)');
          return firebaseAppId;
        }
      }
    }
    
    return null;
  }

  static Future<String?> _createOrFindFirebaseApp(String projectId, String platform, String appId, String displayName) async {
    // First, always try to look up the existing app
    _printInfo('Checking for existing Firebase $platform app: $appId');
    final existingAppId = await _lookupFirebaseApp(projectId, platform, appId);
    
    if (existingAppId != null) {
      return existingAppId;
    }
    
    // If not found, try to create it
    _printInfo('Creating Firebase $platform app: $appId');
    
    final args = [
      'apps:create',
      platform,
      displayName,
      '--project',
      projectId,
    ];
    
    // Add platform-specific identifier
    if (platform == 'android') {
      args.add('--package-name=$appId');
    } else if (platform == 'ios') {
      args.add('--bundle-id=$appId');
    }
    
    final result = await _runCommandWithOutput('firebase', args);
    
    if (result == null) {
      _printError('Failed to create Firebase $platform app: $appId');
      return null;
    }
    
    // Extract the Firebase app ID from the output
    // Look for patterns like "1:123456789:android:abcd1234" or similar
    final appIdMatch = RegExp(r'1:\d+:(?:android|ios):\w+').firstMatch(result);
    if (appIdMatch != null) {
      final firebaseAppId = appIdMatch.group(0)!;
      _printSuccess('Firebase $platform app created: $appId (Firebase ID: $firebaseAppId)');
      return firebaseAppId;
    }
    
    _printSuccess('Firebase $platform app created: $appId');
    _printInfo('Attempting to look up Firebase app ID...');
    // If we can't extract the Firebase app ID from output, try to look it up
    return _lookupFirebaseApp(projectId, platform, appId);
  }

  static Future<bool> _downloadAndroidConfig(String projectId, String firebaseAppId, String flavor) async {
    _printInfo('Downloading Android configuration for $flavor...');
    
    final outputPath = 'android/app/src/$flavor/google-services.json';
    
    // Ensure directory exists for all flavors
    final dir = Directory('android/app/src/$flavor');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    
    // Remove existing file if it exists
    final configFile = File(outputPath);
    if (configFile.existsSync()) {
      _printInfo('Removing existing config file: $outputPath');
      await configFile.delete();
    }
    
    final result = await Process.run('firebase', [
      'apps:sdkconfig',
      'android',
      firebaseAppId,
      '--out',
      outputPath,
      '--project',
      projectId,
    ]);
    
    if (result.exitCode != 0) {
      _printError('Failed to download Android configuration for $flavor');
      _printError('Error: ${result.stderr}');
      return false;
    }
    
    // Verify the file was actually created
    if (!configFile.existsSync()) {
      _printError('Configuration file was not created: $outputPath');
      _printError('Checking if file exists in current directory...');
      
      // Check if the file was created in the current directory instead
      final currentDirFile = File('google-services.json');
      if (currentDirFile.existsSync()) {
        _printInfo('Found google-services.json in current directory, moving to $outputPath');
        await currentDirFile.copy(outputPath);
        await currentDirFile.delete();
      } else {
        return false;
      }
    }
    
    _printSuccess('Android configuration downloaded: $outputPath');
    return true;
  }

  static Future<bool> _downloadiOSConfig(String projectId, String firebaseAppId, String flavor) async {
    _printInfo('Downloading iOS configuration for $flavor...');
    
    final outputPath = flavor == 'production' 
        ? 'ios/Runner/GoogleService-Info.plist'
        : 'ios/Runner/GoogleService-Info-$flavor.plist';
    
    // Remove existing file if it exists
    final configFile = File(outputPath);
    if (configFile.existsSync()) {
      _printInfo('Removing existing config file: $outputPath');
      await configFile.delete();
    }
    
    final result = await Process.run('firebase', [
      'apps:sdkconfig',
      'ios',
      firebaseAppId,
      '--out',
      outputPath,
      '--project',
      projectId,
    ]);
    
    if (result.exitCode != 0) {
      _printError('Failed to download iOS configuration for $flavor');
      _printError('Error: ${result.stderr}');
      return false;
    }
    
    // Verify the file was actually created
    if (!configFile.existsSync()) {
      _printError('Configuration file was not created: $outputPath');
      _printError('Checking if file exists in current directory...');
      
      // Check if the file was created in the current directory instead
      final currentDirFile = File('GoogleService-Info.plist');
      if (currentDirFile.existsSync()) {
        _printInfo('Found GoogleService-Info.plist in current directory, moving to $outputPath');
        await currentDirFile.copy(outputPath);
        await currentDirFile.delete();
      } else {
        return false;
      }
    }
    
    _printSuccess('iOS configuration downloaded: $outputPath');
    return true;
  }

  static Future<bool> _updateFirebaseOptions() async {
    _printInfo('Updating firebase_options.dart with downloaded configurations...');
    
    final firebaseOptionsFile = File('lib/firebase_options.dart');
    if (!firebaseOptionsFile.existsSync()) {
      _printError('firebase_options.dart not found');
      return false;
    }
    
    var content = await firebaseOptionsFile.readAsString();
    
    // Parse Android configs
    final androidProdConfig = File('android/app/src/production/google-services.json');
    final androidStagingConfig = File('android/app/src/staging/google-services.json');
    
    if (androidProdConfig.existsSync()) {
      final config = await _parseAndroidConfig(androidProdConfig);
      content = _replaceConfigPlaceholders(content, 'ANDROID_PRODUCTION', config);
    }
    
    if (androidStagingConfig.existsSync()) {
      final config = await _parseAndroidConfig(androidStagingConfig);
      content = _replaceConfigPlaceholders(content, 'ANDROID_STAGING', config);
    }
    
    // Parse iOS configs
    final iosProdConfig = File('ios/Runner/GoogleService-Info.plist');
    final iosStagingConfig = File('ios/Runner/GoogleService-Info-staging.plist');
    
    if (iosProdConfig.existsSync()) {
      final config = await _parseiOSConfig(iosProdConfig);
      content = _replaceConfigPlaceholders(content, 'IOS_PRODUCTION', config);
    }
    
    if (iosStagingConfig.existsSync()) {
      final config = await _parseiOSConfig(iosStagingConfig);
      content = _replaceConfigPlaceholders(content, 'IOS_STAGING', config);
    }
    
    await firebaseOptionsFile.writeAsString(content);
    _printSuccess('firebase_options.dart updated with configurations');
    return true;
  }
  
  static Future<Map<String, String>> _parseAndroidConfig(File configFile) async {
    final content = await configFile.readAsString();
    final jsonData = jsonDecode(content);
    
    final client = jsonData['client'][0];
    final apiKey = jsonData['client'][0]['api_key'][0]['current_key'];
    
    return {
      'API_KEY': apiKey,
      'APP_ID': client['client_info']['mobilesdk_app_id'],
      'MESSAGING_SENDER_ID': jsonData['project_info']['project_number'],
      'PROJECT_ID': jsonData['project_info']['project_id'],
      'STORAGE_BUCKET': jsonData['project_info']['storage_bucket'],
    };
  }
  
  static Future<Map<String, String>> _parseiOSConfig(File configFile) async {
    final content = await configFile.readAsString();
    
    // Parse plist content using regex
    final apiKeyMatch = RegExp(r'<key>API_KEY</key>\s*<string>([^<]+)</string>').firstMatch(content);
    final appIdMatch = RegExp(r'<key>GOOGLE_APP_ID</key>\s*<string>([^<]+)</string>').firstMatch(content);
    final senderIdMatch = RegExp(r'<key>GCM_SENDER_ID</key>\s*<string>([^<]+)</string>').firstMatch(content);
    final projectIdMatch = RegExp(r'<key>PROJECT_ID</key>\s*<string>([^<]+)</string>').firstMatch(content);
    final storageBucketMatch = RegExp(r'<key>STORAGE_BUCKET</key>\s*<string>([^<]+)</string>').firstMatch(content);
    final bundleIdMatch = RegExp(r'<key>BUNDLE_ID</key>\s*<string>([^<]+)</string>').firstMatch(content);
    
    // CLIENT_ID is optional and used for Google Sign-In, may not be present in basic Firebase config
    final iosClientIdMatch = RegExp(r'<key>CLIENT_ID</key>\s*<string>([^<]+)</string>').firstMatch(content);
    
    return {
      'API_KEY': apiKeyMatch?.group(1) ?? '',
      'APP_ID': appIdMatch?.group(1) ?? '',
      'MESSAGING_SENDER_ID': senderIdMatch?.group(1) ?? '',
      'PROJECT_ID': projectIdMatch?.group(1) ?? '',
      'STORAGE_BUCKET': storageBucketMatch?.group(1) ?? '',
      'CLIENT_ID': iosClientIdMatch?.group(1) ?? '', // Will be empty if not present
      'BUNDLE_ID': bundleIdMatch?.group(1) ?? '',
    };
  }
  
  static String _replaceConfigPlaceholders(String content, String prefix, Map<String, String> config) {
    for (final entry in config.entries) {
      final placeholder = '{{${prefix}_${entry.key}}}';
      // Handle optional iosClientId - if empty, remove the parameter entirely
      if (entry.key == 'CLIENT_ID' && entry.value.isEmpty) {
        // Remove the entire iosClientId line for iOS configurations
        final iosClientIdPattern = '\\s*iosClientId: \'{{${prefix}_CLIENT_ID}}\',?\\s*';
        content = content.replaceAll(RegExp(iosClientIdPattern), '');
      } else {
        content = content.replaceAll(placeholder, entry.value);
      }
    }
    return content;
  }

  static Future<void> _enableFirebaseServices(String projectId) async {
    _printInfo('Firebase services setup...');
    
    _printInfo('Core Firebase services (Analytics, Crashlytics, Cloud Messaging)');
    _printInfo('are automatically available once apps are created.');
    _printInfo('');
    _printInfo('You can enable additional services in the Firebase Console:');
    _printInfo('https://console.firebase.google.com/project/$projectId');
    _printInfo('');
    _printInfo('Recommended services to enable:');
    _printInfo('- App Distribution (for beta testing)');
    _printInfo('- Performance Monitoring');
    _printInfo('- Remote Config (if needed)');
    
    _printSuccess('Firebase services information provided');
  }

  static Future<void> run([List<String>? arguments]) async {
    _printHeader('Firebase Project Setup');
    _printInfo('This script will create a Firebase project with 4 apps:');
    _printInfo('- Android Production');
    _printInfo('- Android Staging');
    _printInfo('- iOS Production');
    _printInfo('- iOS Staging');
    _printInfo('');

    // Check prerequisites
    if (!await _checkFirebaseCLI()) {
      exit(1);
    }

    if (!await _checkFirebaseLogin()) {
      _printInfo('Please run: firebase login');
      exit(1);
    }

    // Parse command line arguments
    String? projectId;
    String? displayName;
    bool? useExisting;
    String? androidPackagePrefix;
    String? iosBundlePrefix;
    
    if (arguments != null && arguments.isNotEmpty) {
      // Parse named arguments
      for (var i = 0; i < arguments.length; i++) {
        final arg = arguments[i];
        if (arg == '--project-id' && i + 1 < arguments.length) {
          projectId = arguments[i + 1];
          i++; // Skip next argument as it's the value
        } else if (arg == '--display-name' && i + 1 < arguments.length) {
          displayName = arguments[i + 1];
          i++; // Skip next argument as it's the value
        } else if (arg == '--android-package' && i + 1 < arguments.length) {
          androidPackagePrefix = arguments[i + 1];
          i++; // Skip next argument as it's the value
        } else if (arg == '--ios-bundle' && i + 1 < arguments.length) {
          iosBundlePrefix = arguments[i + 1];
          i++; // Skip next argument as it's the value
        } else if (arg == '--use-existing') {
          useExisting = true;
        } else if (arg == '--create-new') {
          useExisting = false;
        }
      }
      
      // Debug: Show parsed bundle IDs
      if (androidPackagePrefix != null || iosBundlePrefix != null) {
        _printInfo('Received bundle ID arguments:');
        if (androidPackagePrefix != null) {
          _printInfo('  --android-package: $androidPackagePrefix');
        }
        if (iosBundlePrefix != null) {
          _printInfo('  --ios-bundle: $iosBundlePrefix');
        }
        _printInfo('');
      }
    }

    // Get project details
    if (useExisting == null) {
      _printInfo('You can either create a new Firebase project or use an existing one.');
      final useExistingInput = _getUserInput('Use existing project? (y/n)', 'n').toLowerCase();
      useExisting = useExistingInput == 'y' || useExistingInput == 'yes';
    }
    
    if (useExisting) {
      projectId ??= _getUserInput('Enter existing Firebase project ID');
      displayName = 'Existing Project'; // Won't be used for existing projects
      
      if (projectId.isEmpty) {
        _printError('Project ID is required');
        exit(1);
      }
      
      // Verify the project exists
      _printInfo('Verifying project exists...');
      final listResult = await _runCommandWithOutput('firebase', ['projects:list']);
      if (listResult != null) {
        // Parse the text output to verify project exists
        if (!listResult.contains(projectId)) {
          _printError('Project $projectId not found in your Firebase account.');
          exit(1);
        }
      }
    } else {
      projectId ??= _getUserInput('Enter new Firebase project ID', 'your-app-name');
      displayName ??= _getUserInput('Enter project display name', 'Your App Name');
      
      if (projectId.isEmpty) {
        _printError('Project ID is required');
        exit(1);
      }
    }

    // Read app configuration from flavorizr.yaml
    final flavorizrFile = File('flavorizr.yaml');
    if (!flavorizrFile.existsSync()) {
      _printError('flavorizr.yaml not found. Please run this script from the project root.');
      exit(1);
    }

    // Create or verify Firebase project
    if (useExisting == true) {
      _printHeader('Using Existing Firebase Project');
      _printSuccess('Using existing project: $projectId');
    } else {
      _printHeader('Creating Firebase Project');
      final createdProjectId = await _createFirebaseProject(projectId, displayName);
      if (createdProjectId == null) {
        exit(1);
      }
    }

    // Enable Firebase services
    await _enableFirebaseServices(projectId);

    // Generate app identifiers - use custom values if provided, otherwise derive from project name
    String androidPackage;
    String iosBundleId;
    
    _printHeader('App Bundle Identifiers');
    
    // Use custom bundle IDs if provided, otherwise generate from project name
    if (androidPackagePrefix != null && androidPackagePrefix.isNotEmpty) {
      androidPackage = androidPackagePrefix;
      _printSuccess('Using provided Android Package ID: $androidPackage');
    } else {
      // Generate from project name (legacy behavior)
      final projectCamelCase = projectId.split('-').map((part) => 
        part[0].toUpperCase() + part.substring(1),
      ).join();
      final projectPascalCase = projectCamelCase[0].toLowerCase() + projectCamelCase.substring(1);
      androidPackage = 'dev.twinsun.$projectPascalCase';
      _printWarning('No Android Package ID provided, using generated: $androidPackage');
    }
    
    if (iosBundlePrefix != null && iosBundlePrefix.isNotEmpty) {
      iosBundleId = iosBundlePrefix;
      _printSuccess('Using provided iOS Bundle ID: $iosBundleId');
    } else {
      // Generate from project name (legacy behavior)
      final projectCamelCase = projectId.split('-').map((part) => 
        part[0].toUpperCase() + part.substring(1),
      ).join();
      final projectPascalCase = projectCamelCase[0].toLowerCase() + projectCamelCase.substring(1);
      iosBundleId = 'dev.twinsun.$projectPascalCase';
      _printWarning('No iOS Bundle ID provided, using generated: $iosBundleId');
    }
    
    _printInfo('');
    
    // Create apps
    _printHeader('Creating Firebase Apps');
    
    final apps = [
      {
        'platform': 'android',
        'id': androidPackage,
        'name': 'Android Production',
        'flavor': 'production',
      },
      {
        'platform': 'android',
        'id': '$androidPackage.staging',
        'name': 'Android Staging',
        'flavor': 'staging',
      },
      {
        'platform': 'ios',
        'id': iosBundleId,
        'name': 'iOS Production',
        'flavor': 'production',
      },
      {
        'platform': 'ios',
        'id': '$iosBundleId.staging',
        'name': 'iOS Staging',
        'flavor': 'staging',
      },
    ];

    // Create apps and store their Firebase app IDs
    final createdApps = <Map<String, String>>[];
    
    for (final app in apps) {
      final firebaseAppId = await _createOrFindFirebaseApp(
        projectId,
        app['platform']!,
        app['id']!,
        app['name']!,
      );
      
      if (firebaseAppId != null) {
        createdApps.add({
          'platform': app['platform']!,
          'id': app['id']!,
          'firebaseAppId': firebaseAppId,
          'flavor': app['flavor']!,
        });
        _printInfo('Added app to download list: ${app['flavor']} ${app['platform']} (ID: $firebaseAppId)');
      } else {
        _printWarning('Failed to get Firebase app ID for ${app['flavor']} ${app['platform']}');
      }
    }

    // Download configuration files
    _printHeader('Downloading Configuration Files');
    
    if (createdApps.isEmpty) {
      _printWarning('No apps were successfully created or found. Skipping configuration downloads.');
    } else {
      for (final app in createdApps) {
        _printInfo('Processing ${app['platform']} ${app['flavor']} with Firebase ID: ${app['firebaseAppId']}');
        if (app['platform'] == 'android') {
          await _downloadAndroidConfig(projectId, app['firebaseAppId']!, app['flavor']!);
        } else if (app['platform'] == 'ios') {
          await _downloadiOSConfig(projectId, app['firebaseAppId']!, app['flavor']!);
        }
      }
    }

    // Update firebase_options.dart
    _printHeader('Updating Firebase Options');
    await _updateFirebaseOptions();

    _printHeader('Setup Complete');
    _printSuccess('Firebase project setup completed successfully!');
    _printInfo('');
    _printInfo('Next steps:');
    _printInfo('1. Update your project bundle IDs and package names if needed');
    _printInfo('2. Run: fvm flutter clean && fvm flutter pub get');
    _printInfo('3. Test your Firebase configuration');
    _printInfo('');
    _printInfo('Firebase Console: https://console.firebase.google.com/project/$projectId');
  }
}

void main(List<String> arguments) async {
  await FirebaseSetup.run(arguments);
}