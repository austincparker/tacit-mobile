import 'package:flutter/material.dart';
import 'package:tacit_mobile/api/status_api.dart';
import 'package:tacit_mobile/api/tacit_api.dart';
import 'package:tacit_mobile/bloc/config_bloc.dart';
import 'package:tacit_mobile/model/tacit_status.dart';
import 'package:tacit_mobile/screens/base_screen.dart';
import 'package:tacit_mobile/screens/home_screen.dart';
import 'package:tacit_mobile/screens/qr_scan_screen.dart';

class ServerSetupScreen extends BaseScreen {
  const ServerSetupScreen({super.key, super.title = 'Connect to TACIT'});

  @override
  State<ServerSetupScreen> createState() => _ServerSetupScreenState();
}

class _ServerSetupScreenState extends BaseScreenState<ServerSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _keyController = TextEditingController();

  bool _testing = false;
  TacitStatus? _status;
  String? _testError;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final url = await ConfigBloc().streamFor(ConfigBloc.kServerUrl).first;
    final key = await ConfigBloc().streamFor(ConfigBloc.kApiKey).first;
    if (url.isNotEmpty) _urlController.text = url;
    if (key.isNotEmpty) _keyController.text = key;
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.scheme.startsWith('http')) {
      return 'Must start with http:// or https://';
    }
    if (uri.host.isEmpty) return 'Invalid hostname';
    return null;
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _testing = true;
      _status = null;
      _testError = null;
    });

    // Temporarily save so StatusApi can read the URL
    await ConfigBloc().setServerConfig(
      serverUrl: _urlController.text.trim(),
      apiKey: _keyController.text.trim(),
    );

    try {
      final status = await StatusApi().checkStatus();
      setState(() {
        _status = status;
        _testing = false;
      });
    } on UnauthorizedException {
      setState(() {
        _testError = 'Invalid API key — check the key on your LLM Mac.';
        _testing = false;
      });
    } on ServerUnreachableException catch (e) {
      setState(() {
        _testError = e.toString();
        _testing = false;
      });
    } catch (e) {
      setState(() {
        _testError = 'Connection failed: $e';
        _testing = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await ConfigBloc().setServerConfig(
      serverUrl: _urlController.text.trim(),
      apiKey: _keyController.text.trim(),
    );

    if (mounted) popAllAndPush(const HomeScreen());
  }

  @override
  Widget build(BuildContext context, [_]) {
    return super.build(
      context,
      SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Connect to your TACIT server',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the URL and API key for the LLM Mac running TACIT.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QrScanScreen()),
                ),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Code'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or enter manually', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'Server URL',
                hint: 'Enter the TACIT server address',
                child: TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'Server URL',
                    hintText: 'http://192.168.1.137:8642',
                    prefixIcon: Icon(Icons.dns),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  validator: _validateUrl,
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'API Key',
                hint: 'Enter the TACIT API key',
                child: TextFormField(
                  controller: _keyController,
                  decoration: const InputDecoration(
                    labelText: 'API Key (optional if auth disabled)',
                    prefixIcon: Icon(Icons.key),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  autocorrect: false,
                ),
              ),
              const SizedBox(height: 24),

              // Test connection button
              OutlinedButton.icon(
                onPressed: _testing ? null : _testConnection,
                icon: _testing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_find),
                label: Text(_testing ? 'Testing...' : 'Test Connection'),
              ),

              // Status result
              if (_status != null) ...[
                const SizedBox(height: 12),
                Card(
                  color: _status!.isHealthy ? Colors.green[50] : Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          _status!.isHealthy ? Icons.check_circle : Icons.warning,
                          color: _status!.isHealthy ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_status!.summary)),
                      ],
                    ),
                  ),
                ),
              ],

              // Error result
              if (_testError != null) ...[
                const SizedBox(height: 12),
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _testError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Save button
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save & Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
