import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../domain/entities/project.dart';
import '../controllers/projects_controller.dart';

class CreateProjectPage extends ConsumerStatefulWidget {
  const CreateProjectPage({super.key});

  @override
  ConsumerState<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends ConsumerState<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _budget = TextEditingController(text: '0');
  final _progress = TextEditingController(text: '0');
  DateTime _start = DateTime.now();
  DateTime? _end;
  int? _contractorId;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _budget.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contractors = ref.watch(contractorsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.newProject)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: context.l10n.projectName),
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _location,
              decoration: InputDecoration(labelText: context.l10n.location),
              validator: _required,
            ),
            const SizedBox(height: 16),
            contractors.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => Row(
                children: [
                  Expanded(child: Text(context.l10n.genericError)),
                  IconButton(
                    onPressed: () => ref.invalidate(contractorsProvider),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              data: (users) => DropdownButtonFormField<int>(
                initialValue: _contractorId,
                decoration: InputDecoration(labelText: context.l10n.contractor),
                items: users
                    .map(
                      (user) => DropdownMenuItem(
                        value: user.id,
                        child: Text(user.fullName),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _contractorId = value),
                validator: (value) =>
                    value == null ? context.l10n.requiredField : null,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: context.l10n.startDate,
                    value: _start,
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: context.l10n.endDate,
                    value: _end,
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            if (_end != null && _end!.isBefore(_start))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  context.l10n.endDateBeforeStart,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budget,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: context.l10n.budget),
              validator: _nonNegative,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _progress,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: context.l10n.progress),
              validator: (value) {
                final parsed = int.tryParse(value ?? '');
                return parsed == null || parsed < 0 || parsed > 100
                    ? context.l10n.invalidNumber
                    : null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(context.l10n.create),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? context.l10n.requiredField : null;

  String? _nonNegative(String? value) {
    final parsed = double.tryParse(value ?? '');
    if (parsed == null) return context.l10n.invalidNumber;
    if (parsed < 0) return context.l10n.nonNegativeNumber;
    return null;
  }

  Future<void> _pickDate(bool start) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: start ? _start : (_end ?? _start),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (start) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) ||
        _end == null ||
        _end!.isBefore(_start)) {
      return;
    }
    final user = ref.read(sessionControllerProvider).user!;
    setState(() => _submitting = true);
    try {
      await ref
          .read(projectsControllerProvider.notifier)
          .create(
            CreateProjectRequest(
              name: _name.text.trim(),
              location: _location.text.trim(),
              startDate: _start,
              endDate: _end!,
              budget: double.parse(_budget.text),
              progress: int.parse(_progress.text),
              supervisorId: user.id,
              contractorId: _contractorId!,
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.projectCreated)));
        Navigator.of(context).pop();
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorMapper.message(context.l10n, error))),
        );
        setState(() => _submitting = false);
      }
    }
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(
        value == null
            ? '—'
            : MaterialLocalizations.of(context).formatMediumDate(value!),
      ),
    ),
  );
}
