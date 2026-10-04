import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/project.dart';
import '../models/project_model.dart';

class ProjectRemoteDataSource {
  ProjectRemoteDataSource(this._client);
  final ApiClient _client;

  Future<void> deleteProject(int id) =>
      _client.delete(ApiEndpoints.project(id));

  Future<List<Project>> getProjects() async {
    final data = await _client.get(ApiEndpoints.projects) as List<dynamic>;
    return data
        .map(
          (item) =>
              ProjectModel.fromJson(Map<String, dynamic>.from(item as Map))
                  .entity,
        )
        .toList();
  }

  Future<List<User>> getContractors() async {
    final data = await _client.get(ApiEndpoints.users) as List<dynamic>;
    return data
        .map((item) => User.fromJson(Map<String, dynamic>.from(item as Map)))
        .where((user) => user.isContractor)
        .toList();
  }

  Future<Project> createProject(CreateProjectRequest request) async {
    final data = await _client.post(
      ApiEndpoints.projects,
      data: request.toJson(),
    );
    return ProjectModel.fromJson(Map<String, dynamic>.from(data as Map)).entity;
  }
}
