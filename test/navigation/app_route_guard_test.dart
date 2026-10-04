import 'package:arquitech/app/router/app_route_guard.dart';
import 'package:arquitech/features/auth/domain/entities/user.dart';
import 'package:arquitech/features/auth/presentation/controllers/session_controller.dart';
import 'package:arquitech/features/projects/domain/entities/project.dart';
import 'package:flutter_test/flutter_test.dart';

const supervisor = User(
  id: 1,
  fullName: 'Supervisor',
  email: 's@a.pe',
  role: UserRole.supervisor,
);
const contractor = User(
  id: 2,
  fullName: 'Contractor',
  email: 'c@a.pe',
  role: UserRole.contractor,
);
final project = Project(
  id: 9,
  name: 'Obra',
  location: 'Lima',
  startDate: DateTime(2026),
  endDate: DateTime(2027),
  budget: 1,
  status: ProjectStatus.pending,
  progress: 0,
  supervisorId: 1,
  contractorId: 2,
  supervisorName: 'Supervisor',
  contractorName: 'Contractor',
  createdAt: DateTime(2026),
);

void main() {
  test('navigation without session redirects to login', () {
    expect(
      AppRouteGuard.redirectFor(
        session: const SessionState.unauthenticated(),
        location: '/projects',
        selectedProject: null,
      ),
      '/login',
    );
  });

  test('supervisor may open project creation', () {
    expect(
      AppRouteGuard.redirectFor(
        session: const SessionState.authenticated(supervisor),
        location: '/projects/new',
        selectedProject: null,
      ),
      isNull,
    );
  });

  test('contractor is redirected away from project creation', () {
    expect(
      AppRouteGuard.redirectFor(
        session: const SessionState.authenticated(contractor),
        location: '/projects/new',
        selectedProject: null,
      ),
      '/projects',
    );
  });

  test('project route requires matching selected context', () {
    expect(
      AppRouteGuard.redirectFor(
        session: const SessionState.authenticated(supervisor),
        location: '/projects/10/materials',
        selectedProject: project,
      ),
      '/projects',
    );
  });
}
