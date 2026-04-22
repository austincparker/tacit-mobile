import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/critic_bloc.dart';
import 'package:logging/logging.dart';

class CriticReportDialog extends StatefulWidget {
  const CriticReportDialog({super.key});

  @override
  State<CriticReportDialog> createState() => _CriticReportDialogState();
}

class _CriticReportDialogState extends State<CriticReportDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _submitting = false;

  Logger get _log => Logger('CriticReportDialog');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    setState(() {
      _submitting = true;
    });
    try {
      _log.info('Submitting report: ${_controller.text}');
      await CriticBloc().createReport(description: _controller.text);
      _log.info('Report submitted successfully');
      // show a success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully'),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e, st) {
      // show an error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting report: $e'),
          ),
        );
      }
      _log.warning('Error submitting report', e, st);
      setState(() {
        _submitting = false;
      });
    }
  }

  Widget _buildButtonChild() {
    if (_submitting) {
      return const SizedBox(
        height: 16.0,
        width: 16.0,
        child: CircularProgressIndicator(
          semanticsLabel: 'Submitting',
          strokeWidth: 2.0,
        ),
      );
    }
    return const Text('Submit');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report a problem'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Please describe the problem you are having and we will look into it.'),
          const SizedBox(height: 16),
          MergeSemantics(
            child: Semantics(
              label: 'Problem description',
              hint: 'Enter a detailed description of the problem you are experiencing',
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                  hintText: 'Enter description here',
                ),
                controller: _controller,
                maxLines: 5,
                enabled: !_submitting,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        MergeSemantics(
          child: Semantics(
            label: 'Submit report',
            hint: _submitting ? 'Submitting report' : 'Submit the problem report',
            child: TextButton(
              onPressed: _submitting ? null : _submitReport,
              child: _buildButtonChild(),
            ),
          ),
        ),
      ],
    );
  }
}
