import '../../../projects/domain/entities/project.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../workers/domain/entities/worker.dart';
import '../../../materials/domain/entities/material.dart';
import '../../../materials/domain/entities/material_movement.dart';
import '../../../incidents/domain/entities/incident.dart';
import 'week_range.dart';

class CompletedTaskEntry {
  const CompletedTaskEntry(this.task, this.workerName, this.completedOn);
  final Task task;
  final String workerName;
  final DateTime completedOn;
}

class WeeklyReport {
  WeeklyReport({
    required this.project,
    required this.week,
    required List<Task> tasks,
    required List<Worker> workers,
    required List<MaterialMovement> movements,
    required List<Material> materials,
    required List<Incident> allIncidents,
  }) : completedTasks =
           tasks
               .where(
                 (t) =>
                     t.isCompleted && week.contains(t.completedAt ?? t.dueDate),
               )
               .map(
                 (t) => CompletedTaskEntry(
                   t,
                   workers
                           .where((w) => w.id == t.workerId)
                           .firstOrNull
                           ?.fullName ??
                       t.workerName,
                   t.completedAt ?? t.dueDate,
                 ),
               )
               .toList()
             ..sort((a, b) => b.completedOn.compareTo(a.completedOn)),
       openTasks = tasks.where((t) => !t.isCompleted).length,
       entries =
           movements
               .where(
                 (m) =>
                     m.type == MovementType.entry &&
                     week.contains(m.occurredAt),
               )
               .toList()
             ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt)),
       usages =
           movements
               .where(
                 (m) =>
                     m.type == MovementType.usage &&
                     week.contains(m.occurredAt),
               )
               .toList()
             ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt)),
       incidents =
           allIncidents.where((i) => week.contains(i.reportedAt)).toList()
             ..sort((a, b) => b.reportedAt.compareTo(a.reportedAt)),
       openIncidents = allIncidents.where((i) => !i.isResolved).length,
       lowStockMaterials = materials.where((m) => m.isLowStock).toList();
  final Project project;
  final WeekRange week;
  final List<CompletedTaskEntry> completedTasks;
  final int openTasks, openIncidents;
  final List<MaterialMovement> entries, usages;
  final List<Incident> incidents;
  final List<Material> lowStockMaterials;
}
