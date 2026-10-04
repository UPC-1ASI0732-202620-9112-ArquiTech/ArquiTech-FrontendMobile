import '../../domain/entities/worker.dart';

class WorkerModel {
  static Worker fromJson(Map<String, dynamic> json) => Worker(
    id: (json['id'] as num).toInt(),
    projectId: (json['projectId'] as num).toInt(),
    status: WorkerStatus.fromApi(json['status'] as String),
    fullName: json['fullName']?.toString() ?? '',
    role: json['role']?.toString() ?? '',
    specialty: json['specialty']?.toString() ?? '',
    hireDate: DateTime.parse(json['hireDate'] as String),
  );
}
