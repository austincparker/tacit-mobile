import 'package:flutter_app_base/model/user.dart';

class AuthResponse {
  AuthResponse({
    required this.authenticationToken,
    required this.authenticationTokenCreatedAt,
    required this.user,
  });

  final String authenticationToken;
  final DateTime authenticationTokenCreatedAt;
  final User user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      authenticationToken: json['authentication_token'],
      authenticationTokenCreatedAt: DateTime.parse(json['authentication_token_created_at']),
      user: User.fromJson(json['user']),
    );
  }
}
