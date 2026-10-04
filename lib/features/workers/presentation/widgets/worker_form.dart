import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/widgets/record_form.dart';
import '../../../../core/widgets/localized_value.dart';
import '../../domain/entities/worker.dart';
import '../../domain/entities/worker_request.dart';
import '../controllers/workers_controller.dart';

Future<void> showWorkerForm(
  BuildContext context,
  WidgetRef ref,
  int projectId, {
  Worker? existing,
}) async {
  if (!context.mounted) return;
  await Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (context) => RecordForm(
        title: existing == null ? context.l10n.create : context.l10n.edit,
        fields: [
          RecordField(
            'fullName',
            context.l10n.fullName,
            initial: existing?.fullName ?? '',
            maxLength: 100,
            required: true,
          ),
          RecordField(
            'role',
            context.l10n.workerRole,
            initial: existing?.role ?? '',
            maxLength: 50,
            required: true,
            options: {
              for (final r in [
                'Maestro de obra',
                'Capataz',
                'Operario',
                'Oficial',
                'Peón',
                'Albañil',
                'Electricista',
                'Gasfitero',
                'Operador',
                'Topógrafo',
                if (existing != null) existing.role,
              ])
                r: r,
            },
          ),
          RecordField(
            'specialty',
            context.l10n.specialty,
            initial: existing?.specialty ?? '',
            maxLength: 255,
            required: false,
          ),
          RecordField(
            'hireDate',
            context.l10n.hireDate,
            initial: (existing?.hireDate ?? DateTime.now())
                .toIso8601String()
                .split('T')
                .first,
            maxLength: 10,
            required: true,
            date: true,
          ),

          RecordField(
            'status',
            context.l10n.status,
            initial: (existing?.status ?? WorkerStatus.active).apiValue,
            options: {
              for (final s in WorkerStatus.values)
                s.apiValue: localizedValue(context.l10n, s.apiValue),
            },
          ),
        ],
        onSave: (v) => ref
            .read(workersControllerProvider(projectId).notifier)
            .save(
              WorkerRequest(
                projectId: existing == null ? projectId : null,
                status: WorkerStatus.fromApi(v['status']!),
                fullName: v['fullName']!,
                role: v['role']!,
                specialty: v['specialty']!,
                hireDate: DateTime.parse(v['hireDate']!),
              ),
              id: existing?.id,
            ),
      ),
    ),
  );
}
