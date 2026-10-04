import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/session_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/incidents/presentation/pages/incidents_placeholder_page.dart';
import '../../features/machinery/presentation/pages/machinery_placeholder_page.dart';
import '../../features/materials/presentation/pages/material_history_page.dart';
import '../../features/materials/presentation/pages/materials_page.dart';
import '../../features/profile/presentation/pages/more_page.dart';
import '../../features/projects/presentation/controllers/project_context_controller.dart';
import '../../features/projects/presentation/pages/create_project_page.dart';
import '../../features/projects/presentation/pages/projects_page.dart';
import '../../features/workers/presentation/pages/workers_placeholder_page.dart';
import 'app_route_guard.dart';
import 'project_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefreshNotifier();
  ref
    ..listen(sessionControllerProvider, (_, _) => refresh.notify())
    ..listen(projectContextProvider, (_, _) => refresh.notify())
    ..onDispose(refresh.dispose);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (_, state) => AppRouteGuard.redirectFor(
      session: ref.read(sessionControllerProvider),
      location: state.uri.path,
      selectedProject: ref.read(projectContextProvider),
    ),
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const _SplashPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/projects', builder: (_, _) => const ProjectsPage()),
      GoRoute(
        path: '/projects/new',
        builder: (_, _) => const CreateProjectPage(),
      ),
      ShellRoute(
        builder: (_, state, child) => ProjectShell(
          projectId: int.parse(state.pathParameters['projectId']!),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/projects/:projectId/materials',
            builder: (_, state) => MaterialsPage(
              projectId: int.parse(state.pathParameters['projectId']!),
            ),
          ),
          GoRoute(
            path: '/projects/:projectId/materials/history',
            builder: (_, state) => MaterialHistoryPage(
              projectId: int.parse(state.pathParameters['projectId']!),
            ),
          ),
          GoRoute(
            path: '/projects/:projectId/workers',
            builder: (_, _) => const WorkersPlaceholderPage(),
          ),
          GoRoute(
            path: '/projects/:projectId/incidents',
            builder: (_, _) => const IncidentsPlaceholderPage(),
          ),
          GoRoute(
            path: '/projects/:projectId/machinery',
            builder: (_, _) => const MachineryPlaceholderPage(),
          ),
          GoRoute(
            path: '/projects/:projectId/more',
            builder: (_, state) => MorePage(
              projectId: int.parse(state.pathParameters['projectId']!),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (_, _) => const ProjectsPage(),
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator.adaptive()));
}
