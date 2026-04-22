import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

class LoggingBloc {
  static LoggingBloc? _instance;

  factory LoggingBloc() {
    return _instance ??= LoggingBloc._();
  }

  static Future<LoggingBloc> reset() async {
    await _instance?._dispose();
    return _instance = LoggingBloc._();
  }

  final List<String> _logs = [];
  List<String> get logs => _logs;

  final BehaviorSubject<bool> _connectedSubject = BehaviorSubject<bool>();

  Stream<bool> get connected => _connectedSubject.stream;

  StreamSubscription? _logRecordSubscription;
  StreamSubscription? _connectivitySubscription;

  LoggingBloc._() {
    Logger.root.level = Level.ALL;
  }

  Future initialize() async {
    _logRecordSubscription?.cancel();
    _connectivitySubscription?.cancel();

    _logRecordSubscription = Logger.root.onRecord.listen((LogRecord rec) {
      final pieces = [
        '(${rec.time}) · ${rec.loggerName.isEmpty ? 'root' : rec.loggerName} · ${rec.level.name.toUpperCase()}: ${rec.message}',
      ];
      if (rec.error != null) pieces.add(rec.error.toString());
      if (rec.stackTrace != null) pieces.add(rec.stackTrace.toString());

      _logs.add(pieces.join('\n'));

      print(pieces.join('\n')); // ignore: avoid_print
    });

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_logConnectivity);
    _logConnectivity(await Connectivity().checkConnectivity());

    return Future.value();
  }

  void logNetworkRequest({
    required String url,
    required String method,
    required int statusCode,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final message =
        '(${DateTime.now()}) · Network · INFO: $method $url completed with $statusCode in ${endTime.difference(startTime).inMilliseconds / 1000}s';
    _logs.add(message);

    // ignore: avoid_print
    print(message);
  }

  void _logConnectivity(List<ConnectivityResult> results) {
    for (final result in results) {
      switch (result) {
        case ConnectivityResult.mobile:
          Logger.root.info('Network Connectivity: mobile');
          _connectedSubject.add(true);
        case ConnectivityResult.wifi:
          Logger.root.info('Network Connectivity: wifi');
          _connectedSubject.add(true);
        case ConnectivityResult.none:
        default:
          Logger.root.info('Network Connectivity: none');
          _connectedSubject.add(false);
      }
    }
  }

  Future<void> _dispose() async {
    _instance = null;
    _logRecordSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _connectedSubject.close();
  }
}
