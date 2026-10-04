enum IncidentStatus {
  open('OPEN'),
  inReview('IN_REVIEW'),
  resolved('RESOLVED');

  const IncidentStatus(this.apiValue);
  final String apiValue;
  static IncidentStatus fromApi(String value) =>
      values.firstWhere((e) => e.apiValue == value);
}

enum IncidentSeverity {
  high('HIGH'),
  medium('MEDIUM'),
  low('LOW');

  const IncidentSeverity(this.apiValue);
  final String apiValue;
  static IncidentSeverity fromApi(String value) =>
      values.firstWhere((e) => e.apiValue == value);
}

class Incident {
  const Incident({
    required this.id,
    required this.projectId,
    required this.status,
    required this.reportedByUserId,
    required this.type,
    required this.description,
    required this.severity,
    required this.reportedAt,
    required this.resolvedAt,
  });
  final int id;
  final int projectId;
  final IncidentStatus status;
  final int reportedByUserId;
  final String type;
  final String description;
  final IncidentSeverity severity;
  final DateTime reportedAt;
  final DateTime? resolvedAt;
  bool get isResolved => status == IncidentStatus.resolved;
  bool get isCritical => severity == IncidentSeverity.high && !isResolved;
}
