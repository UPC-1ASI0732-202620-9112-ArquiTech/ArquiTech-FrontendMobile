import '../../../auth/presentation/controllers/session_controller.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/worker_remote_datasource.dart';
import '../../data/repositories/worker_repository_impl.dart';
import '../../domain/repositories/worker_repository.dart';
import '../../domain/entities/worker.dart';
import '../../domain/entities/worker_request.dart';

final workerRepositoryProvider = Provider<WorkerRepository>((ref) {
  ref.watch(sessionControllerProvider.select((s) => s.user?.id));
  return WorkerRepositoryImpl(
    WorkerRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

class WorkerController extends StateNotifier<AsyncValue<List<Worker>>> {
  WorkerController(this.projectId, this.repository)
    : super(const AsyncValue.loading()) {
    load();
  }
  final int projectId;
  final WorkerRepository repository;
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

  Future<void> save(WorkerRequest request, {int? id}) async {
    if (id == null) {
      await repository.create(request);
    } else {
      await repository.update(id, request);
    }
    await refresh();
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    await refresh();
  }
}

final workersControllerProvider = StateNotifierProvider.autoDispose
    .family<WorkerController, AsyncValue<List<Worker>>, int>(
      (ref, id) => WorkerController(id, ref.watch(workerRepositoryProvider)),
    );
