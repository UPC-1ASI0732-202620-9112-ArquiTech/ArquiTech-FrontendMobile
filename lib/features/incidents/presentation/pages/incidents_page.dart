import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/widgets/record_list.dart';
import '../../../../core/widgets/async_action_button.dart';
import '../../../reports/presentation/widgets/alerts_button.dart';
import '../../../../core/widgets/localized_value.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../domain/entities/incident.dart';
import '../controllers/incidents_controller.dart';
import '../widgets/incident_form.dart';

class IncidentPage extends ConsumerWidget {
  const IncidentPage({super.key, required this.projectId});
  final int projectId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final write =
        ref.watch(sessionControllerProvider).user?.isSupervisor ?? false;
    final provider = incidentsControllerProvider(projectId);
    return RecordList<Incident>(
      title: context.l10n.incidents,
      state: ref.watch(provider),
      refresh: () => ref.read(provider.notifier).refresh(),
      statuses: IncidentStatus.values.map((s) => s.apiValue).toList(),
      status: (i) => i.status.apiValue,
      searchText: (i) => i.description,
      create: write ? () => showIncidentForm(context, ref, projectId) : null,
      actions: [AlertsButton(projectId: projectId)],
      card: (item) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.description,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${localizedValue(context.l10n, item.type)} · ${localizedValue(context.l10n, item.severity.apiValue)}\n${item.reportedAt.toLocal()}',
              ),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(
                      localizedValue(context.l10n, item.status.apiValue),
                    ),
                  ),
                ],
              ),
              if (write)
                Wrap(
                  spacing: 8,
                  children: [
                    if (!item.isResolved)
                      AsyncActionButton(
                        label: context.l10n.resolve,
                        action: () => ref.read(provider.notifier).resolve(item),
                      ),
                    TextButton(
                      onPressed: () => showIncidentForm(
                        context,
                        ref,
                        projectId,
                        existing: item,
                      ),
                      child: Text(context.l10n.edit),
                    ),
                    TextButton(
                      onPressed: () => deleteRecord(
                        context,
                        () => ref.read(provider.notifier).delete(item.id),
                      ),
                      child: Text(context.l10n.delete),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
