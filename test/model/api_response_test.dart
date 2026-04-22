import 'package:flutter_app_base/model/api_error.dart';
import 'package:flutter_app_base/model/api_response.dart';
import 'package:flutter_app_base/model/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('ApiResponse Tests', () {
    test('Test successful parsing of response', () async {
      final successfulResponse = http.Response('{"key": "value"}', 200);
      final response = await ApiResponse.parse(successfulResponse);

      expect(response.data, {'key': 'value'});
      expect(response.error, isNull);
    });

    test('Test failure parsing of response', () async {
      final failedResponse = http.Response('{"error": "Bad request"}', 400);

      expect(
        () => ApiResponse.parse(failedResponse),
        throwsA(isA<ApiResponse>()),
      );
    });

    test('Test successful parsing of status only', () async {
      final successfulResponse = http.Response('{"key": "value"}', 200);
      final response = await ApiResponse.parseStatusOnly(successfulResponse);

      expect(response, true);
    });

    test('Test failure parsing of status only', () async {
      final failedResponse =
          http.Response('{"error": "Bad request"}', 400);

      expect(
        () => ApiResponse.parseStatusOnly(failedResponse),
        throwsA(isA<ApiError>()),
      );
    });

    test('Test parsing response to object', () async {
      final successfulResponse =
          http.Response('{"id": "1", "email": "test@test.com"}', 200);

      User userMapper(Map<String, dynamic> json) {
        return User.fromJson(json);
      }

      final response =
          await ApiResponse.parseToObject<User>(userMapper)(successfulResponse);

      expect(response.data, const TypeMatcher<User>());
      expect(response.data!.id, '1');
      expect(response.data!.email, 'test@test.com');
    });

    test('Test parsing response to list', () async {
      final successfulResponse = http.Response(
        '[{"id": "1", "email": "test1@test.com"}, {"id": "2", "email": "test2@test.com"}]',
        200,
      );

      User userMapper(Map<String, dynamic> json) {
        return User.fromJson(json);
      }

      final response = await ApiResponse.parseToList<User>((List data) {
        return data
            .map((item) => userMapper(item as Map<String, dynamic>))
            .toList();
      })(successfulResponse);

      expect(response.data, const TypeMatcher<List<User>>());
      expect(response.data!.length, 2);
      expect(response.data![0].id, '1');
      expect(response.data![0].email, 'test1@test.com');
      expect(response.data![1].id, '2');
      expect(response.data![1].email, 'test2@test.com');
    });
  });
}
