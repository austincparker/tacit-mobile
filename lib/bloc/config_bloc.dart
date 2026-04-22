import 'package:flutter_app_base/mixins/logger.dart';
import 'package:flutter_app_base/repository/config_repository.dart';
import 'package:rxdart/rxdart.dart';

class ConfigBloc with Logger {
  static ConfigBloc? _instance;

  factory ConfigBloc() {
    return _instance ??= ConfigBloc._();
  }

  static Future<ConfigBloc> reset({ConfigRepository? repository}) async {
    await _instance?._dispose();
    return _instance = ConfigBloc._(repository);
  }

  final ConfigRepository _repository;

  final Map<String, BehaviorSubject> _streams = {};

  ConfigBloc._([ConfigRepository? repository])
      : _repository = repository ?? ConfigRepository();

  Future<void> initialize() async {
    log.finest('initialize()');
    final authEmail = await stringValueFor(kAuthEmail);
    _streams[kAuthEmail] = BehaviorSubject<String>.seeded(authEmail ?? '');

    final authToken = await stringValueFor(kAuthToken);
    _streams[kAuthToken] = BehaviorSubject<String>.seeded(authToken ?? '');

    final authId = await stringValueFor(kAuthId);
    _streams[kAuthId] = BehaviorSubject<String>.seeded(authId ?? '');
  }

  Future<void> _dispose() async {
    _instance = null;
    await Future.wait(_streams.values.map((s) => s.close()));
    _streams.clear();
  }

  Stream streamFor(String key) {
    if (!_streams.containsKey(key)) {
      throw 'Unknown configuration key: $key';
    }
    return _streams[key]!.stream;
  }

  Future<double?> doubleValueFor(String key) async {
    final value = await _repository.getValueForKey(key);
    log.finest('doubleValueFor $key -> $value');
    if (value != null) {
      return double.tryParse(value);
    }
    return null;
  }

  Future<String?> stringValueFor(String key) async {
    final value = await _repository.getValueForKey(key);
    log.finest('stringValueFor $key -> $value');
    return value;
  }

  Future<void> addToStream(String key, dynamic value) async {
    log.finest('addToStream $key -> $value');
    if (!_streams.containsKey(key)) {
      throw 'Unknown configuration key: $key';
    }
    await _repository.setValueForKey(key, value.toString());
    _streams[key]!.add(value);
  }

  Future<void> setAuthCredentials({
    required String email,
    required String token,
    required String userId,
  }) async {
    log.finest('setAuthCredentials($email)');
    await Future.wait([
      addToStream(kAuthEmail, email),
      addToStream(kAuthToken, token),
      addToStream(kAuthId, userId),
    ]);
  }

  Future<void> clearAuthCredentials() async {
    log.finest('clearAuthCredentials()');
    await Future.wait([
      addToStream(kAuthEmail, ''),
      addToStream(kAuthToken, ''),
      addToStream(kAuthId, ''),
    ]);
  }

  static const kAuthToken = 'kAuthToken';
  static const kAuthEmail = 'kAuthEmail';
  static const kAuthId = 'kAuthId';
}
