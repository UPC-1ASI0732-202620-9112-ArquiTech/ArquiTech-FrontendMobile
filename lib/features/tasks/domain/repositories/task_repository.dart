import '../entities/task.dart';
import '../entities/task_request.dart';

abstract class TaskRepository {
  Future<List<Task>> list(int projectId);
  Future<Task> create(TaskRequest request);
  Future<Task> update(int id, TaskRequest request);
  Future<void> delete(int id);
}
