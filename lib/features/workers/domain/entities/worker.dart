enum WorkerStatus {
  active('ACTIVE'),
  onLeave('ON_LEAVE'),
  inactive('INACTIVE');

  const WorkerStatus(this.apiValue);
  final String apiValue;
  static WorkerStatus fromApi(String value) =>
      values.firstWhere((e) => e.apiValue == value);
}

class Worker {
  const Worker({
    required this.id,
    required this.projectId,
    required this.status,
    required this.fullName,
    required this.role,
    required this.specialty,
    required this.hireDate,
  });
  final int id;
  final int projectId;
  final WorkerStatus status;
  final String fullName;
  final String role;
  final String specialty;
  final DateTime hireDate;
}
