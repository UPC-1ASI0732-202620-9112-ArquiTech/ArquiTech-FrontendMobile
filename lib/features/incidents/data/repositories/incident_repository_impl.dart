import '../../domain/entities/incident.dart';
import '../../domain/entities/incident_request.dart';
import '../../domain/repositories/incident_repository.dart';
import '../datasources/incident_remote_datasource.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  IncidentRepositoryImpl(this.source);
  final IncidentRemoteDataSource source;
  @override
  Future<List<Incident>> list(int projectId) => source.list(projectId);
  @override
  Future<Incident> create(IncidentRequest request) => source.create(request);
  @override
  Future<Incident> update(int id, IncidentRequest request) =>
      source.update(id, request);
  @override
  Future<void> delete(int id) => source.delete(id);
}
