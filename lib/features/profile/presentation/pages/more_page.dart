import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../../reports/presentation/widgets/alerts_button.dart';
import '../../../projects/presentation/controllers/project_context_controller.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key, required this.projectId});
  final int projectId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.more),
      actions: [AlertsButton(projectId: projectId)],
    ),
    body: ListView(
      children: [
        ListTile(
          title: Text(context.l10n.selectedProject),
          subtitle: Text(ref.watch(projectContextProvider)?.name ?? ''),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: Text(context.l10n.reports),
          onTap: () => context.push('/projects/$projectId/reports'),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(context.l10n.profile),
          onTap: () => context.push('/projects/$projectId/profile'),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: Text(context.l10n.settings),
          onTap: () => context.push('/projects/$projectId/settings'),
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: Text(context.l10n.alerts),
          onTap: () => context.push('/projects/$projectId/alerts'),
        ),
        ListTile(
          leading: const Icon(Icons.swap_horiz),
          title: Text(context.l10n.changeProject),
          onTap: () async {
            await ref.read(projectContextProvider.notifier).clear();
            if (context.mounted) context.go('/projects');
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: Text(context.l10n.logout),
          onTap: () async {
            await ref.read(projectContextProvider.notifier).clear();
            await ref.read(sessionControllerProvider.notifier).logout();
          },
        ),
      ],
    ),
  );
}
