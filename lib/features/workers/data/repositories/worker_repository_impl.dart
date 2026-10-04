import '../../domain/entities/worker.dart';
import '../../domain/entities/worker_request.dart';
import '../../domain/repositories/worker_repository.dart';
import '../datasources/worker_remote_datasource.dart';

class WorkerRepositoryImpl implements WorkerRepository {
  WorkerRepositoryImpl(this.source);
  final WorkerRemoteDataSource source;
  @override
  Future<List<Worker>> list(int projectId) => source.list(projectId);
  @override
  Future<Worker> create(WorkerRequest request) => source.create(request);
  @override
  Future<Worker> update(int id, WorkerRequest request) =>
      source.update(id, request);
  @override
  Future<void> delete(int id) => source.delete(id);
}
