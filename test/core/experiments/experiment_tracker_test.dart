import 'dart:convert';

import 'package:arquitech/app/localization/app_localizations.dart';
import 'package:arquitech/app/theme/app_theme.dart';
import 'package:arquitech/core/errors/api_error.dart';
import 'package:arquitech/core/experiments/experiment_event.dart';
import 'package:arquitech/core/experiments/experiment_tracker.dart';
import 'package:arquitech/core/experiments/experiment_tracking_provider.dart';
import 'package:arquitech/core/providers/app_providers.dart';
import 'package:arquitech/features/auth/domain/entities/user.dart';
import 'package:arquitech/features/auth/presentation/controllers/session_controller.dart';
import 'package:arquitech/features/incidents/presentation/controllers/incidents_controller.dart';
import 'package:arquitech/features/materials/domain/entities/material_movement.dart';
import 'package:arquitech/features/materials/presentation/controllers/materials_controller.dart';
import 'package:arquitech/features/materials/presentation/widgets/material_movement_sheet.dart';
import 'package:arquitech/features/projects/presentation/controllers/projects_controller.dart';
import 'package:arquitech/features/projects/presentation/pages/projects_page.dart';
import 'package:arquitech/features/reports/presentation/pages/reports_page.dart';
import 'package:arquitech/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:arquitech/features/workers/presentation/controllers/workers_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../auth/session_controller_test.dart';
import '../../support/fake_repositories.dart';
import '../../support/second_half_fixtures.dart';

class _TrackingMaterialRepository extends FakeMaterialRepository {
  Object? failure;
  MaterialEntryRequest? lastEntry;
  MaterialUsageRequest? lastUsage;

  @override
  Future<MaterialMovement> registerEntry(
    int materialId,
    MaterialEntryRequest request,
  ) async {
    lastEntry = request;
    if (failure != null) throw failure!;
    return sampleMovement;
  }

  @override
  Future<MaterialMovement> registerUsage(
    int materialId,
    MaterialUsageRequest request,
  ) async {
    lastUsage = request;
    if (failure != null) throw failure!;
    return sampleMovement;
  }
}

class _ThrowingSink implements ExperimentEventSink {
  @override
  void emit(ExperimentEvent event) {
    throw StateError('Simulated sink failure');
  }
}

