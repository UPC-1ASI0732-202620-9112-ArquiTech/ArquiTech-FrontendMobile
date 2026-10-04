import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_request.dart';
import '../models/task_model.dart';
import '../models/task_request_model.dart';

class TaskRemoteDataSource {
  TaskRemoteDataSource(this.client);
  final ApiClient client;
  Future<List<Task>> list(int projectId) async =>
      ((await client.get(ApiEndpoints.tasksList(projectId))) as List)
          .map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
  Future<Task> create(TaskRequest request) async => TaskModel.fromJson(
    Map<String, dynamic>.from(
      await client.post(ApiEndpoints.tasks, data: request.toJson()) as Map,
    ),
  );
  Future<Task> update(int id, TaskRequest request) async => TaskModel.fromJson(
    Map<String, dynamic>.from(
      await client.put(ApiEndpoints.task(id), data: request.toJson()) as Map,
    ),
  );
  Future<void> delete(int id) => client.delete(ApiEndpoints.task(id));
}
