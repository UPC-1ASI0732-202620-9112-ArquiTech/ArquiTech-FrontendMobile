import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/utils/validators.dart' as app_validators;
import '../../domain/entities/material.dart' as domain;
import '../controllers/materials_controller.dart';

class MaterialFormSheet extends ConsumerStatefulWidget {
  const MaterialFormSheet({super.key, required this.projectId, this.material});
  final int projectId;
  final domain.Material? material;

  @override
  ConsumerState<MaterialFormSheet> createState() => _MaterialFormSheetState();
}

class _MaterialFormSheetState extends ConsumerState<MaterialFormSheet> {
  static const units = [
    'kg',
    'bolsa',
    'unidad',
    'litro',
    'galón',
    'm³',
    'm²',
    'm',
    'varilla',
    'plancha',
  ];
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _unit;
  late final TextEditingController _quantity;
  late final TextEditingController _minimumStock;
  late final TextEditingController _unitPrice;
  late final TextEditingController _provider;
  late final TextEditingController _providerRuc;
  late DateTime _date;
  bool _submitting = false;

  bool get isEdit => widget.material != null;

  @override
  void initState() {
    super.initState();
    final material = widget.material;
    _name = TextEditingController(text: material?.name ?? '');
    _unit = TextEditingController(text: material?.unit ?? '');
    _quantity = TextEditingController(
      text: material == null ? '0' : material.quantity.toString(),
    );
    _minimumStock = TextEditingController(
      text: material?.minimumStock.toString() ?? '0',
    );
    _unitPrice = TextEditingController(
      text: material?.unitPrice.toString() ?? '0',
    );
    _provider = TextEditingController(text: material?.provider ?? '');
    _providerRuc = TextEditingController(text: material?.providerRuc ?? '');
    _date = material?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _unit,
      _quantity,
      _minimumStock,
      _unitPrice,
      _provider,
      _providerRuc,
    ]) {
      controller.dispose();
    }
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
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isEdit ? context.l10n.editMaterial : context.l10n.newMaterial,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _name,
            decoration: InputDecoration(labelText: context.l10n.materialName),
            validator: _required,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _unit,
            decoration: InputDecoration(labelText: context.l10n.unit),
            validator: _required,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: units
                .map(
                  (unit) => ActionChip(
                    label: Text(unit),
                    onPressed: () => setState(() => _unit.text = unit),
                  ),
                )
                .toList(),
          ),
          if (!isEdit) ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: _quantity,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: context.l10n.quantity),
              validator: _nonNegative,
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minimumStock,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: context.l10n.minimumStock,
                  ),
                  validator: _nonNegative,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _unitPrice,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: context.l10n.unitPrice,
                  ),
                  validator: _nonNegative,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _provider,
            decoration: InputDecoration(labelText: context.l10n.provider),
            validator: _required,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _providerRuc,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: context.l10n.providerRuc),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return context.l10n.requiredField;
              }
              return app_validators.Validators.isProviderRuc(value)
                  ? null
                  : context.l10n.invalidRuc;
            },
          ),
          if (!isEdit) ...[
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(labelText: context.l10n.date),
                child: Text(
                  MaterialLocalizations.of(context).formatMediumDate(_date),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(context.l10n.save),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    ),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? context.l10n.requiredField : null;
  String? _nonNegative(String? value) {
    final parsed = double.tryParse(value ?? '');
    if (parsed == null) return context.l10n.invalidNumber;
    return parsed < 0 ? context.l10n.nonNegativeNumber : null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    final controller = ref.read(
      materialsControllerProvider(widget.projectId).notifier,
    );
    try {
      if (isEdit) {
        await controller.update(
          widget.material!.id,
          domain.UpdateMaterialRequest(
            name: _name.text.trim(),
            unit: _unit.text.trim(),
            minimumStock: double.parse(_minimumStock.text),
            unitPrice: double.parse(_unitPrice.text),
            provider: _provider.text.trim(),
            providerRuc: _providerRuc.text.trim(),
          ),
        );
      } else {
        await controller.create(
          domain.CreateMaterialRequest(
            projectId: widget.projectId,
            name: _name.text.trim(),
            unit: _unit.text.trim(),
            quantity: double.parse(_quantity.text),
            minimumStock: double.parse(_minimumStock.text),
            unitPrice: double.parse(_unitPrice.text),
            provider: _provider.text.trim(),
            providerRuc: _providerRuc.text.trim(),
            date: _date,
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
