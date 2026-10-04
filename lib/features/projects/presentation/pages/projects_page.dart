import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/locale_controller.dart';
import '../../../../app/localization/localization_context.dart';
import '../../../../core/utils/role_permissions.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../controllers/project_context_controller.dart';
import '../controllers/projects_controller.dart';
import '../widgets/project_card.dart';

class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectsControllerProvider);
    final user = ref.watch(sessionControllerProvider).user;
    if (user == null) return const Scaffold(body: SizedBox.shrink());
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.projects),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (value) => ref
                .read(localeControllerProvider.notifier)
                .change(Locale(value)),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'es', child: Text(context.l10n.spanish)),
              PopupMenuItem(value: 'en', child: Text(context.l10n.english)),
            ],
          ),
          IconButton(
            tooltip: context.l10n.logout,
            onPressed: () async {
              await ref.read(projectContextProvider.notifier).clear();
              await ref.read(sessionControllerProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: state.when(
        loading: () => const AppLoading(),
        error: (_, _) => AppErrorView(
          message: context.l10n.projectsLoadError,
          retryLabel: context.l10n.retry,
          onRetry: ref.read(projectsControllerProvider.notifier).load,
        ),
        data: (projects) => RefreshIndicator(
          onRefresh: ref.read(projectsControllerProvider.notifier).refresh,
          child: projects.isEmpty
              ? ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.65,
                      child: AppEmptyView(
                        message: context.l10n.noProjects,
                        icon: Icons.apartment_outlined,
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: projects.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return ProjectCard(
                      project: project,
                      onTap: () async {
                        await ref
                            .read(projectContextProvider.notifier)
                            .select(project);
                        if (context.mounted) {
                          context.go('/projects/${project.id}/materials');
                        }
                      },
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: RolePermissions.canCreateProject(user.role)
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/projects/new'),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.newProject),
            )
          : null,
    );
  }
}
