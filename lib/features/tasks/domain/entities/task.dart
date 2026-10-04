enum TaskStatus {
  pending('PENDING'),
  inProgress('IN_PROGRESS'),
  completed('COMPLETED');

  const TaskStatus(this.apiValue);
  final String apiValue;
  static TaskStatus fromApi(String value) =>
      values.firstWhere((e) => e.apiValue == value);
}

class Task {
  const Task({
    required this.id,
    required this.projectId,
    required this.status,
    required this.workerId,
    required this.workerName,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.createdAt,
    required this.completedAt,
  });
  final int id;
  final int projectId;
  final TaskStatus status;
  final int workerId;
  final String workerName;
  final String title;
  final String description;
  final DateTime dueDate;
  final DateTime? createdAt;
  final DateTime? completedAt;
  bool get isCompleted => status == TaskStatus.completed;
  bool isOverdue(DateTime now) =>
      !isCompleted && dueDate.isBefore(DateTime(now.year, now.month, now.day));
}
