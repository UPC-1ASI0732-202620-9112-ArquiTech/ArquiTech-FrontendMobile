import '../../../projects/domain/entities/project.dart';
import '../entities/weekly_report.dart';
import '../entities/project_alert.dart';

abstract class ReportRepository {
  Future<WeeklyReport> generate(Project project, DateTime date);
  Future<List<ProjectAlert>> alerts(int projectId);
}
