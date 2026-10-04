import '../../../projects/domain/entities/project.dart';
import '../../domain/entities/weekly_report.dart';
import '../../domain/entities/project_alert.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_local_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  const ReportRepositoryImpl(this.source);
  final ReportLocalDataSource source;
  @override
  Future<WeeklyReport> generate(Project project, DateTime date) =>
      source.generate(project, date);
  @override
  Future<List<ProjectAlert>> alerts(int projectId) => source.alerts(projectId);
}
