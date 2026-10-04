import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../tasks/presentation/controllers/tasks_controller.dart';
import '../../../workers/presentation/controllers/workers_controller.dart';
import '../../../materials/presentation/controllers/materials_controller.dart';
import '../../../incidents/presentation/controllers/incidents_controller.dart';
import '../../../projects/presentation/controllers/project_context_controller.dart';
import '../../data/datasources/report_local_datasource.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/entities/weekly_report.dart';
import '../../domain/entities/project_alert.dart';

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => ReportRepositoryImpl(
    ReportLocalDataSource(
      ref.watch(taskRepositoryProvider),
      ref.watch(workerRepositoryProvider),
      ref.watch(materialRepositoryProvider),
      ref.watch(incidentRepositoryProvider),
    ),
  ),
);
final weeklyReportProvider = FutureProvider.autoDispose
    .family<WeeklyReport, DateTime>((ref, date) {
      final project = ref.watch(projectContextProvider);
      if (project == null) throw StateError('Project required');
      return ref.watch(reportRepositoryProvider).generate(project, date);
    });
final projectAlertsProvider = Provider.autoDispose
    .family<AsyncValue<List<ProjectAlert>>, int>((ref, id) {
      final materials = ref.watch(materialsControllerProvider(id));
      final incidents = ref.watch(incidentsControllerProvider(id));
      if (materials.hasError) {
        return AsyncValue.error(materials.error!, materials.stackTrace!);
      }
      if (incidents.hasError) {
        return AsyncValue.error(incidents.error!, incidents.stackTrace!);
      }
      if (materials.isLoading || incidents.isLoading) {
        return const AsyncValue.loading();
      }
      return AsyncValue.data(
        ProjectAlert.aggregate(materials.requireValue, incidents.requireValue),
      );
    });
Future<void> refreshProjectAlerts(WidgetRef ref, int projectId) => Future.wait([
  ref.read(materialsControllerProvider(projectId).notifier).refresh(),
  ref.read(incidentsControllerProvider(projectId).notifier).refresh(),
]);
