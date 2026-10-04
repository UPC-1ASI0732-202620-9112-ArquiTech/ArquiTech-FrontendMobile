import '../../../auth/presentation/controllers/session_controller.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_request.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  ref.watch(sessionControllerProvider.select((s) => s.user?.id));
  return TaskRepositoryImpl(TaskRemoteDataSource(ref.watch(apiClientProvider)));
});

class TaskController extends StateNotifier<AsyncValue<List<Task>>> {
  TaskController(this.projectId, this.repository)
    : super(const AsyncValue.loading()) {
    load();
  }
  final int projectId;
  final TaskRepository repository;
  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => repository.list(projectId));
    if (mounted) {
      state = result;
    }
  }

  Future<void> refresh() async {
    final result = await AsyncValue.guard(() => repository.list(projectId));
    if (mounted) {
      state = result;
    }
  }

  Future<void> save(TaskRequest request, {int? id}) async {
    if (id == null) {
      await repository.create(request);
    } else {
      await repository.update(id, request);
    }
    await refresh();
  }

  Future<void> complete(Task task) => save(
    TaskRequest(
      workerId: task.workerId,
      title: task.title,
      description: task.description,
      status: TaskStatus.completed,
      dueDate: task.dueDate,
    ),
    id: task.id,
  );
  Future<void> delete(int id) async {
    await repository.delete(id);
    await refresh();
  }
}

final tasksControllerProvider = StateNotifierProvider.autoDispose
    .family<TaskController, AsyncValue<List<Task>>, int>(
      (ref, id) => TaskController(id, ref.watch(taskRepositoryProvider)),
    );
