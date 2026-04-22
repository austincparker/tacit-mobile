import 'dart:async';

import 'package:tacit_mobile/api/query_api.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tacit_mobile/mixins/logger.dart';
import 'package:tacit_mobile/model/pipeline_event.dart';
import 'package:tacit_mobile/model/query_request.dart';

enum QueryStatus { idle, loading, streaming, complete, error }

class QueryState {
  final QueryStatus status;
  final String prompt;
  final String currentStage;
  final String response;
  final List<String> experts;
  final Map<String, double> timings;
  final String? error;

  const QueryState({
    this.status = QueryStatus.idle,
    this.prompt = '',
    this.currentStage = '',
    this.response = '',
    this.experts = const [],
    this.timings = const {},
    this.error,
  });

  QueryState copyWith({
    QueryStatus? status,
    String? prompt,
    String? currentStage,
    String? response,
    List<String>? experts,
    Map<String, double>? timings,
    String? error,
  }) {
    return QueryState(
      status: status ?? this.status,
      prompt: prompt ?? this.prompt,
      currentStage: currentStage ?? this.currentStage,
      response: response ?? this.response,
      experts: experts ?? this.experts,
      timings: timings ?? this.timings,
      error: error ?? this.error,
    );
  }
}

class QueryBloc with Logger {
  static QueryBloc? _instance;

  factory QueryBloc() => _instance ??= QueryBloc._();

  static Future<QueryBloc> reset({QueryApi? queryApi}) async {
    await _instance?._dispose();
    return _instance = QueryBloc._(queryApi);
  }

  final QueryApi _queryApi;

  QueryBloc._([QueryApi? queryApi]) : _queryApi = queryApi ?? QueryApi();

  final BehaviorSubject<QueryState> _stateSubject =
      BehaviorSubject<QueryState>.seeded(const QueryState());

  Stream<QueryState> get stateStream => _stateSubject.stream;
  QueryState get currentState => _stateSubject.value;

  StreamSubscription<PipelineEvent>? _querySub;

  Future<void> query(String prompt, {bool skipDeliberation = false}) async {
    await cancel();
    log.finest('query($prompt)');

    _stateSubject.add(QueryState(
      status: QueryStatus.loading,
      prompt: prompt,
    ));

    try {
      _querySub = _queryApi
          .stream(QueryRequest(prompt: prompt, skipDeliberation: skipDeliberation))
          .listen(
        (event) {
          switch (event) {
            case StageStarted(:final stage, :final name):
              _stateSubject.add(_stateSubject.value.copyWith(
                status: QueryStatus.streaming,
                currentStage: name.isNotEmpty ? name : stage,
              ));
            case StageComplete():
              break; // Progress tracked via StageStarted
            case PipelineComplete(:final response):
              _stateSubject.add(QueryState(
                status: QueryStatus.complete,
                prompt: prompt,
                response: response.finalResponse,
                experts: response.expertsConsulted,
                timings: response.timings,
              ));
            case PipelineError(:final error):
              _stateSubject.add(QueryState(
                status: QueryStatus.error,
                prompt: prompt,
                error: error,
              ));
          }
        },
        onError: (Object e) {
          _stateSubject.add(QueryState(
            status: QueryStatus.error,
            prompt: prompt,
            error: e.toString(),
          ));
        },
      );
    } catch (e) {
      _stateSubject.add(QueryState(
        status: QueryStatus.error,
        prompt: prompt,
        error: e.toString(),
      ));
    }
  }

  Future<void> cancel() async {
    await _querySub?.cancel();
    _querySub = null;
  }

  void reset_() {
    _stateSubject.add(const QueryState());
  }

  Future<void> _dispose() async {
    _instance = null;
    await cancel();
    await _stateSubject.close();
  }
}
