import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arquitech/app/app.dart';
import 'package:arquitech/app/router/app_router.dart';
import 'package:arquitech/core/providers/app_providers.dart';
import 'package:arquitech/features/auth/domain/entities/user.dart';
import 'package:arquitech/features/auth/presentation/controllers/session_controller.dart';
import 'package:arquitech/features/projects/presentation/controllers/project_context_controller.dart';
import 'package:arquitech/features/projects/presentation/controllers/projects_controller.dart';
import 'package:arquitech/features/materials/presentation/controllers/materials_controller.dart';
import 'package:arquitech/features/workers/presentation/controllers/workers_controller.dart';
import 'package:arquitech/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:arquitech/features/incidents/presentation/controllers/incidents_controller.dart';
import 'package:arquitech/features/machinery/presentation/controllers/machinery_controller.dart';
import 'package:arquitech/features/profile/presentation/controllers/profile_controller.dart';
import 'package:arquitech/features/profile/domain/entities/accessibility_preferences.dart';

import 'package:arquitech/features/attendance/presentation/controllers/attendance_controller.dart';

import '../auth/session_controller_test.dart';
import '../support/fake_repositories.dart';
import '../support/second_half_fixtures.dart';

Future<ProviderContainer> setup(UserRole role) async {
  final secure = FakeSecureStorage();
  final storage = FakePreferences();
  final session = SessionController(secure, storage);
  await session.start(
    user: User(
      id: role == UserRole.supervisor ? 1 : 2,
      fullName: 'User',
      email: 'user@example.test',
      role: role,
    ),
    token: 'test-only-token',
  );
  final container = ProviderContainer(
    overrides: [
      secureStorageProvider.overrideWithValue(secure),
      preferencesStorageProvider.overrideWithValue(storage),
      sessionControllerProvider.overrideWith((ref) => session),
      projectRepositoryProvider.overrideWithValue(FakeProjectRepository()),
      materialRepositoryProvider.overrideWithValue(FakeMaterialRepository()),
      attendanceRepositoryProvider.overrideWithValue(
        FakeAttendanceRepository(),
      ),
      workerRepositoryProvider.overrideWithValue(FakeWorkerRepository()),
      taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
      incidentRepositoryProvider.overrideWithValue(FakeIncidentRepository()),
      machineryRepositoryProvider.overrideWithValue(FakeMachineryRepository()),
    ],
  );
  await container.read(projectContextProvider.notifier).select(sampleProject);
  return container;
}

void main() {
  for (final role in UserRole.values) {
    testWidgets(
      'Integrated ${role.apiValue} routes, project context and logout',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final container = await setup(role);
        addTearDown(container.dispose);
        await container
            .read(accessibilityProvider.notifier)
            .change(
              const AccessibilityPreferences(
                textScale: 1.6,
                highContrast: true,
                reduceMotion: true,
              ),
            );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const ArquiTechApp(),
          ),
        );
        await tester.pumpAndSettle();
        final router = container.read(appRouterProvider);
        for (final module in [
          'materials',
          'attendance',
          'workers',
          'tasks',
          'incidents',
          'machinery',
          'more',
          'reports',
          'profile',
          'settings',
          'alerts',
          'materials/history',
        ]) {
          router.go('/projects/9/$module');
          await tester.pumpAndSettle();
          expect(find.byType(NavigationBar), findsOneWidget);
          expect(tester.takeException(), isNull, reason: module);
          if (module == 'reports') {
            expect(
              find.text('Generar PDF'),
              role == UserRole.supervisor ? findsOneWidget : findsNothing,
            );
          }
        }
        router.go('/projects/10/workers');
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path, '/projects');
        router.go('/projects/invalid/tasks');
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path, '/projects');
        router.go('/projects/9/more');
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Cerrar sesión'));
        await tester.tap(find.text('Cerrar sesión'));
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path, '/login');
        expect(container.read(projectContextProvider), isNull);
        expect(await container.read(secureStorageProvider).readToken(), isNull);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('Protected deep link is rejected after session expiration', (
    tester,
  ) async {
    final container = await setup(UserRole.supervisor);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ArquiTechApp(),
      ),
    );
    await tester.pumpAndSettle();
    container.read(appRouterProvider).go('/projects/9/tasks');
    await tester.pumpAndSettle();
    await container.read(sessionControllerProvider.notifier).expireSession();
    await tester.pumpAndSettle();
    expect(
      container.read(appRouterProvider).routeInformationProvider.value.uri.path,
      '/login',
    );
    expect(container.read(projectContextProvider), isNull);
    expect(tester.takeException(), isNull);
  });
}
