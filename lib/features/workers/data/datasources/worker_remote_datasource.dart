import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/worker.dart';
import '../../domain/entities/worker_request.dart';
import '../models/worker_model.dart';
import '../models/worker_request_model.dart';

class WorkerRemoteDataSource {
  WorkerRemoteDataSource(this.client);
  final ApiClient client;
  Future<List<Worker>> list(int projectId) async =>
      ((await client.get(ApiEndpoints.workersList(projectId))) as List)
          .map((e) => WorkerModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
  Future<Worker> create(WorkerRequest request) async => WorkerModel.fromJson(
    Map<String, dynamic>.from(
      await client.post(ApiEndpoints.workers, data: request.toJson()) as Map,
    ),
  );
  Future<Worker> update(int id, WorkerRequest request) async =>
      WorkerModel.fromJson(
        Map<String, dynamic>.from(
          await client.put(ApiEndpoints.worker(id), data: request.toJson())
              as Map,
        ),
      );
  Future<void> delete(int id) => client.delete(ApiEndpoints.worker(id));
}
