import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/utils/role_permissions.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../domain/entities/material.dart' as domain;
import '../../domain/entities/material_movement.dart';
import '../controllers/materials_controller.dart';
import '../../../reports/presentation/widgets/alerts_button.dart';
import '../widgets/material_card.dart';
import '../widgets/material_form_sheet.dart';
import '../widgets/material_movement_sheet.dart';

class MaterialsPage extends ConsumerWidget {
  const MaterialsPage({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(materialsControllerProvider(projectId));
    final role = ref.watch(sessionControllerProvider).user?.role;
    final canWrite = role != null && RolePermissions.canWriteMaterials(role);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.materials),
        actions: [
          AlertsButton(projectId: projectId),
          IconButton(
            tooltip: context.l10n.history,
            onPressed: () =>
                context.push('/projects/$projectId/materials/history'),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: state.when(
        loading: () => const AppLoading(),
        error: (_, _) => AppErrorView(
          message: context.l10n.materialsLoadError,
          retryLabel: context.l10n.retry,
          onRetry: ref
              .read(materialsControllerProvider(projectId).notifier)
              .load,
        ),
        data: (materials) => RefreshIndicator(
          onRefresh: ref
              .read(materialsControllerProvider(projectId).notifier)
              .refresh,
          child: materials.isEmpty
              ? ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.55,
                      child: AppEmptyView(
                        message: context.l10n.noMaterials,
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: materials.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => MaterialCard(
                    material: materials[index],
                    canWrite: canWrite,
                    onAction: (action) =>
                        _handleAction(context, ref, materials[index], action),
                  ),
                ),
        ),
      ),
      floatingActionButton: canWrite
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(context, ref),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.newMaterial),
            )
          : null,
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    domain.Material material,
    MaterialAction action,
  ) async {
    switch (action) {
      case MaterialAction.edit:
        await _openForm(context, ref, material: material);
      case MaterialAction.entry:
        await _openMovement(context, material, MovementType.entry);
      case MaterialAction.usage:
        await _openMovement(context, material, MovementType.usage);
      case MaterialAction.delete:
        await _delete(context, ref, material);
    }
  }

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    domain.Material? material,
  }) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      builder: (_) =>
          MaterialFormSheet(projectId: projectId, material: material),
    );
    if (changed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            material == null
                ? context.l10n.materialCreated
                : context.l10n.materialUpdated,
          ),
        ),
      );
    }
  }

  Future<void> _openMovement(
    BuildContext context,
    domain.Material material,
    MovementType type,
  ) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => MaterialMovementSheet(
        projectId: projectId,
        material: material,
        type: type,
      ),
    );
    if (changed == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.movementRegistered)));
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    domain.Material material,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteMaterialTitle),
        content: Text(context.l10n.deleteMaterialMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(materialsControllerProvider(projectId).notifier)
          .delete(material.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.materialDeleted)));
      }
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorMapper.message(context.l10n, error))),
        );
      }
    }
  }
}
