import '../entities/incident.dart';
import '../entities/incident_request.dart';

abstract class IncidentRepository {
  Future<List<Incident>> list(int projectId);
  Future<Incident> create(IncidentRequest request);
  Future<Incident> update(int id, IncidentRequest request);
  Future<void> delete(int id);
}
