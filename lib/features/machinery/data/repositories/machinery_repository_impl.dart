import '../../domain/entities/machinery.dart';
import '../../domain/entities/machinery_request.dart';
import '../../domain/repositories/machinery_repository.dart';
import '../datasources/machinery_remote_datasource.dart';

class MachineryRepositoryImpl implements MachineryRepository {
  MachineryRepositoryImpl(this.source);
  final MachineryRemoteDataSource source;
  @override
  Future<List<Machinery>> list(int projectId) => source.list(projectId);
  @override
  Future<Machinery> create(MachineryRequest request) => source.create(request);
  @override
  Future<Machinery> update(int id, MachineryRequest request) =>
      source.update(id, request);
  @override
  Future<void> delete(int id) => source.delete(id);
}
