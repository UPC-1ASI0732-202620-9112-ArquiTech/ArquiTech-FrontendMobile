import '../../domain/entities/task.dart';
import '../../domain/entities/task_request.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this.source);
  final TaskRemoteDataSource source;
  @override
  Future<List<Task>> list(int projectId) => source.list(projectId);
  @override
  Future<Task> create(TaskRequest request) => source.create(request);
  @override
  Future<Task> update(int id, TaskRequest request) =>
      source.update(id, request);
  @override
  Future<void> delete(int id) => source.delete(id);
}
