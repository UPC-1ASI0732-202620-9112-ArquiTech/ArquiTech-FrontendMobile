import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/widgets/record_list.dart';
import '../../../reports/presentation/widgets/alerts_button.dart';
import '../../../../core/widgets/localized_value.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../domain/entities/machinery.dart';
import '../controllers/machinery_controller.dart';
import '../widgets/machinery_form.dart';

class MachineryPage extends ConsumerWidget {
  const MachineryPage({super.key, required this.projectId});
  final int projectId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final write =
        ref.watch(sessionControllerProvider).user?.isSupervisor ?? false;
    final provider = machineryControllerProvider(projectId);
    return RecordList<Machinery>(
      title: context.l10n.machinery,
      state: ref.watch(provider),
      refresh: () => ref.read(provider.notifier).refresh(),
      statuses: MachineryStatus.values.map((s) => s.apiValue).toList(),
      status: (i) => i.status.apiValue,
      searchText: (i) => '${i.name} ${i.serialNumber}',
      create: write ? () => showMachineryForm(context, ref, projectId) : null,
      actions: [AlertsButton(projectId: projectId)],
      card: (item) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: Theme.of(context).textTheme.titleMedium),
              Text(
                '${item.serialNumber}\n${item.description}\n${item.registeredAt.toIso8601String().split('T').first}',
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
                      onPressed: () => showMachineryForm(
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
