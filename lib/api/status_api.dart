import 'dart:convert';

import 'package:tacit_mobile/api/tacit_api.dart';
import 'package:tacit_mobile/model/tacit_status.dart';

class StatusApi with TacitApiMixin {
  static final StatusApi _instance = StatusApi._();
  factory StatusApi() => _instance;
  StatusApi._();

  Future<TacitStatus> checkStatus() async {
    final url = await serverUrl;
    final headers = await getDefaultHeaders();

    try {
      final response = await client
          .get(Uri.parse('$url/v1/status'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) throw UnauthorizedException();
      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      return TacitStatus.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw ServerUnreachableException(url);
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> listExperts({String scope = 'all'}) async {
    final url = await serverUrl;
    final headers = await getDefaultHeaders();

    final response = await client
        .get(Uri.parse('$url/v1/experts?scope=$scope'), headers: headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 401) throw UnauthorizedException();

    final data = jsonDecode(response.body);
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }

  Future<List<String>> listModels() async {
    final url = await serverUrl;
    final headers = await getDefaultHeaders();

    final response = await client
        .get(Uri.parse('$url/v1/models'), headers: headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 401) throw UnauthorizedException();

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final models = data['models'] as List<dynamic>? ?? [];
    return models.map((m) => (m as Map<String, dynamic>)['name'] as String).toList();
  }
}
