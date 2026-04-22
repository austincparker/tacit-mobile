import 'dart:io';

import 'package:flutter_app_base/api/app_http_client.dart';
import 'package:flutter_app_base/bloc/config_bloc.dart';
import 'package:flutter_app_base/flavors.dart';

const _useLocalApi = bool.fromEnvironment('USE_LOCAL_API');

mixin ApiMixin {
  AppHttpClient get client => AppHttpClient();

  String get apiUrl {
    if (_useLocalApi) {
      // Android emulator uses 10.0.2.2 to reach host machine's localhost
      return Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
    }
    return F.apiUrl;
  }

  Future<String> getAuthHeader() async {
    final email = await ConfigBloc().streamFor(ConfigBloc.kAuthEmail).first;
    final token = await ConfigBloc().streamFor(ConfigBloc.kAuthToken).first;
    return 'Token token=$token,email=$email';
  }

  Future<Map<String, String>> getDefaultHeaders() async {
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: await getAuthHeader(),
    };
  }
}
