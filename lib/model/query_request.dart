class QueryRequest {
  final String prompt;
  final String? model;
  final bool skipDeliberation;
  final bool includePersonal;
  final int topK;

  const QueryRequest({
    required this.prompt,
    this.model,
    this.skipDeliberation = false,
    this.includePersonal = false,
    this.topK = 5,
  });

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
        if (model != null) 'model': model,
        'skip_deliberation': skipDeliberation,
        'include_personal': includePersonal,
        'top_k': topK,
      };
}
