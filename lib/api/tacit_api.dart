import 'dart:io';

import 'package:tacit_mobile/api/app_http_client.dart';
import 'package:tacit_mobile/bloc/config_bloc.dart';

mixin TacitApiMixin {
  AppHttpClient get client => AppHttpClient();

  Future<String> get serverUrl async {
    final url = await ConfigBloc().streamFor(ConfigBloc.kServerUrl).first;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Future<Map<String, String>> getDefaultHeaders() async {
    final apiKey = await ConfigBloc().streamFor(ConfigBloc.kApiKey).first;
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (apiKey.isNotEmpty) HttpHeaders.authorizationHeader: 'Bearer $apiKey',
    };
  }
}

class ServerUnreachableException implements Exception {
  final String host;
  const ServerUnreachableException(this.host);

  @override
  String toString() => 'Cannot reach $host — is TACIT running?';
}

class UnauthorizedException implements Exception {
  @override
  String toString() => 'Invalid API key — re-enter on setup screen.';
}
