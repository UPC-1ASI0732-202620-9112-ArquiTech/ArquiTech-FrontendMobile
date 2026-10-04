import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/material.dart' as domain;
import '../../domain/entities/material_movement.dart';
import '../controllers/materials_controller.dart';

class MaterialMovementSheet extends ConsumerStatefulWidget {
  const MaterialMovementSheet({
    super.key,
    required this.projectId,
    required this.material,
    required this.type,
  });
  final int projectId;
  final domain.Material material;
  final MovementType type;

  @override
  ConsumerState<MaterialMovementSheet> createState() =>
      _MaterialMovementSheetState();
}

class _MaterialMovementSheetState extends ConsumerState<MaterialMovementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  late final TextEditingController _supplier;
  final _note = TextEditingController();
  DateTime _occurredAt = DateTime.now();
  bool _submitting = false;
  bool get isEntry => widget.type == MovementType.entry;

  @override
  void initState() {
    super.initState();
    _supplier = TextEditingController(text: widget.material.provider);
  }

  @override
  void dispose() {
    _quantity.dispose();
    _supplier.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 16,
      right: 16,
      top: 12,
      bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
    ),
    child: Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        children: [
          Center(
            child: Container(width: 40, height: 4, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            isEntry ? context.l10n.registerEntry : context.l10n.registerUsage,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(widget.material.name),
          const SizedBox(height: 20),
          TextFormField(
            controller: _quantity,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: context.l10n.quantity,
              suffixText: widget.material.unit,
              helperText: isEntry
                  ? null
                  : '${context.l10n.stock}: ${widget.material.stock}',
            ),
            validator: (value) {
              final amount = double.tryParse(value ?? '');
              if (amount == null || amount <= 0) {
                return context.l10n.positiveNumber;
              }
              if (!isEntry && !widget.material.canUse(amount)) {
                return context.l10n.usageExceedsStock;
              }
              return null;
            },
          ),
          if (isEntry) ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: _supplier,
              decoration: InputDecoration(labelText: context.l10n.supplier),
              validator: (value) => value == null || value.trim().isEmpty
                  ? context.l10n.requiredField
                  : null,
            ),
          ],
          const SizedBox(height: 14),
          InkWell(
            onTap: _pickDateTime,
            child: InputDecorator(
              decoration: InputDecoration(labelText: context.l10n.occurredAt),
              child: Text(
                MaterialLocalizations.of(context).formatFullDate(_occurredAt),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _note,
            maxLines: 3,
            maxLength: 2000,
            decoration: InputDecoration(
              labelText: '${context.l10n.note} (${context.l10n.optional})',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: _submitting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.l10n.confirm),
          ),
        ],
      ),
    ),
  );

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (time != null) {
      setState(
        () => _occurredAt = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    final controller = ref.read(
      materialsControllerProvider(widget.projectId).notifier,
    );
    try {
      if (isEntry) {
        await controller.entry(
          widget.material.id,
          MaterialEntryRequest(
            quantity: double.parse(_quantity.text),
            supplier: _supplier.text.trim(),
            occurredAt: _occurredAt,
            note: _note.text.trim(),
          ),
        );
      } else {
        await controller.usage(
          widget.material.id,
          MaterialUsageRequest(
            quantity: double.parse(_quantity.text),
            occurredAt: _occurredAt,
            note: _note.text.trim(),
          ),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
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
