import 'dart:io';

import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/bloc/logging_bloc.dart';
import 'package:flutter_app_base/mixins/logger.dart';
import 'package:inventiv_critic_flutter/critic.dart';
import 'package:inventiv_critic_flutter/modal/bug_report.dart';

class CriticBloc with Logger {
  static CriticBloc? _instance;

  factory CriticBloc() {
    return _instance ??= CriticBloc._();
  }

  static Future<CriticBloc> reset({Critic? critic}) async {
    await _instance?._dispose();
    return _instance = CriticBloc._(critic);
  }

  Critic critic;

  CriticBloc._([Critic? critic]) : critic = critic ?? Critic();

  Future<void> initialize() async {
    if (await critic.initialize('JXLT4W6WaCtkKvrZRujRdB1Y')) {
      log.info('Critic initialized');
    } else {
      log.warning('Critic failed to initialize');
    }
  }

  Future<BugReport> createReport({required String description}) async {
    final user = AuthBloc().currentUser;
    final report = BugReport.create(
      description: description,
      stepsToReproduce: '',
      userIdentifier: user?.id ?? 'anonymous',
    );
    report.attachments = [];

    // Create a temporary file
    final tempDir = await Directory.systemTemp.createTemp();
    final tempFile = File('${tempDir.path}/logs.txt');

    // Write each log to the temporary file
    await tempFile.writeAsString(LoggingBloc().logs.join('\n'));

    report.attachments!.add(
      Attachment(name: 'logs.txt', path: tempFile.path),
    );

    return critic.submitReport(report);
  }

  Future<void> _dispose() async {
    _instance = null;
  }
}
