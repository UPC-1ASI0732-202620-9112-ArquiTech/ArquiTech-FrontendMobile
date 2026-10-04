import 'package:flutter/material.dart';

import '../../app/localization/localization_context.dart';
import '../errors/error_mapper.dart';

class AsyncActionButton extends StatefulWidget {
  const AsyncActionButton({
    super.key,
    required this.label,
    required this.action,
  });
  final String label;
  final Future<void> Function() action;
  @override
  State<AsyncActionButton> createState() => _AsyncActionButtonState();
}

class _AsyncActionButtonState extends State<AsyncActionButton> {
  bool submitting = false;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: submitting
        ? null
        : () async {
            setState(() => submitting = true);
            try {
              await widget.action();
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(context.l10n.saved)));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ErrorMapper.message(context.l10n, e))),
                );
              }
            } finally {
              if (mounted) {
                setState(() => submitting = false);
              }
            }
          },
    child: submitting
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(),
          )
        : Text(widget.label),
  );
}
