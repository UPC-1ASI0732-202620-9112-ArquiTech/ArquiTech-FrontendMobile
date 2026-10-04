import 'package:flutter_test/flutter_test.dart';
import 'package:arquitech/features/tasks/data/models/task_model.dart';
import 'package:arquitech/features/tasks/data/models/task_request_model.dart';
import 'package:arquitech/features/tasks/domain/entities/task.dart';
import 'package:arquitech/features/tasks/domain/entities/task_request.dart';

import '../support/second_half_fixtures.dart';

void main() {
  test('Task parsing preserves completedAt and optional description', () {
    final t = TaskModel.fromJson(
      taskJson(status: 'COMPLETED', completedAt: '2026-10-03T18:30:00Z'),
    );
    expect(t.isCompleted, isTrue);
    expect(t.completedAt, DateTime.utc(2026, 10, 3, 18, 30));
    expect(t.description, '');
  });
  for (final status in TaskStatus.values) {
    test(
      'Task parses ${status.apiValue}',
      () => expect(
        TaskModel.fromJson(taskJson(status: status.apiValue)).status,
        status,
      ),
    );
  }
  test('Due today is not overdue; yesterday is overdue until completed', () {
    final today = DateTime(2026, 10, 4, 23, 59);
    expect(
      TaskModel.fromJson(taskJson(dueDate: '2026-10-04')).isOverdue(today),
      isFalse,
    );
    expect(sampleTask.isOverdue(today), isTrue);
    expect(
      TaskModel.fromJson(taskJson(status: 'COMPLETED')).isOverdue(today),
      isFalse,
    );
  });
  test('Task create and update serialize only canonical client fields', () {
    final r = TaskRequest(
      projectId: 9,
      workerId: 3,
      title: 'Task',
      description: '',
      status: TaskStatus.pending,
      dueDate: DateTime(2026, 10, 4),
    );
    expect(r.toJson(), {
      'projectId': 9,
      'workerId': 3,
      'title': 'Task',
      'description': '',
      'status': 'PENDING',
      'dueDate': '2026-10-04',
    });
    final update = TaskRequest(
      workerId: 3,
      title: 'Task',
      description: '',
      status: TaskStatus.completed,
      dueDate: DateTime(2026, 10, 4),
    ).toJson();
    expect(update.containsKey('projectId'), false);
    expect(update.containsKey('completedAt'), false);
    expect(update['status'], 'COMPLETED');
  });
}
