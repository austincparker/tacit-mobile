class TacitStatus {
  final String ollama;
  final String qdrant;

  const TacitStatus({required this.ollama, required this.qdrant});

  bool get isHealthy => ollama == 'ok' && qdrant.startsWith('ok');

  String get summary => 'Ollama: $ollama | Qdrant: $qdrant';

  factory TacitStatus.fromJson(Map<String, dynamic> json) {
    return TacitStatus(
      ollama: json['ollama'] as String? ?? 'unknown',
      qdrant: json['qdrant'] as String? ?? 'unknown',
    );
  }
}
