import 'dart:io';

bool _quietMode = false;

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

void main(List<String> arguments) {
  String newAppPascal;
  
  // Parse arguments
  final args = arguments.toList();
  if (args.contains('--quiet') || args.contains('-q')) {
    _quietMode = true;
    args.remove('--quiet');
    args.remove('-q');
  }
  
  if (args.isNotEmpty) {
    newAppPascal = args[0];
  } else {
    // ignore: avoid_print
    print('Flutter App Renaming Tool');
    // ignore: avoid_print
    print('=========================');
    newAppPascal = _promptForInput('Enter new app name (PascalCase, e.g., MyAwesomeApp)', null);
    
    if (newAppPascal.isEmpty) {
      // ignore: avoid_print
      print('App name is required');
      exit(1);
    }
  }

  final newAppSnake = newAppPascal.replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}').toLowerCase();
  final newAppCamel = newAppPascal[0].toLowerCase() + newAppPascal.substring(1);
  final newAppKebab = newAppSnake.replaceAll('_', '-');
  final newAppSpaced = newAppPascal.replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}');
  final newAppSentence = newAppSpaced[0] + newAppSpaced.substring(1).toLowerCase();

  // ignore: avoid_print
  print('Renaming app to $newAppPascal ($newAppSnake, $newAppCamel, $newAppKebab, "$newAppSpaced", "$newAppSentence")...');

  void replaceInFiles(Directory dir) {
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && !(entity.path.contains('/.git/') || entity.path.endsWith('/.git')) && !entity.path.endsWith('.DS_Store')) {
        try {
          var content = entity.readAsStringSync();
          if (entity.path.endsWith('android/fastlane/Fastfile')) {
            content = content.replaceAll(RegExp(r'^\s*raise.*$', multiLine: true), '');
          }
          content = content.replaceAll('Tacit Mobile (Staging)', '$newAppSpaced (Staging)');
          content = content.replaceAll('Tacit Mobile', newAppSpaced);
          content = content.replaceAll('Tacit mobile', newAppSentence);
          content = content.replaceAll('tacit_mobile', newAppSnake);
          content = content.replaceAll('TacitMobile', newAppPascal);
          content = content.replaceAll('tacitMobile', newAppCamel);
          content = content.replaceAll('tacit-mobile', newAppKebab);

          entity.writeAsStringSync(content);
        } catch (e) {
          // Only print skip messages in verbose mode
          if (!_quietMode) {
            // ignore: avoid_print
            print('Skipping file ${entity.path}: ${e.toString()}');
          }
        }
      }
    }
  }

  replaceInFiles(Directory.current);

  // ignore: avoid_print
  print('Renaming completed!');

  Process.runSync('flutter', ['clean']);
  Process.runSync('flutter', ['pub', 'get']);
}
