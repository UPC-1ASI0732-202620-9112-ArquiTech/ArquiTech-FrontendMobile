import 'package:flutter/material.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/project.dart';

Future<bool> showDeleteProjectDialog(
  BuildContext context,
  Project project,
  Future<void> Function() action,
) async =>
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DeleteProjectDialog(project: project, action: action),
    ) ??
    false;

class _DeleteProjectDialog extends StatefulWidget {
  const _DeleteProjectDialog({required this.project, required this.action});
  final Project project;
  final Future<void> Function() action;
  @override
  State<_DeleteProjectDialog> createState() => _DeleteProjectDialogState();
}

class _DeleteProjectDialogState extends State<_DeleteProjectDialog> {
  final name = TextEditingController();
  bool submitting = false;
  String? error;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() => submitting = true);
    try {
      await widget.action();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = ErrorMapper.message(context.l10n, e));
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !submitting,
    child: AlertDialog(
      title: Text(context.l10n.deleteProject),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.deleteProjectWarning),
            const SizedBox(height: 12),
            Text(widget.project.name),
            TextField(
              controller: name,
              enabled: !submitting,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: context.l10n.confirmProjectName,
              ),
            ),
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: submitting ? null : () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: submitting || name.text != widget.project.name
              ? null
              : submit,
          child: submitting
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.l10n.delete),
        ),
      ],
    ),
  );
}
