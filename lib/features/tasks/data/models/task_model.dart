import '../../domain/entities/task.dart';

class TaskModel {
  static Task fromJson(Map<String, dynamic> json) => Task(
    id: (json['id'] as num).toInt(),
    projectId: (json['projectId'] as num).toInt(),
    status: TaskStatus.fromApi(json['status'] as String),
    workerId: (json['workerId'] as num).toInt(),
    workerName: json['workerName']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    dueDate: DateTime.parse(json['dueDate'] as String),
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? ''),
  );
}
