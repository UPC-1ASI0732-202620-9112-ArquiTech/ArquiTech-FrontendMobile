import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../controllers/reports_controller.dart';

class AlertsPage extends ConsumerWidget {
  const AlertsPage({super.key, required this.projectId});
  final int projectId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = projectAlertsProvider(projectId);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.alerts)),
      body: ref
          .watch(provider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AppErrorView(
              message: ErrorMapper.message(context.l10n, e),
              retryLabel: context.l10n.retry,
              onRetry: () => refreshProjectAlerts(ref, projectId),
            ),
            data: (items) => RefreshIndicator(
              onRefresh: () => refreshProjectAlerts(ref, projectId),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(context.l10n.noRecords),
                    ),
                  for (final a in items)
                    ListTile(
                      leading: const Icon(Icons.warning_amber),
                      title: Text(
                        a.critical
                            ? context.l10n.criticalIncident
                            : context.l10n.lowStock,
                      ),
                      subtitle: Text(a.name),
                      onTap: () =>
                          context.go('/projects/$projectId/${a.module}'),
                    ),
                ],
              ),
            ),
          ),
    );
  }
}
