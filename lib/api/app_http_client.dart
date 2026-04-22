import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:tacit_mobile/bloc/logging_bloc.dart';

final class AppHttpClient implements http.Client {
  static final AppHttpClient _instance = AppHttpClient._internal();
  static bool _initialized = false;

  factory AppHttpClient() => _instance;

  AppHttpClient._internal();

  final http.Client _client = http.Client();

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  Map<String, String> baseHeaders(Map<String, String>? headers) {
    return {
      ...(headers ?? {}),
    };
  }

  Future<http.Response> _logRequest(Future<http.Response> request) async {
    final startTime = DateTime.now();
    final response = await request;

    LoggingBloc().logNetworkRequest(
      url: response.request?.url.toString() ?? '',
      method: response.request?.method ?? '',
      statusCode: response.statusCode,
      startTime: startTime,
      endTime: DateTime.now(),
    );

    return response;
  }

  @override
  void close() {
    _client.close();
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) {
    return _logRequest(_client.head(url, headers: baseHeaders(headers)));
  }

  @override
  Future<http.Response> delete(Uri url, {Object? body, Encoding? encoding, Map<String, String>? headers}) {
    return _logRequest(_client.delete(url, body: body, encoding: encoding, headers: baseHeaders(headers)));
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return _logRequest(_client.get(url, headers: baseHeaders(headers)));
  }

  @override
  Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return _logRequest(_client.patch(url, headers: baseHeaders(headers), body: body, encoding: encoding));
  }

  @override
  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return _logRequest(_client.post(url, headers: baseHeaders(headers), body: body, encoding: encoding));
  }

  @override
  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return _logRequest(_client.put(url, headers: baseHeaders(headers), body: body, encoding: encoding));
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    return _client.read(url, headers: baseHeaders(headers));
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    return _client.readBytes(url, headers: baseHeaders(headers));
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request);
  }
}
