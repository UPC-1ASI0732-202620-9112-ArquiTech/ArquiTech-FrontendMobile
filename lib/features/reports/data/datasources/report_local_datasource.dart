import '../../../tasks/domain/repositories/task_repository.dart';
import '../../../workers/domain/repositories/worker_repository.dart';
import '../../../materials/domain/repositories/material_repository.dart';
import '../../../incidents/domain/repositories/incident_repository.dart';
import '../../../projects/domain/entities/project.dart';
import '../../domain/entities/week_range.dart';
import '../../domain/entities/weekly_report.dart';
import '../../domain/entities/project_alert.dart';

class ReportLocalDataSource {
  const ReportLocalDataSource(
    this.tasks,
    this.workers,
    this.materials,
    this.incidents,
  );
  final TaskRepository tasks;
  final WorkerRepository workers;
  final MaterialRepository materials;
  final IncidentRepository incidents;
  Future<WeeklyReport> generate(Project project, DateTime date) async {
    final t = tasks.list(project.id);
    final w = workers.list(project.id);
    final h = materials.getHistory(project.id);
    final m = materials.getMaterials(project.id);
    final i = incidents.list(project.id);
    await Future.wait<Object>([t, w, h, m, i]);
    return WeeklyReport(
      project: project,
      week: WeekRange(date),
      tasks: await t,
      workers: await w,
      movements: await h,
      materials: await m,
      allIncidents: await i,
    );
  }

  Future<List<ProjectAlert>> alerts(int projectId) async {
    final m = materials.getMaterials(projectId);
    final i = incidents.list(projectId);
    await Future.wait<Object>([m, i]);
    return [
      for (final incident in await i)
        if (incident.isCritical)
          ProjectAlert(
            name: incident.description,
            module: 'incidents',
            critical: true,
          ),
      for (final material in await m)
        if (material.isLowStock)
          ProjectAlert(
            name: material.name,
            module: 'materials',
            critical: false,
          ),
    ];
  }
}
