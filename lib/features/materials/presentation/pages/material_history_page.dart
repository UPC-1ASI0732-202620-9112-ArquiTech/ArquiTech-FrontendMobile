import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/entities/material_movement.dart';
import '../controllers/materials_controller.dart';

class MaterialHistoryPage extends ConsumerStatefulWidget {
  const MaterialHistoryPage({super.key, required this.projectId});
  final int projectId;

  @override
  ConsumerState<MaterialHistoryPage> createState() =>
      _MaterialHistoryPageState();
}

class _MaterialHistoryPageState extends ConsumerState<MaterialHistoryPage> {
  MovementType? _filter;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(movementsControllerProvider(widget.projectId));
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.movementHistory)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<MovementType?>(
              initialValue: _filter,
              decoration: InputDecoration(labelText: context.l10n.filterByType),
              items: [
                DropdownMenuItem(value: null, child: Text(context.l10n.all)),
                DropdownMenuItem(
                  value: MovementType.entry,
                  child: Text(context.l10n.entry),
                ),
                DropdownMenuItem(
                  value: MovementType.usage,
                  child: Text(context.l10n.usage),
                ),
              ],
              onChanged: (value) => setState(() => _filter = value),
            ),
          ),
          Expanded(
            child: state.when(
              loading: () => const AppLoading(),
              error: (_, _) => AppErrorView(
                message: context.l10n.genericError,
                retryLabel: context.l10n.retry,
                onRetry: ref
                    .read(
                      movementsControllerProvider(widget.projectId).notifier,
                    )
                    .load,
              ),
              data: (movements) {
                final filtered = _filter == null
                    ? movements
                    : movements
                          .where((movement) => movement.type == _filter)
                          .toList();
                if (filtered.isEmpty) {
                  return AppEmptyView(
                    message: context.l10n.noMovements,
                    icon: Icons.history,
                  );
                }
                return RefreshIndicator(
                  onRefresh: ref
                      .read(
                        movementsControllerProvider(widget.projectId).notifier,
                      )
                      .load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, index) =>
                        _MovementCard(movement: filtered[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementCard extends StatelessWidget {
  const _MovementCard({required this.movement});
  final MaterialMovement movement;

  @override
  Widget build(BuildContext context) {
    final entry = movement.type == MovementType.entry;
    return Card(
      child: ListTile(
        minVerticalPadding: 14,
        leading: CircleAvatar(
          backgroundColor: entry
              ? Colors.green.shade100
              : Colors.orange.shade100,
          child: Icon(
            entry ? Icons.south_west : Icons.north_east,
            color: entry ? Colors.green.shade800 : Colors.orange.shade900,
          ),
        ),
        title: Text(movement.materialName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppDateUtils.displayDateTime(
                movement.occurredAt,
                Localizations.localeOf(context).languageCode,
              ),
            ),
            if ((movement.supplier ?? '').isNotEmpty)
              Text('${context.l10n.supplier}: ${movement.supplier}'),
            if ((movement.registeredByName ?? '').isNotEmpty)
              Text(
                '${context.l10n.registeredBy}: ${movement.registeredByName}',
              ),
            if ((movement.note ?? '').isNotEmpty) Text(movement.note!),
          ],
        ),
        trailing: Text(
          '${entry ? '+' : '-'}${movement.quantity} ${movement.unit}',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: entry ? Colors.green.shade800 : Colors.orange.shade900,
          ),
        ),
      ),
    );
  }
}
