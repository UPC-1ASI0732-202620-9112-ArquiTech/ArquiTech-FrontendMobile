import '../../../auth/domain/entities/user.dart';
import '../entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects();
  Future<void> deleteProject(int id);
  Future<List<User>> getContractors();
  Future<Project> createProject(CreateProjectRequest request);
}
