import 'worker.dart';

class WorkerRequest {
  const WorkerRequest({
    this.projectId,
    required this.status,
    required this.fullName,
    required this.role,
    required this.specialty,
    required this.hireDate,
  });
  final int? projectId;
  final WorkerStatus status;
  final String fullName;
  final String role;
  final String specialty;
  final DateTime hireDate;
}
