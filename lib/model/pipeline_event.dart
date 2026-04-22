import 'package:tacit_mobile/model/query_response.dart';

sealed class PipelineEvent {
  const PipelineEvent();
}

class StageStarted extends PipelineEvent {
  final String stage;
  final String name;

  const StageStarted({required this.stage, this.name = ''});
}

class StageComplete extends PipelineEvent {
  final String stage;
  final double durationS;

  const StageComplete({required this.stage, required this.durationS});
}

class PipelineComplete extends PipelineEvent {
  final QueryResponse response;

  const PipelineComplete({required this.response});
}

class PipelineError extends PipelineEvent {
  final String error;

  const PipelineError({required this.error});
}
