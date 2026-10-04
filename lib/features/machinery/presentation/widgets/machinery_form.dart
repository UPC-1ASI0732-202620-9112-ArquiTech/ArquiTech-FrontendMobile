import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/widgets/record_form.dart';
import '../../../../core/widgets/localized_value.dart';
import '../../domain/entities/machinery.dart';
import '../../domain/entities/machinery_request.dart';
import '../controllers/machinery_controller.dart';

Future<void> showMachineryForm(
  BuildContext context,
  WidgetRef ref,
  int projectId, {
  Machinery? existing,
}) async {
  if (!context.mounted) return;
  await Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (context) => RecordForm(
        title: existing == null ? context.l10n.create : context.l10n.edit,
        fields: [
          RecordField(
            'name',
            context.l10n.projectName,
            initial: existing?.name ?? '',
            maxLength: 255,
            required: true,
          ),
          RecordField(
            'serialNumber',
            context.l10n.serialNumber,
            initial: existing?.serialNumber ?? '',
            maxLength: 20,
            required: true,
            validate: (v) =>
                Machinery.validSerial(v) ? null : context.l10n.invalidSerial,
          ),
          RecordField(
            'description',
            context.l10n.description,
            initial: existing?.description ?? '',
            maxLength: 255,
            required: false,
          ),
          RecordField(
            'registeredAt',
            context.l10n.registeredAt,
            initial: (existing?.registeredAt ?? DateTime.now())
                .toIso8601String()
                .split('T')
                .first,
            maxLength: 10,
            required: true,
            date: true,
            pastOnly: true,
          ),

          RecordField(
            'status',
            context.l10n.status,
            initial: (existing?.status ?? MachineryStatus.operational).apiValue,
            options: {
              for (final s in MachineryStatus.values)
                s.apiValue: localizedValue(context.l10n, s.apiValue),
            },
          ),
        ],
        onSave: (v) => ref
            .read(machineryControllerProvider(projectId).notifier)
            .save(
              MachineryRequest(
                projectId: existing == null ? projectId : null,
                status: MachineryStatus.fromApi(v['status']!),
                name: v['name']!,
                serialNumber: v['serialNumber']!,
                registeredAt: DateTime.parse(v['registeredAt']!),
                description: v['description']!,
              ),
              id: existing?.id,
            ),
      ),
    ),
  );
}
