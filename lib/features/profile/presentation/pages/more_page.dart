import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/locale_controller.dart';
import '../../../../app/localization/localization_context.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../../projects/presentation/controllers/project_context_controller.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectContextProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.more)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.apartment_outlined),
            title: Text(context.l10n.selectedProject),
            subtitle: Text(project?.name ?? ''),
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
            leading: const Icon(Icons.history),
            title: Text(context.l10n.movementHistory),
            onTap: () => context.push('/projects/$projectId/materials/history'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.l10n.language),
            trailing: DropdownButton<String>(
              value: ref.watch(localeControllerProvider).languageCode,
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem(
                  value: 'es',
                  child: Text(context.l10n.spanish),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text(context.l10n.english),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(localeControllerProvider.notifier)
                      .change(Locale(value));
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(context.l10n.reports),
            subtitle: Text(context.l10n.comingSoon),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(context.l10n.profile),
            subtitle: Text(context.l10n.comingSoon),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
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
}
