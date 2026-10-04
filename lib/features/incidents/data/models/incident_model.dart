import '../../domain/entities/incident.dart';

class IncidentModel {
  static Incident fromJson(Map<String, dynamic> json) => Incident(
    id: (json['id'] as num).toInt(),
    projectId: (json['projectId'] as num).toInt(),
    status: IncidentStatus.fromApi(json['status'] as String),
    reportedByUserId: (json['reportedByUserId'] as num).toInt(),
    type: json['type']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    severity: IncidentSeverity.fromApi(json['severity'] as String),
    reportedAt: DateTime.parse(json['reportedAt'] as String),
    resolvedAt: DateTime.tryParse(json['resolvedAt']?.toString() ?? ''),
  );
}
