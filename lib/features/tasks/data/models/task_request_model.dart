import '../../domain/entities/task_request.dart';

extension TaskRequestModel on TaskRequest {
  Map<String, dynamic> toJson() => {
    if (projectId != null) 'projectId': projectId,
    'status': status.apiValue,
    'workerId': workerId,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String().split('T').first,
  };
}
