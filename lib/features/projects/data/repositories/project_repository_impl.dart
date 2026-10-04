import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_datasource.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl(this._remote);
  final ProjectRemoteDataSource _remote;

  @override
  Future<void> deleteProject(int id) => _remote.deleteProject(id);

  @override
  Future<Project> createProject(CreateProjectRequest request) =>
      _remote.createProject(request);
  @override
  Future<List<User>> getContractors() => _remote.getContractors();
  @override
  Future<List<Project>> getProjects() => _remote.getProjects();
}
