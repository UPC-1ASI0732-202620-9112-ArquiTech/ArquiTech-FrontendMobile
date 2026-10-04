import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/widgets/record_list.dart';
import '../../../../core/widgets/async_action_button.dart';
import '../../../reports/presentation/widgets/alerts_button.dart';
import '../../../../core/widgets/localized_value.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../domain/entities/task.dart';
import '../controllers/tasks_controller.dart';
import '../widgets/task_form.dart';

class TaskPage extends ConsumerWidget {
  const TaskPage({super.key, required this.projectId});
  final int projectId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final write =
        ref.watch(sessionControllerProvider).user?.isSupervisor ?? false;
    final provider = tasksControllerProvider(projectId);
    return RecordList<Task>(
      title: context.l10n.tasks,
      state: ref.watch(provider),
      refresh: () => ref.read(provider.notifier).refresh(),
      statuses: TaskStatus.values.map((s) => s.apiValue).toList(),
      status: (i) => i.status.apiValue,
      searchText: (i) => i.title,
      create: write ? () => showTaskForm(context, ref, projectId) : null,
      actions: [AlertsButton(projectId: projectId)],
      card: (item) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: Theme.of(context).textTheme.titleMedium),
              Text(
                '${item.workerName}\n${item.description}\n${item.dueDate.toIso8601String().split('T').first}',
              ),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(
                      localizedValue(context.l10n, item.status.apiValue),
                    ),
                  ),
                  if (item.isOverdue(DateTime.now()))
                    Chip(label: Text(context.l10n.overdue)),
                ],
              ),
              if (write)
                Wrap(
                  spacing: 8,
                  children: [
                    if (!item.isCompleted)
                      AsyncActionButton(
                        label: context.l10n.complete,
                        action: () =>
                            ref.read(provider.notifier).complete(item),
                      ),
                    TextButton(
                      onPressed: () =>
                          showTaskForm(context, ref, projectId, existing: item),
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
