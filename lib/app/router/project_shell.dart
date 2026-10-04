import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/localization_context.dart';

class ProjectShell extends StatelessWidget {
  const ProjectShell({super.key, required this.projectId, required this.child});
  final int projectId;
  final Widget child;

  int _index(String path) {
    if ((path.contains('/workers') || path.contains('/tasks'))) return 1;
    if (path.contains('/incidents')) return 2;
    if (path.contains('/machinery')) return 3;
    if (path.contains('/more') ||
        path.contains('/reports') ||
        path.contains('/profile') ||
        path.contains('/settings') ||
        path.contains('/alerts')) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        animationDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : null,
        selectedIndex: _index(path),
        onDestinationSelected: (index) {
          final suffix = switch (index) {
            0 => 'materials',
            1 => 'workers',
            2 => 'incidents',
            3 => 'machinery',
            _ => 'more',
          };
          context.go('/projects/$projectId/$suffix');
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            label: context.l10n.materials,
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            label: context.l10n.personnel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.warning_amber_outlined),
            label: context.l10n.incidents,
          ),
          NavigationDestination(
            icon: const Icon(Icons.precision_manufacturing_outlined),
            label: context.l10n.machinery,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            label: context.l10n.more,
          ),
        ],
      ),
    );
  }
}
