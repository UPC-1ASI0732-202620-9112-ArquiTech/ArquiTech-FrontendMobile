import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arquitech/features/auth/domain/entities/user.dart';
import 'package:arquitech/features/attendance/presentation/pages/attendance_page.dart';
import 'package:arquitech/features/attendance/domain/entities/attendance.dart';
import 'package:arquitech/features/projects/presentation/pages/projects_page.dart';
import 'package:arquitech/features/projects/presentation/controllers/project_context_controller.dart';
import 'package:arquitech/features/projects/presentation/controllers/projects_controller.dart';
import 'package:arquitech/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/role_flows_test.dart' show mount;
import '../navigation/router_integration_test.dart' show setup;
import '../support/fake_repositories.dart';

void main() {
  testWidgets(
    'Supervisor records attendance with project and selected worker',
    (tester) async {
      final repository = FakeAttendanceRepository();
      await mount(
        tester,
        const AttendancePage(projectId: 9),
        UserRole.supervisor,
        attendance: repository,
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Guardar'));
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(repository.saved?.projectId, 9);
      expect(repository.saved?.workerId, 3);
      expect(repository.saved?.status, AttendanceStatus.present);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Supervisor deletion requires exact project name and clears selected project',
    (tester) async {
      final container = await setup(UserRole.supervisor);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ArquiTechApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProjectsPage), findsOneWidget);
      await tester.tap(find.text('Eliminar proyecto'));
      await tester.pumpAndSettle();
      final button = find.widgetWithText(FilledButton, 'Eliminar');
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'Obra Lima');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(container.read(projectContextProvider), isNull);
      expect(container.read(projectsControllerProvider).value, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Contractor never sees delete project control', (tester) async {
    final container = await setup(UserRole.contractor);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ArquiTechApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Eliminar proyecto'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
