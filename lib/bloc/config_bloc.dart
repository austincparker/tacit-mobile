import 'package:tacit_mobile/mixins/logger.dart';
import 'package:tacit_mobile/repository/config_repository.dart';
import 'package:tacit_mobile/repository/secure_config_repository.dart';
import 'package:rxdart/rxdart.dart';

class ConfigBloc with Logger {
  static ConfigBloc? _instance;

  factory ConfigBloc() {
    return _instance ??= ConfigBloc._();
  }

  static Future<ConfigBloc> reset({
    ConfigRepository? repository,
    SecureConfigRepository? secureRepository,
  }) async {
    await _instance?._dispose();
    return _instance = ConfigBloc._(repository, secureRepository);
  }

  final ConfigRepository _repository;
  final SecureConfigRepository _secureRepository;

  final Map<String, BehaviorSubject<String>> _streams = {};

  ConfigBloc._([ConfigRepository? repository, SecureConfigRepository? secureRepository])
      : _repository = repository ?? ConfigRepository(),
        _secureRepository = secureRepository ?? SecureConfigRepository();

  Future<void> initialize() async {
    log.finest('initialize()');

    final serverUrl = await _repository.getValueForKey(kServerUrl);
    _streams[kServerUrl] = BehaviorSubject<String>.seeded(serverUrl ?? '');

    final apiKey = await _secureRepository.getValueForKey(kApiKey);
    _streams[kApiKey] = BehaviorSubject<String>.seeded(apiKey ?? '');
  }

  Future<void> _dispose() async {
    _instance = null;
    await Future.wait(_streams.values.map((s) => s.close()));
    _streams.clear();
  }

  Stream<String> streamFor(String key) {
    if (!_streams.containsKey(key)) {
      throw 'Unknown configuration key: $key';
    }
    return _streams[key]!.stream;
  }

  Stream<bool> get isConfigured => Rx.combineLatest2(
        streamFor(kServerUrl),
        streamFor(kApiKey),
        (String url, String key) => url.isNotEmpty && key.isNotEmpty,
      );

  Future<void> setServerConfig({
    required String serverUrl,
    required String apiKey,
  }) async {
    log.finest('setServerConfig($serverUrl)');
    await _repository.setValueForKey(kServerUrl, serverUrl);
    _streams[kServerUrl]!.add(serverUrl);

    await _secureRepository.setValueForKey(kApiKey, apiKey);
    _streams[kApiKey]!.add(apiKey);
  }

  Future<void> clearServerConfig() async {
    log.finest('clearServerConfig()');
    await _repository.setValueForKey(kServerUrl, '');
    _streams[kServerUrl]!.add('');

    await _secureRepository.deleteValueForKey(kApiKey);
    _streams[kApiKey]!.add('');
  }

  static const kServerUrl = 'kServerUrl';
  static const kApiKey = 'kApiKey';
}
