import 'package:flutter_app_base/constants/types.dart';

class User {
  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.subscribed = false,
    this.subscribedUntil,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final bool subscribed;
  final DateTime? subscribedUntil;
  final String? avatarUrl;

  String get fullName {
    final parts = [firstName, lastName].where((s) => s != null && s.isNotEmpty);
    return parts.isEmpty ? email : parts.join(' ');
  }

  factory User.fromJson(Json json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      subscribed: json['subscribed'] as bool? ?? false,
      subscribedUntil: json['subscribed_until'] != null
          ? DateTime.parse(json['subscribed_until'] as String)
          : null,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
