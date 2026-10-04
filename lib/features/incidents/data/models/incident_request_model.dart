import '../../domain/entities/incident_request.dart';

extension IncidentRequestModel on IncidentRequest {
  Map<String, dynamic> toJson() => {
    if (projectId != null) 'projectId': projectId,
    'status': status.apiValue,
    'type': type,
    'description': description,
    'severity': severity.apiValue,
    'reportedAt': reportedAt.toUtc().toIso8601String(),
  };
}
