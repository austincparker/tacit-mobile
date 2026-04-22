import 'package:faker/faker.dart';
import 'package:flutter_app_base/model/user.dart';

class UserFabricator {
  static User fabricate({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    bool subscribed = false,
    DateTime? subscribedUntil,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? '${Faker().randomGenerator.integer(1000)}',
      email: email ?? Faker().internet.email(),
      firstName: firstName,
      lastName: lastName,
      subscribed: subscribed,
      subscribedUntil: subscribedUntil,
      avatarUrl: avatarUrl,
    );
  }
}