void main() {
  group('ExperimentTracker & Mobile Tracking Plan (8.2.8)', () {
    test(
      '1 & 2. validates schema_version, closed event catalog, and official EC/Q/metric mappings',
      () {
        expect(TrackedExperimentId.ec01.questionId, 'Q01');
        expect(TrackedExperimentId.ec01.metricIds, ['M01', 'F01']);
        expect(TrackedExperimentId.ec04.questionId, 'Q04');
        expect(TrackedExperimentId.ec04.metricIds, ['M04', 'F01']);
        expect(TrackedExperimentId.ec06.metricIds, ['M06', 'M07', 'F02']);
        expect(TrackedExperimentId.ec08.metricIds, ['M09', 'F01']);
        expect(TrackedExperimentId.ec10.metricIds, ['M11', 'F03']);

        const valid = ExperimentEvent(
          eventName: ExperimentEventName.materialOperationCompleted,
          experimentId: TrackedExperimentId.ec01,
          questionId: 'Q01',
          metricIds: ['M01', 'F01'],
          platform: ExperimentPlatform.mobile,
          condition: ExperimentCondition.a,
          timestamp: '2026-11-10T18:00:00.000Z',
          sessionId: 'sess-0123456789abcdef',
          attemptId: 'att-fedcba9876543210',
          outcome: ExperimentOutcome.completed,
          durationMs: 112,
          operationType: ExperimentOperationType.usage,
        );
        expect(valid.validate().valid, isTrue);

        const mismatchedMetrics = ExperimentEvent(
          eventName: ExperimentEventName.materialOperationCompleted,
          experimentId: TrackedExperimentId.ec01,
          questionId: 'Q04',
          metricIds: ['M04', 'F01'],
          platform: ExperimentPlatform.mobile,
          condition: ExperimentCondition.a,
          timestamp: '2026-11-10T18:00:00.000Z',
          sessionId: 'sess-0123456789abcdef',
          attemptId: 'att-fedcba9876543210',
          outcome: ExperimentOutcome.completed,
          durationMs: 112,
          operationType: ExperimentOperationType.usage,
        );
        expect(mismatchedMetrics.validate().valid, isFalse);
      },
    );

    test(
      '12. rejects sensitive fields (userId, projectId, materialId, emails, JWTs, notes, outcome_correct)',
      () {
        final baseJson = <String, Object?>{
          'schema_version': '1.0',
          'event_name': 'project_consultation_loaded',
          'experiment_id': 'EC04',
          'question_id': 'Q04',
          'metric_ids': ['M04', 'F01'],
          'platform': 'mobile',
          'condition': 'A',
          'timestamp': '2026-11-10T18:00:00.000Z',
          'session_id': 'sess-0123456789abcdef',
          'attempt_id': 'att-0123456789abcdef',
          'outcome': 'loaded',
          'duration_ms': 60,
        };

        for (final forbidden in [
          'userId',
          'projectId',
          'materialId',
          'email',
          'password',
          'jwt',
          'note',
          'description',
          'errorMessage',
          'outcome_correct',
        ]) {
          final polluted = <String, Object?>{...baseJson, forbidden: 'secret'};
          expect(
            ExperimentEvent.validateExperimentEventJson(polluted).valid,
            isFalse,
            reason: 'Should reject $forbidden',
          );
        }

        final jwtSession = <String, Object?>{
          ...baseJson,
          'session_id': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIn0.s',
        };
        expect(
          ExperimentEvent.validateExperimentEventJson(jwtSession).valid,
          isFalse,
        );
      },
    );

    test('13. is disabled by default and acts as a no-op', () {
      final tracker = ExperimentTracker();
      expect(tracker.isEnabled, isFalse);
      final attempt = tracker.startMaterialOperation(
        operationType: ExperimentOperationType.entry,
      );
      attempt.complete();
      expect(tracker.events, isEmpty);
    });

    test(
      '4, 8, 11, 14 & 15. enforces single outcome per attempt, valid monotonic duration, sink fault tolerance, and Web JSON compatibility',
      () {
        var clockMs = 500;
        final debugLines = <String>[];
        final tracker = ExperimentTracker(
          enabled: true,
          sink: _ThrowingSink(),
          debugSink: DebugPrintExperimentEventSink(logger: debugLines.add),
          monotonicMilliseconds: () => clockMs,
          utcTimestamp: () => '2026-11-10T19:00:00.000Z',
        );

        final attempt = tracker.startMaterialOperation(
          condition: ExperimentCondition.a,
          operationType: ExperimentOperationType.usage,
        );
        clockMs = 685;
        attempt.complete();
        // Subsequent terminal calls must be ignored
        clockMs = 999;
        attempt.complete();
        attempt.failApi(errorCategory: ExperimentErrorCategory.network);
        attempt.failValidation(
          errorCategory: ExperimentErrorCategory.insufficientStock,
        );

        expect(tracker.events.length, 2);
        expect(
          tracker.events[0].eventName,
          ExperimentEventName.materialOperationStarted,
        );
        expect(
          tracker.events[1].eventName,
          ExperimentEventName.materialOperationCompleted,
        );
        expect(tracker.events[0].attemptId, tracker.events[1].attemptId);
        expect(tracker.events[1].durationMs, 185);
        expect(debugLines.length, 2);

        final lines = tracker.toJsonLines().split('\n');
        expect(lines.length, 2);
        for (final line in lines) {
          final parsed = Map<String, Object?>.from(
            jsonDecode(line) as Map<String, dynamic>,
          );
          expect(
            ExperimentEvent.validateExperimentEventJson(parsed).valid,
            isTrue,
          );
        }

        // Cross-platform compatibility with Web JSON event
        final webJson = <String, Object?>{
          'schema_version': '1.0',
          'event_name': 'material_operation_failed',
          'experiment_id': 'EC01',
          'question_id': 'Q01',
          'metric_ids': ['M01', 'F01'],
          'platform': 'web',
          'condition': 'B',
          'timestamp': '2026-11-10T19:00:00.000Z',
          'session_id': 'sess-abcdef0123456789',
          'attempt_id': 'att-1234567890abcdef',
          'outcome': 'validation_failed',
          'duration_ms': 40,
          'operation_type': 'USAGE',
          'error_category': 'insufficient_stock',
        };
        expect(
          ExperimentEvent.validateExperimentEventJson(webJson).valid,
          isTrue,
        );
      },
    );

    testWidgets(
      '3, 5, 6, 7, 9 & 10. instruments MaterialMovementSheet on real submit only with condition A',
      (tester) async {
        final tracker = ExperimentTracker(enabled: true);
        final repo = _TrackingMaterialRepository();
        final session = SessionController(FakeSecureStorage(), FakePreferences());
        await session.start(
          user: const User(
            id: 1,
            fullName: 'Supervisor',
            email: 'sup@example.test',
            role: UserRole.supervisor,
          ),
          token: 'test-token',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              experimentTrackerProvider.overrideWithValue(tracker),
              sessionControllerProvider.overrideWith((ref) => session),
              preferencesStorageProvider.overrideWithValue(FakePreferences()),
              materialRepositoryProvider.overrideWithValue(repo),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              locale: const Locale('es'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Scaffold(
                body: MaterialMovementSheet(
                  projectId: 9,
                  material: sampleMaterial,
                  type: MovementType.usage,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 9. Building/rendering the sheet must not emit events
        expect(tracker.events, isEmpty);

        // 6. Validation rejection: quantity exceeds stock (sampleMaterial.stock is 2)
        await tester.enterText(find.byType(TextFormField).first, '999');
        await tester.tap(find.byType(FilledButton));
        await tester.pump();

        expect(tracker.events.length, 2);
        expect(
          tracker.events[0].eventName,
          ExperimentEventName.materialOperationStarted,
        );
        expect(tracker.events[0].condition, ExperimentCondition.a);
        expect(
          tracker.events[1].eventName,
          ExperimentEventName.materialOperationFailed,
        );
        expect(tracker.events[1].outcome, ExperimentOutcome.validationFailed);
        expect(
          tracker.events[1].errorCategory,
          ExperimentErrorCategory.insufficientStock,
        );
        expect(tracker.events[0].attemptId, tracker.events[1].attemptId);

        // 7. API error on valid form submission (1 <= stock 2)
        tracker.clear();
        repo.failure = const ApiError(
          code: 'NETWORK_ERROR',
          message: 'Connection reset by peer',
          statusCode: 0,
        );
        await tester.enterText(find.byType(TextFormField).first, '1');
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();

        expect(tracker.events.length, 2);
        expect(
          tracker.events[1].eventName,
          ExperimentEventName.materialOperationFailed,
        );
        expect(tracker.events[1].outcome, ExperimentOutcome.apiFailed);
        expect(
          tracker.events[1].errorCategory,
          ExperimentErrorCategory.network,
        );

        // 5. API success on valid form submission
        tracker.clear();
        repo.failure = null;
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();

        expect(tracker.events.length, 2);
        expect(
          tracker.events[0].eventName,
          ExperimentEventName.materialOperationStarted,
        );
        expect(
          tracker.events[1].eventName,
          ExperimentEventName.materialOperationCompleted,
        );
        expect(tracker.events[1].condition, ExperimentCondition.a);
        expect(tracker.events[1].outcome, ExperimentOutcome.completed);
      },
    );

    testWidgets(
      '3, 4 & 9. instruments EC04 Condition A across ProjectsPage and ReportsPage without build() emissions',
      (tester) async {
        final tracker = ExperimentTracker(enabled: true);
        final session = SessionController(FakeSecureStorage(), FakePreferences());
        await session.start(
          user: const User(
            id: 2,
            fullName: 'Contractor',
            email: 'contractor@example.test',
            role: UserRole.contractor,
          ),
          token: 'test-token',
        );

        final router = GoRouter(
          initialLocation: '/projects',
          routes: [
            GoRoute(
              path: '/projects',
              builder: (_, _) => const ProjectsPage(),
            ),
            GoRoute(
              path: '/projects/:projectId/materials',
              builder: (_, _) => const ReportsPage(),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              experimentTrackerProvider.overrideWithValue(tracker),
              sessionControllerProvider.overrideWith((ref) => session),
              preferencesStorageProvider.overrideWithValue(FakePreferences()),
              projectRepositoryProvider.overrideWithValue(
                FakeProjectRepository(),
              ),
              taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
              workerRepositoryProvider.overrideWithValue(
                FakeWorkerRepository(),
              ),
              materialRepositoryProvider.overrideWithValue(
                FakeMaterialRepository(),
              ),
              incidentRepositoryProvider.overrideWithValue(
                FakeIncidentRepository(),
              ),
            ],
            child: MaterialApp.router(
              theme: AppTheme.light,
              locale: const Locale('es'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Rendering ProjectsPage must not emit any events
        expect(tracker.events, isEmpty);

        // Selecting a project emits project_consultation_started and navigating to ReportsPage loads it
        await tester.tap(find.text(sampleProject.name));
        await tester.pumpAndSettle();

        expect(
          tracker.events.map((e) => e.eventName).toList(),
          [
            ExperimentEventName.projectConsultationStarted,
            ExperimentEventName.projectConsultationLoaded,
          ],
        );
        expect(tracker.events[0].attemptId, tracker.events[1].attemptId);
        expect(tracker.events[0].condition, ExperimentCondition.a);

        // Opening report once correlates with the active consultation; a second call does not duplicate
        tracker.recordProjectReportOpened(condition: ExperimentCondition.a);
        tracker.recordProjectReportOpened(condition: ExperimentCondition.a);
        expect(
          tracker.events.map((e) => e.eventName).toList(),
          [
            ExperimentEventName.projectConsultationStarted,
            ExperimentEventName.projectConsultationLoaded,
            ExperimentEventName.projectReportOpened,
          ],
        );
        expect(tracker.events[2].attemptId, tracker.events[0].attemptId);

        // Rebuilding ReportsPage must not emit extra events
        await tester.pump();
        expect(tracker.events.length, 3);
      },
    );
  });
}
