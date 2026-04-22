class QueryResponse {
  final String finalResponse;
  final List<String> expertsConsulted;
  final Map<String, double> timings;
  final Map<String, int> tokenUsage;
  final String runId;
  final String model;

  const QueryResponse({
    required this.finalResponse,
    required this.expertsConsulted,
    required this.timings,
    required this.tokenUsage,
    required this.runId,
    required this.model,
  });

  factory QueryResponse.fromJson(Map<String, dynamic> json) {
    return QueryResponse(
      finalResponse: json['final_response'] as String? ?? '',
      expertsConsulted: (json['experts_consulted'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      timings: (json['timings'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      tokenUsage: (json['token_usage'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          ) ??
          {},
      runId: json['run_id'] as String? ?? '',
      model: json['model'] as String? ?? 'qwen3:4b',
    );
  }
}
