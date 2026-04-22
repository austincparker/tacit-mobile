import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_app_base/api/api.dart';
import 'package:flutter_app_base/mixins/logger.dart';
import 'package:flutter_app_base/model/api_response.dart';
import 'package:flutter_app_base/model/direct_upload.dart';
import 'package:http/http.dart' as http;

final class DirectUploadsApi with ApiMixin, Logger {
  /// Creates a direct upload blob and returns the signed ID and upload URL.
  Future<ApiResponse<DirectUpload>> createDirectUpload({
    required File file,
    required String contentType,
  }) async {
    final bytes = await file.readAsBytes();
    final checksum = base64.encode(md5.convert(bytes).bytes);
    final filename = file.path.split('/').last;

    return client
        .post(
          Uri.parse('$apiUrl/api/v1/direct_uploads'),
          headers: await getDefaultHeaders(),
          body: json.encode({
            'file': {
              'filename': filename,
              'byte_size': bytes.length,
              'checksum': checksum,
              'content_type': contentType,
            },
          }),
        )
        .then(ApiResponse.parseToObject(DirectUpload.fromJson));
  }

  /// Uploads a file directly to the storage service using the provided URL and headers.
  Future<void> uploadToStorage({
    required File file,
    required DirectUpload directUpload,
  }) async {
    final bytes = await file.readAsBytes();

    final response = await http.put(
      Uri.parse(directUpload.url),
      headers: directUpload.headers,
      body: bytes,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to upload file: ${response.statusCode}');
    }
  }

  /// Convenience method to create a direct upload and upload the file in one call.
  /// Returns the blob signed ID to attach to a record.
  Future<String> uploadFile({
    required File file,
    required String contentType,
  }) async {
    final response = await createDirectUpload(file: file, contentType: contentType);
    final directUpload = response.data!;

    await uploadToStorage(file: file, directUpload: directUpload);

    return directUpload.blobSignedId;
  }
}
