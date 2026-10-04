import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../domain/entities/project.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.onDelete,
  });
  final Project project;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final currency = NumberFormat.simpleCurrency(
      locale: locale,
      decimalDigits: 0,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: AppColors.fulvous,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                project.name,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(project.location)),
                      _ProjectStatus(status: project.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: project.progress / 100,
                      minHeight: 9,
                      backgroundColor: AppColors.warningContainer,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${context.l10n.progress}: ${project.progress}%'),
                  if (onDelete != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        label: Text(context.l10n.deleteProject),
                      ),
                    ),
                  const Divider(height: 28),
                  Row(
                    children: [
                      Expanded(child: Text(currency.format(project.budget))),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectStatus extends StatelessWidget {
  const _ProjectStatus({required this.status});
  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, foreground, background) = switch (status) {
      ProjectStatus.active => (
        context.l10n.statusActive,
        const Color(0xFF1B7337),
        AppColors.successContainer,
      ),
      ProjectStatus.pending => (
        context.l10n.statusPending,
        const Color(0xFF855400),
        AppColors.warningContainer,
      ),
      ProjectStatus.completed => (
        context.l10n.statusCompleted,
        const Color(0xFF1B6473),
        const Color(0xFFE0F2F6),
      ),
      ProjectStatus.suspended => (
        context.l10n.statusSuspended,
        AppColors.sinopia,
        AppColors.dangerContainer,
      ),
    };
    return AppStatusChip(
      label: label,
      foreground: foreground,
      background: background,
    );
  }
}
