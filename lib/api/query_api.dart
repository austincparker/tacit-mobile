import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tacit_mobile/api/tacit_api.dart';
import 'package:tacit_mobile/model/pipeline_event.dart';
import 'package:tacit_mobile/model/query_request.dart';
import 'package:tacit_mobile/model/query_response.dart';

class QueryApi with TacitApiMixin {
  static final QueryApi _instance = QueryApi._();
  factory QueryApi() => _instance;
  QueryApi._();

  /// Blocking pipeline call. Returns after the full pipeline completes (60-230s).
  Future<QueryResponse> query(QueryRequest request) async {
    final url = await serverUrl;
    final headers = await getDefaultHeaders();

    try {
      final response = await client
          .post(
            Uri.parse('$url/v1/query'),
            headers: headers,
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 300));

      if (response.statusCode == 401) throw UnauthorizedException();
      if (response.statusCode != 200) {
        throw Exception('Pipeline error (${response.statusCode}): ${response.body}');
      }

      return QueryResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('SocketException')) {
        throw ServerUnreachableException(url);
      }
      rethrow;
    }
  }

  /// SSE streaming pipeline call. Yields events as each stage starts/completes.
  Stream<PipelineEvent> stream(QueryRequest request) async* {
    final url = await serverUrl;
    final headers = await getDefaultHeaders();

    final httpRequest = http.Request('POST', Uri.parse('$url/v1/query/stream'));
    httpRequest.headers.addAll(headers);
    httpRequest.body = jsonEncode(request.toJson());

    final streamedResponse = await client.send(httpRequest);

    if (streamedResponse.statusCode == 401) throw UnauthorizedException();

    String eventType = '';
    final buffer = StringBuffer();

    await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
      buffer.write(chunk);
      final lines = buffer.toString().split('\n');
      buffer.clear();

      // Keep incomplete last line in the buffer
      if (!chunk.endsWith('\n')) {
        buffer.write(lines.removeLast());
      }

      for (final line in lines) {
        if (line.startsWith('event: ')) {
          eventType = line.substring(7).trim();
        } else if (line.startsWith('data: ')) {
          final data = jsonDecode(line.substring(6)) as Map<String, dynamic>;
          yield _parseEvent(eventType, data);
        }
      }
    }
  }

  PipelineEvent _parseEvent(String type, Map<String, dynamic> data) {
    return switch (type) {
      'stage_started' => StageStarted(
          stage: data['stage'] as String? ?? '',
          name: data['name'] as String? ?? '',
        ),
      'stage_complete' => StageComplete(
          stage: data['stage'] as String? ?? '',
          durationS: (data['duration_s'] as num?)?.toDouble() ?? 0,
        ),
      'pipeline_complete' => PipelineComplete(
          response: QueryResponse.fromJson(data['data'] as Map<String, dynamic>? ?? data),
        ),
      'pipeline_error' => PipelineError(
          error: data['error'] as String? ?? 'Unknown pipeline error',
        ),
      _ => StageStarted(stage: type, name: data.toString()),
    };
  }
}
