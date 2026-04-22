import 'dart:convert';

import 'package:flutter_app_base/api/api.dart';
import 'package:flutter_app_base/mixins/logger.dart';
import 'package:flutter_app_base/model/api_response.dart';
import 'package:flutter_app_base/model/auth_response.dart';
import 'package:flutter_app_base/model/user.dart';

final class RegistrationsApi with ApiMixin, Logger {
  Future<ApiResponse<AuthResponse>> register({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return client
        .post(
          Uri.parse('$apiUrl/api/v1/users'),
          headers: await getDefaultHeaders(),
          body: json.encode({
            'user': {
              'email': email,
              'password': password,
              'password_confirmation': passwordConfirmation,
            },
          }),
        )
        .then(ApiResponse.parseToObject(AuthResponse.fromJson));
  }

  Future<ApiResponse<User>> updateProfile({
    required String email,
    String? firstName,
    String? lastName,
    String? avatarSignedId,
  }) async {
    final userParams = <String, dynamic>{
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
    };

    if (avatarSignedId != null) {
      userParams['avatar'] = avatarSignedId;
    }

    return client
        .put(
          Uri.parse('$apiUrl/api/v1/users'),
          headers: await getDefaultHeaders(),
          body: json.encode({'user': userParams}),
        )
        .then(ApiResponse.parseToObject(User.fromJson));
  }

  Future<ApiResponse<User>> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    return client
        .put(
          Uri.parse('$apiUrl/api/v1/users'),
          headers: await getDefaultHeaders(),
          body: json.encode({
            'user': {
              'current_password': currentPassword,
              'password': password,
              'password_confirmation': passwordConfirmation,
            },
          }),
        )
        .then(ApiResponse.parseToObject(User.fromJson));
  }

  Future<void> deleteAccount() async {
    await client.delete(
      Uri.parse('$apiUrl/api/v1/users'),
      headers: await getDefaultHeaders(),
    );
  }
}
