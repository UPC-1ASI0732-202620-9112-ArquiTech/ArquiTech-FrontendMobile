import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/widgets/record_form.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/localized_value.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_request.dart';
import '../controllers/tasks_controller.dart';
import '../../../workers/presentation/controllers/workers_controller.dart';
import '../../../workers/domain/entities/worker.dart';

Future<void> showTaskForm(
  BuildContext context,
  WidgetRef ref,
  int projectId, {
  Task? existing,
  int? assignedWorkerId,
}) async {
  List<Worker> workers;
  try {
    workers = await ref.read(workerRepositoryProvider).list(projectId);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ErrorMapper.message(context.l10n, e))),
      );
    }
    return;
  }
  if (!context.mounted) return;
  final eligible = workers
      .where(
        (w) =>
            w.projectId == projectId &&
            (w.status != WorkerStatus.inactive || w.id == existing?.workerId),
      )
      .toList();
  if (eligible.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.noEligibleWorkers)));
    return;
  }
  if (!context.mounted) return;
  await Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (context) => RecordForm(
        title: existing == null ? context.l10n.create : context.l10n.edit,
        fields: [
          RecordField(
            'title',
            context.l10n.title,
            initial: existing?.title ?? '',
            maxLength: 255,
            required: true,
          ),
          RecordField(
            'description',
            context.l10n.description,
            initial: existing?.description ?? '',
            maxLength: 400,
            required: false,
          ),
          RecordField(
            'dueDate',
            context.l10n.dueDate,
            initial: (existing?.dueDate ?? DateTime.now())
                .toIso8601String()
                .split('T')
                .first,
            maxLength: 10,
            required: true,
            date: true,
          ),
          RecordField(
            'workerId',
            context.l10n.worker,
            initial:
                (existing?.workerId ?? assignedWorkerId ?? eligible.first.id)
                    .toString(),
            options: {for (final w in eligible) w.id.toString(): w.fullName},
          ),

          RecordField(
            'status',
            context.l10n.status,
            initial: (existing?.status ?? TaskStatus.pending).apiValue,
            options: {
              for (final s in TaskStatus.values)
                s.apiValue: localizedValue(context.l10n, s.apiValue),
            },
          ),
        ],
        onSave: (v) => ref
            .read(tasksControllerProvider(projectId).notifier)
            .save(
              TaskRequest(
                projectId: existing == null ? projectId : null,
                status: TaskStatus.fromApi(v['status']!),
                workerId: int.parse(v['workerId']!),
                title: v['title']!,
                description: v['description']!,
                dueDate: DateTime.parse(v['dueDate']!),
              ),
              id: existing?.id,
            ),
      ),
    ),
  );
}
