import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tacit_mobile/bloc/query_bloc.dart';
import 'package:tacit_mobile/screens/base_screen.dart';
import 'package:tacit_mobile/screens/settings_screen.dart';

class HomeScreen extends BaseScreen {
  const HomeScreen({super.key, super.title = 'TACIT'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseScreenState<HomeScreen> {
  final _promptController = TextEditingController();
  final _scrollController = ScrollController();
  late final StreamSubscription<QueryState> _querySubscription;

  QueryState _queryState = const QueryState();

  @override
  void initState() {
    super.initState();
    _querySubscription = QueryBloc().stateStream.listen((state) {
      setState(() => _queryState = state);
      if (state.status == QueryStatus.streaming ||
          state.status == QueryStatus.complete) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _querySubscription.cancel();
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _submit() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    _promptController.clear();
    FocusScope.of(context).unfocus();
    await QueryBloc().query(prompt);
  }

  bool get _isActive =>
      _queryState.status == QueryStatus.loading ||
      _queryState.status == QueryStatus.streaming;

  @override
  Widget build(BuildContext context, [_]) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('TACIT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => pushScreen(const SettingsScreen()),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Response area
            Expanded(
              child: _buildResponseArea(),
            ),

            // Prompt input
            _buildPromptInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseArea() {
    if (_queryState.status == QueryStatus.idle) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Ask TACIT anything',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your prompt runs through expert knowledge, LLM processing, and validation.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[400],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // User prompt
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              _queryState.prompt,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Stage progress
        if (_isActive) ...[
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                _queryState.currentStage.isNotEmpty
                    ? _queryState.currentStage
                    : 'Starting pipeline...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Response
        if (_queryState.response.isNotEmpty)
          MarkdownBody(
            data: _queryState.response,
            selectable: true,
          ),

        // Experts + timing
        if (_queryState.status == QueryStatus.complete &&
            _queryState.experts.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final expert in _queryState.experts)
                Chip(
                  label: Text(expert, style: const TextStyle(fontSize: 12)),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          if (_queryState.timings.containsKey('total'))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${_queryState.timings['total']!.toStringAsFixed(1)}s',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ),
        ],

        // Error
        if (_queryState.status == QueryStatus.error) ...[
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _queryState.error ?? 'Unknown error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => QueryBloc().query(_queryState.prompt),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPromptInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: 'Enter your prompt',
              child: TextField(
                controller: _promptController,
                decoration: const InputDecoration(
                  hintText: 'Ask TACIT...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
                enabled: !_isActive,
              ),
            ),
          ),
          if (_isActive)
            IconButton(
              icon: const Icon(Icons.stop_circle),
              tooltip: 'Cancel',
              onPressed: () {
                QueryBloc().cancel();
                QueryBloc().reset_();
              },
            )
          else
            Semantics(
              label: 'Send prompt',
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _submit,
              ),
            ),
        ],
      ),
    );
  }
}
