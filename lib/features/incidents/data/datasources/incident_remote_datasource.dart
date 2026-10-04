import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/incident.dart';
import '../../domain/entities/incident_request.dart';
import '../models/incident_model.dart';
import '../models/incident_request_model.dart';

class IncidentRemoteDataSource {
  IncidentRemoteDataSource(this.client);
  final ApiClient client;
  Future<List<Incident>> list(int projectId) async =>
      ((await client.get(ApiEndpoints.incidentsList(projectId))) as List)
          .map(
            (e) => IncidentModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
  Future<Incident> create(IncidentRequest request) async =>
      IncidentModel.fromJson(
        Map<String, dynamic>.from(
          await client.post(ApiEndpoints.incidents, data: request.toJson())
              as Map,
        ),
      );
  Future<Incident> update(int id, IncidentRequest request) async =>
      IncidentModel.fromJson(
        Map<String, dynamic>.from(
          await client.put(ApiEndpoints.incident(id), data: request.toJson())
              as Map,
        ),
      );
  Future<void> delete(int id) => client.delete(ApiEndpoints.incident(id));
}
