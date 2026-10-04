import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/localization/localization_context.dart';
import '../errors/error_mapper.dart';

class RecordField {
  const RecordField(
    this.keyName,
    this.label, {
    this.initial = '',
    this.options,
    this.required = true,
    this.maxLength = 255,
    this.validate,
    this.date = false,
    this.timestamp = false,
    this.pastOnly = false,
  });
  final String keyName, label, initial;
  final Map<String, String>? options;
  final bool required, date, pastOnly, timestamp;
  final int maxLength;
  final String? Function(String)? validate;
}

class RecordForm extends StatefulWidget {
  const RecordForm({
    super.key,
    required this.title,
    required this.fields,
    required this.onSave,
  });
  final String title;
  final List<RecordField> fields;
  final Future<void> Function(Map<String, String>) onSave;
  @override
  State<RecordForm> createState() => _RecordFormState();
}

class _RecordFormState extends State<RecordForm> {
  final form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> controllers = {
    for (final f in widget.fields)
      f.keyName: TextEditingController(text: f.initial),
  };
  bool submitting = false;
  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? validate(RecordField f, String value) {
    if (f.required && value.trim().isEmpty) return context.l10n.requiredField;
    if (f.timestamp && DateTime.tryParse(value) == null) {
      return context.l10n.invalidDate;
    }
    if (f.date) {
      final d = DateTime.tryParse(value);
      if (d == null ||
          !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) ||
          d.toIso8601String().split('T').first != value ||
          (f.pastOnly && d.isAfter(DateTime.now()))) {
        return context.l10n.invalidDate;
      }
    }
    return f.validate?.call(value);
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() => submitting = true);
    try {
      await widget.onSave({
        for (final e in controllers.entries) e.key: e.value.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.saved)));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorMapper.message(context.l10n, e))),
        );
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final f in widget.fields)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: f.options != null
                  ? DropdownButtonFormField<String>(
                      initialValue:
                          f.options!.containsKey(controllers[f.keyName]!.text)
                          ? controllers[f.keyName]!.text
                          : null,
                      isExpanded: true,
                      items: f.options!.entries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          )
                          .toList(),
                      onChanged: submitting
                          ? null
                          : (v) => controllers[f.keyName]!.text = v ?? '',
                      decoration: InputDecoration(labelText: f.label),
                      validator: (v) => validate(f, v ?? ''),
                    )
                  : TextFormField(
                      controller: controllers[f.keyName],
                      enabled: !submitting,
                      inputFormatters: f.keyName == 'serialNumber'
                          ? [
                              TextInputFormatter.withFunction(
                                (oldValue, newValue) => newValue.copyWith(
                                  text: newValue.text.toUpperCase(),
                                ),
                              ),
                            ]
                          : null,
                      maxLength: f.maxLength,
                      maxLines: f.keyName == 'description' ? 3 : 1,
                      decoration: InputDecoration(
                        labelText: f.label,
                        hintText: f.date ? 'YYYY-MM-DD' : null,
                        suffixIcon: (f.date || f.timestamp)
                            ? IconButton(
                                tooltip: context.l10n.selectDate,
                                onPressed: submitting
                                    ? null
                                    : () async {
                                        final current =
                                            DateTime.tryParse(
                                              controllers[f.keyName]!.text,
                                            )?.toLocal() ??
                                            DateTime.now();
                                        final selected = await showDatePicker(
                                          context: context,
                                          initialDate: current,
                                          firstDate: DateTime(1900),
                                          lastDate: f.pastOnly
                                              ? DateTime.now()
                                              : DateTime(2100),
                                        );
                                        if (selected == null ||
                                            !context.mounted) {
                                          return;
                                        }
                                        DateTime result = selected;
                                        if (f.timestamp) {
                                          final time = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.fromDateTime(
                                              current,
                                            ),
                                          );
                                          if (time == null ||
                                              !context.mounted) {
                                            return;
                                          }
                                          result = DateTime(
                                            selected.year,
                                            selected.month,
                                            selected.day,
                                            time.hour,
                                            time.minute,
                                          );
                                        }
                                        controllers[f.keyName]!.text =
                                            f.timestamp
                                            ? result.toIso8601String()
                                            : result
                                                  .toIso8601String()
                                                  .split('T')
                                                  .first;
                                      },
                                icon: const Icon(Icons.calendar_month),
                              )
                            : null,
                      ),
                      validator: (v) => validate(f, v ?? ''),
                    ),
            ),
          FilledButton(
            onPressed: submitting ? null : submit,
            child: submitting
                ? const CircularProgressIndicator()
                : Text(context.l10n.save),
          ),
        ],
      ),
    ),
  );
}
