import '../../domain/entities/worker_request.dart';

extension WorkerRequestModel on WorkerRequest {
  Map<String, dynamic> toJson() => {
    if (projectId != null) 'projectId': projectId,
    'status': status.apiValue,
    'fullName': fullName,
    'role': role,
    'specialty': specialty,
    'hireDate': hireDate.toIso8601String().split('T').first,
  };
}
