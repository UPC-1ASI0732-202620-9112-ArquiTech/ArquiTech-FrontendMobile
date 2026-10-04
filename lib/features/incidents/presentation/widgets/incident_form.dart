import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/widgets/record_form.dart';
import '../../../../core/widgets/localized_value.dart';
import '../../domain/entities/incident.dart';
import '../../domain/entities/incident_request.dart';
import '../controllers/incidents_controller.dart';

Future<void> showIncidentForm(
  BuildContext context,
  WidgetRef ref,
  int projectId, {
  Incident? existing,
}) async {
  if (!context.mounted) return;
  await Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (context) => RecordForm(
        title: existing == null ? context.l10n.create : context.l10n.edit,
        fields: [
          RecordField(
            'reportedAt',
            context.l10n.reportedAt,
            initial: (existing?.reportedAt ?? DateTime.now())
                .toLocal()
                .toIso8601String(),
            maxLength: 40,
            timestamp: true,
          ),
          RecordField(
            'description',
            context.l10n.description,
            initial: existing?.description ?? '',
            maxLength: 500,
            required: true,
          ),

          RecordField(
            'type',
            context.l10n.incidentType,
            initial: existing?.type ?? 'OTHER',
            options: {
              for (final s in [
                'MATERIAL_SHORTAGE',
                'DELIVERY_DELAY',
                'EQUIPMENT_FAILURE',
                'WORK_ACCIDENT',
                'UNSAFE_CONDITION',
                'OTHER',
                if (existing != null) existing.type,
              ])
                s: localizedValue(context.l10n, s),
            },
          ),
          RecordField(
            'severity',
            context.l10n.severity,
            initial: (existing?.severity ?? IncidentSeverity.medium).apiValue,
            options: {
              for (final s in IncidentSeverity.values)
                s.apiValue: localizedValue(context.l10n, s.apiValue),
            },
          ),
          RecordField(
            'status',
            context.l10n.status,
            initial: (existing?.status ?? IncidentStatus.open).apiValue,
            options: {
              for (final s in IncidentStatus.values)
                s.apiValue: localizedValue(context.l10n, s.apiValue),
            },
          ),
        ],
        onSave: (v) => ref
            .read(incidentsControllerProvider(projectId).notifier)
            .save(
              IncidentRequest(
                projectId: existing == null ? projectId : null,
                status: IncidentStatus.fromApi(v['status']!),
                type: v['type']!,
                description: v['description']!,
                severity: IncidentSeverity.fromApi(v['severity']!),
                reportedAt: DateTime.parse(v['reportedAt']!),
              ),
              id: existing?.id,
            ),
      ),
    ),
  );
}
