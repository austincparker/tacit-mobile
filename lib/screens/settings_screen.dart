import 'package:flutter/material.dart';
import 'package:tacit_mobile/api/status_api.dart';
import 'package:tacit_mobile/api/tacit_api.dart';
import 'package:tacit_mobile/bloc/config_bloc.dart';
import 'package:tacit_mobile/model/tacit_status.dart';
import 'package:tacit_mobile/screens/base_screen.dart';
import 'package:tacit_mobile/screens/server_setup_screen.dart';

class SettingsScreen extends BaseScreen {
  const SettingsScreen({super.key, super.title = 'Settings'});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends BaseScreenState<SettingsScreen> {
  TacitStatus? _status;
  List<Map<String, dynamic>>? _experts;
  List<String>? _models;
  String? _serverUrl;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    _serverUrl = await ConfigBloc().streamFor(ConfigBloc.kServerUrl).first;

    try {
      final results = await Future.wait([
        StatusApi().checkStatus(),
        StatusApi().listExperts(),
        StatusApi().listModels(),
      ]);

      setState(() {
        _status = results[0] as TacitStatus;
        _experts = results[1] as List<Map<String, dynamic>>;
        _models = results[2] as List<String>;
        _loading = false;
      });
    } on UnauthorizedException {
      setState(() {
        _error = 'Invalid API key';
        _loading = false;
      });
    } on ServerUnreachableException catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _disconnect() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disconnect from TACIT?'),
        content: const Text('This will clear the server URL and API key.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Disconnect', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ConfigBloc().clearServerConfig();
      if (mounted) popAllAndPush(const ServerSetupScreen());
    }
  }

  @override
  Widget build(BuildContext context, [_]) {
    return super.build(
      context,
      _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _sectionHeader('Connection'),
                ListTile(
                  leading: Icon(
                    _status?.isHealthy == true ? Icons.check_circle : Icons.error,
                    color: _status?.isHealthy == true ? Colors.green : Colors.red,
                  ),
                  title: Text(_serverUrl ?? 'Not configured'),
                  subtitle: _status != null
                      ? Text(_status!.summary)
                      : _error != null
                          ? Text(_error!, style: const TextStyle(color: Colors.red))
                          : null,
                ),
                const Divider(),
                if (_experts != null) ...[
                  _sectionHeader('Experts (${_experts!.length})'),
                  for (final expert in _experts!)
                    ListTile(
                      dense: true,
                      title: Text(expert['name']?.toString() ?? ''),
                      trailing: Text(
                        expert['scope']?.toString() ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ),
                  const Divider(),
                ],
                if (_models != null) ...[
                  _sectionHeader('Models (${_models!.length})'),
                  for (final model in _models!)
                    ListTile(dense: true, title: Text(model)),
                  const Divider(),
                ],
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton.icon(
                    onPressed: () => pushScreen(const ServerSetupScreen()),
                    icon: const Icon(Icons.edit),
                    label: const Text('Reconfigure'),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton.icon(
                    onPressed: _disconnect,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Disconnect',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
