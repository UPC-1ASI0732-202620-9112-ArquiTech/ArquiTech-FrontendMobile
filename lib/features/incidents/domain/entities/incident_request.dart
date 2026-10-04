import 'incident.dart';

class IncidentRequest {
  const IncidentRequest({
    this.projectId,
    required this.status,
    required this.type,
    required this.description,
    required this.severity,
    required this.reportedAt,
  });
  final int? projectId;
  final IncidentStatus status;
  final String type;
  final String description;
  final IncidentSeverity severity;
  final DateTime reportedAt;
}
