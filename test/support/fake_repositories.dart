import 'package:arquitech/features/workers/domain/entities/worker.dart';
import 'package:arquitech/features/workers/domain/entities/worker_request.dart';
import 'package:arquitech/features/workers/domain/repositories/worker_repository.dart';
import 'package:arquitech/features/tasks/domain/entities/task.dart';
import 'package:arquitech/features/tasks/domain/entities/task_request.dart';
import 'package:arquitech/features/tasks/domain/repositories/task_repository.dart';
import 'package:arquitech/features/incidents/domain/entities/incident.dart';
import 'package:arquitech/features/incidents/domain/entities/incident_request.dart';
import 'package:arquitech/features/incidents/domain/repositories/incident_repository.dart';
import 'package:arquitech/features/machinery/domain/entities/machinery.dart';
import 'package:arquitech/features/machinery/domain/repositories/machinery_repository.dart';
import 'package:arquitech/features/materials/domain/entities/material.dart';
import 'package:arquitech/features/materials/domain/entities/material_movement.dart';
import 'package:arquitech/features/materials/domain/repositories/material_repository.dart';
import 'package:arquitech/features/projects/domain/entities/project.dart';
import 'package:arquitech/features/projects/domain/repositories/project_repository.dart';

import 'second_half_fixtures.dart';

import 'package:arquitech/features/attendance/domain/entities/attendance.dart';
import 'package:arquitech/features/attendance/domain/entities/attendance_request.dart';
import 'package:arquitech/features/attendance/domain/repositories/attendance_repository.dart';

class FakeAttendanceRepository implements AttendanceRepository {
  List<Attendance> items = [
    Attendance(
      id: 20,
      projectId: 9,
      workerId: 3,
      workerName: 'Ana Torres',
      attendanceDate: DateTime.now(),
      status: AttendanceStatus.present,
      registeredByUserId: 1,
    ),
  ];
  AttendanceRequest? saved;
  Object? failure;
  @override
  Future<List<Attendance>> list(int projectId, {DateTime? date}) async {
    if (failure != null) throw failure!;
    return items;
  }

  @override
  Future<Attendance> create(AttendanceRequest request) async {
    saved = request;
    if (failure != null) throw failure!;
    return items.first;
  }

  @override
  Future<Attendance> update(int id, AttendanceRequest request) async {
    saved = request;
    if (failure != null) throw failure!;
    return items.first;
  }

  @override
  Future<void> delete(int id) async {
    if (failure != null) throw failure!;
    items = items.where((a) => a.id != id).toList();
  }
}

class FakeWorkerRepository implements WorkerRepository {
  List<Worker> items = [sampleWorker];
  WorkerRequest? saved;
  Object? failure;
  @override
  Future<List<Worker>> list(int id) async {
    if (failure != null) throw failure!;
    return items;
  }

  @override
  Future<Worker> create(WorkerRequest r) async {
    saved = r;
    return sampleWorker;
  }

  @override
  Future<Worker> update(int id, WorkerRequest r) async {
    saved = r;
    return sampleWorker;
  }

  @override
  Future<void> delete(int id) async {
    if (failure != null) throw failure!;
    items = [];
  }
}

class FakeTaskRepository implements TaskRepository {
  List<Task> items = [sampleTask];
  TaskRequest? saved;
  @override
  Future<List<Task>> list(int id) async => items;
  @override
  Future<Task> create(TaskRequest r) async {
    saved = r;
    return sampleTask;
  }

  @override
  Future<Task> update(int id, TaskRequest r) async {
    saved = r;
    return sampleTask;
  }

  @override
  Future<void> delete(int id) async {
    items = [];
  }
}

class FakeIncidentRepository implements IncidentRepository {
  List<Incident> items = [sampleIncident];
  IncidentRequest? saved;
  @override
  Future<List<Incident>> list(int id) async => items;
  @override
  Future<Incident> create(IncidentRequest r) async {
    saved = r;
    return sampleIncident;
  }

  @override
  Future<Incident> update(int id, IncidentRequest r) async {
    saved = r;
    return sampleIncident;
  }

  @override
  Future<void> delete(int id) async {
    items = [];
  }
}

class FakeMachineryRepository implements MachineryRepository {
  @override
  Future<List<Machinery>> list(int id) async => [sampleMachinery];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeMaterialRepository implements MaterialRepository {
  @override
  Future<List<Material>> getMaterials(int id) async => [sampleMaterial];
  @override
  Future<List<MaterialMovement>> getHistory(int id) async => [sampleMovement];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeProjectRepository implements ProjectRepository {
  List<Project> items = [sampleProject];
  Object? failure;
  @override
  Future<void> deleteProject(int id) async {
    if (failure != null) throw failure!;
    items = items.where((p) => p.id != id).toList();
  }

  @override
  Future<List<Project>> getProjects() async => items;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
