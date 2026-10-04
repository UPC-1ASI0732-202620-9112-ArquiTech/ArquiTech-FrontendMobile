import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arquitech/app/localization/app_localizations.dart';
import 'package:arquitech/app/theme/app_theme.dart';
import 'package:arquitech/core/providers/app_providers.dart';
import 'package:arquitech/features/auth/domain/entities/user.dart';
import 'package:arquitech/features/auth/presentation/controllers/session_controller.dart';
import 'package:arquitech/features/workers/presentation/controllers/workers_controller.dart';
import 'package:arquitech/features/workers/presentation/pages/workers_page.dart';
import 'package:arquitech/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:arquitech/features/tasks/presentation/pages/tasks_page.dart';
import 'package:arquitech/features/incidents/presentation/controllers/incidents_controller.dart';
import 'package:arquitech/features/incidents/presentation/pages/incidents_page.dart';
import 'package:arquitech/features/machinery/presentation/controllers/machinery_controller.dart';
import 'package:arquitech/features/machinery/presentation/pages/machinery_page.dart';
import 'package:arquitech/features/materials/presentation/controllers/materials_controller.dart';
import 'package:arquitech/features/tasks/domain/entities/task.dart';
import 'package:arquitech/features/incidents/domain/entities/incident.dart';
import 'package:arquitech/features/workers/data/models/worker_model.dart';

import 'package:arquitech/features/attendance/presentation/controllers/attendance_controller.dart';
import 'package:arquitech/features/attendance/presentation/pages/attendance_page.dart';

import '../auth/session_controller_test.dart';
import '../support/fake_repositories.dart';
import '../support/second_half_fixtures.dart';

Future<void> mount(
  WidgetTester tester,
  Widget page,
  UserRole role, {
  FakeAttendanceRepository? attendance,
  FakeWorkerRepository? workers,
  FakeTaskRepository? tasks,
  FakeIncidentRepository? incidents,
  double scale = 1,
  String language = 'es',
}) async {
  final session = SessionController(FakeSecureStorage(), FakePreferences());
  await session.start(
    user: User(
      id: role == UserRole.supervisor ? 1 : 2,
      fullName: 'User',
      email: 'user@example.test',
      role: role,
    ),
    token: 'test-only-token',
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionControllerProvider.overrideWith((ref) => session),
        preferencesStorageProvider.overrideWithValue(FakePreferences()),
        attendanceRepositoryProvider.overrideWithValue(
          attendance ?? FakeAttendanceRepository(),
        ),
        workerRepositoryProvider.overrideWithValue(
          workers ?? FakeWorkerRepository(),
        ),
        taskRepositoryProvider.overrideWithValue(tasks ?? FakeTaskRepository()),
        incidentRepositoryProvider.overrideWithValue(
          incidents ?? FakeIncidentRepository(),
        ),
        machineryRepositoryProvider.overrideWithValue(
          FakeMachineryRepository(),
        ),
        materialRepositoryProvider.overrideWithValue(FakeMaterialRepository()),
      ],
      child: MaterialApp(
        theme: AppTheme.withAccessibility(
          highContrast: true,
          reduceMotion: true,
        ),
        locale: Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: page,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final pages = <String, Widget>{
    'attendance': const AttendancePage(projectId: 9),
    'workers': const WorkerPage(projectId: 9),
    'tasks': const TaskPage(projectId: 9),
    'incidents': const IncidentPage(projectId: 9),
    'machinery': const MachineryPage(projectId: 9),
  };
  for (final e in pages.entries) {
    testWidgets('Contractor ${e.key} has no write actions', (tester) async {
      await mount(tester, e.value, UserRole.contractor);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.text('Editar'), findsNothing);
      expect(find.text('Eliminar'), findsNothing);
      expect(find.text('Completar'), findsNothing);
      expect(find.text('Resolver'), findsNothing);
      expect(tester.takeException(), isNull);
    });
    testWidgets('Supervisor ${e.key} exposes CRUD at extra large scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await mount(tester, e.value, UserRole.supervisor, scale: 1.6);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Eliminar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'Supervisor creates Worker through form, with project from context',
    (tester) async {
      final repo = FakeWorkerRepository();
      await mount(
        tester,
        const WorkerPage(projectId: 9),
        UserRole.supervisor,
        workers: repo,
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Juan Pérez');
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Capataz').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Guardar'));
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(repo.saved?.fullName, 'Juan Pérez');
      expect(repo.saved?.projectId, 9);
      expect(repo.saved?.role, 'Capataz');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Complete Task sends canonical COMPLETED update', (tester) async {
    final repo = FakeTaskRepository();
    await mount(
      tester,
      const TaskPage(projectId: 9),
      UserRole.supervisor,
      tasks: repo,
    );
    await tester.tap(find.text('Completar'));
    await tester.pumpAndSettle();
    expect(repo.saved?.status, TaskStatus.completed);
    expect(repo.saved?.projectId, isNull);
  });
  testWidgets('Resolve Incident sends RESOLVED and preserves reportedAt', (
    tester,
  ) async {
    final repo = FakeIncidentRepository();
    await mount(
      tester,
      const IncidentPage(projectId: 9),
      UserRole.supervisor,
      incidents: repo,
    );
    await tester.tap(find.text('Resolver'));
    await tester.pumpAndSettle();
    expect(repo.saved?.status, IncidentStatus.resolved);
    expect(repo.saved?.reportedAt, sampleIncident.reportedAt);
  });
  testWidgets('New task cannot be assigned to INACTIVE workers', (
    tester,
  ) async {
    final repo = FakeWorkerRepository()
      ..items = [WorkerModel.fromJson(workerJson(status: 'INACTIVE'))];
    await mount(
      tester,
      const TaskPage(projectId: 9),
      UserRole.supervisor,
      workers: repo,
    );
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Registra un trabajador activo o de licencia para asignar tareas.',
      ),
      findsOneWidget,
    );
    expect(find.text('Guardar'), findsNothing);
  });
  testWidgets('Worker search filters cards; English strings are used', (
    tester,
  ) async {
    await mount(
      tester,
      const WorkerPage(projectId: 9),
      UserRole.contractor,
      language: 'en',
    );
    expect(find.text('Workers'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'no match');
    await tester.pump();
    expect(find.text('Ana Torres'), findsNothing);
    expect(find.text('No records match these filters.'), findsOneWidget);
  });
}
