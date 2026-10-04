import '../../features/auth/presentation/controllers/session_controller.dart';
import '../../features/projects/domain/entities/project.dart';

abstract final class AppRouteGuard {
  static String? redirectFor({
    required SessionState session,
    required String location,
    required Project? selectedProject,
  }) {
    if (session.status == SessionStatus.restoring) {
      return location == '/splash' ? null : '/splash';
    }
    if (!session.isAuthenticated) {
      return location == '/login' ? null : '/login';
    }
    if (location == '/login' || location == '/splash') return '/projects';
    if (location == '/projects/new' && session.user!.isContractor) {
      return '/projects';
    }
    final match = RegExp(r'^/projects/(\d+)/').firstMatch(location);
    if (match != null) {
      final routeProjectId = int.tryParse(match.group(1)!);
      if (selectedProject == null || selectedProject.id != routeProjectId) {
        return '/projects';
      }
    }
    return null;
  }
}
