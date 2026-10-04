import '../entities/worker.dart';
import '../entities/worker_request.dart';

abstract class WorkerRepository {
  Future<List<Worker>> list(int projectId);
  Future<Worker> create(WorkerRequest request);
  Future<Worker> update(int id, WorkerRequest request);
  Future<void> delete(int id);
}
