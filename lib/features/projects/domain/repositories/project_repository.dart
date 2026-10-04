import '../../../auth/domain/entities/user.dart';
import '../entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects();
  Future<List<User>> getContractors();
  Future<Project> createProject(CreateProjectRequest request);
}
