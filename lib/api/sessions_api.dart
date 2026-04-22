import 'dart:convert';

import 'package:flutter_app_base/api/api.dart';
import 'package:flutter_app_base/mixins/logger.dart';
import 'package:flutter_app_base/model/api_response.dart';
import 'package:flutter_app_base/model/auth_response.dart';
import 'package:flutter_app_base/model/user.dart';

final class SessionsApi with ApiMixin, Logger {
  Future<ApiResponse<AuthResponse>> login(String email, String password) async {
    return client
        .post(
          Uri.parse('$apiUrl/api/v1/users/sign_in'),
          headers: await getDefaultHeaders(),
          body: json.encode({
            'user': {
              'email': email,
              'password': password,
            },
          }),
        )
        .then(ApiResponse.parseToObject(AuthResponse.fromJson));
  }

  Future<ApiResponse<User>> fetchCurrentUser() async {
    return client
        .get(
          Uri.parse('$apiUrl/api/v1/users/me'),
          headers: await getDefaultHeaders(),
        )
        .then(ApiResponse.parseToObject(User.fromJson));
  }

  Future<void> logout() async {
    await client.delete(
      Uri.parse('$apiUrl/api/v1/users/sign_out'),
      headers: await getDefaultHeaders(),
    );
  }
}
