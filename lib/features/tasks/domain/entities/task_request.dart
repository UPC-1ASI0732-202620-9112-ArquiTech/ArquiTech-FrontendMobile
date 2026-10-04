import 'task.dart';

class TaskRequest {
  const TaskRequest({
    this.projectId,
    required this.status,
    required this.workerId,
    required this.title,
    required this.description,
    required this.dueDate,
  });
  final int? projectId;
  final TaskStatus status;
  final int workerId;
  final String title;
  final String description;
  final DateTime dueDate;
}
