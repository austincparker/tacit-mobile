import 'package:flutter/material.dart';
import 'package:flutter_app_base/widgets/critic_report_dialog.dart';

class CriticReportButton extends StatelessWidget {
  const CriticReportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.help_outline,
        color: Colors.black,
      ),
      tooltip: 'Report a problem',
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => const CriticReportDialog(),
        );
      },
    );
  }
}
