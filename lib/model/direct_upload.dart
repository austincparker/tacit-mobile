class DirectUpload {
  DirectUpload({
    required this.blobSignedId,
    required this.url,
    required this.headers,
  });

  final String blobSignedId;
  final String url;
  final Map<String, String> headers;

  factory DirectUpload.fromJson(Map<String, dynamic> json) {
    final directUpload = json['direct_upload'] as Map<String, dynamic>;
    return DirectUpload(
      blobSignedId: json['blob_signed_id'],
      url: directUpload['url'],
      headers: Map<String, String>.from(directUpload['headers']),
    );
  }
}
