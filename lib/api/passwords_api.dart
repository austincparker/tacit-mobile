import 'dart:convert';

import 'package:flutter_app_base/api/api.dart';
import 'package:flutter_app_base/mixins/logger.dart';
import 'package:flutter_app_base/model/api_response.dart';

final class PasswordsApi with ApiMixin, Logger {
  Future<ApiResponse> requestReset(String email) async {
    return client
        .post(
          Uri.parse('$apiUrl/api/v1/users/password'),
          headers: await getDefaultHeaders(),
          body: json.encode({
            'user': {
              'email': email,
            },
          }),
        )
        .then(ApiResponse.parse);
  }
}
