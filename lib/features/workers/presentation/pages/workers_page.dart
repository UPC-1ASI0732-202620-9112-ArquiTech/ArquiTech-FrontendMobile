import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../tasks/presentation/widgets/task_form.dart';
import '../../../../app/localization/localization_context.dart';
import '../../../../core/widgets/record_list.dart';
import '../../../reports/presentation/widgets/alerts_button.dart';
import '../../../../core/widgets/localized_value.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../domain/entities/worker.dart';
import '../controllers/workers_controller.dart';
import '../widgets/worker_form.dart';

class WorkerPage extends ConsumerWidget {
  const WorkerPage({super.key, required this.projectId});
  final int projectId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final write =
        ref.watch(sessionControllerProvider).user?.isSupervisor ?? false;
    final provider = workersControllerProvider(projectId);
    return RecordList<Worker>(
      title: context.l10n.workers,
      state: ref.watch(provider),
      refresh: () => ref.read(provider.notifier).refresh(),
      statuses: WorkerStatus.values.map((s) => s.apiValue).toList(),
      status: (i) => i.status.apiValue,
      searchText: (i) => '${i.fullName} ${i.role} ${i.specialty}',
      create: write ? () => showWorkerForm(context, ref, projectId) : null,
      actions: [
        AlertsButton(projectId: projectId),
        TextButton(
          onPressed: () => context.push('/projects/$projectId/tasks'),
          child: Text(context.l10n.tasks),
        ),
      ],
      card: (item) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.fullName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${item.role} · ${item.specialty}\n${item.hireDate.toIso8601String().split('T').first}',
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
                    TextButton(
                      onPressed: () => showWorkerForm(
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
                    if (item.status != WorkerStatus.inactive)
                      TextButton(
                        onPressed: () => showTaskForm(
                          context,
                          ref,
                          projectId,
                          assignedWorkerId: item.id,
                        ),
                        child: Text(context.l10n.assignTask),
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
