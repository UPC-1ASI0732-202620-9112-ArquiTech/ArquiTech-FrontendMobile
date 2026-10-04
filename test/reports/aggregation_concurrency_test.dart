import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:arquitech/features/reports/data/datasources/report_local_datasource.dart';
import 'package:arquitech/features/workers/domain/entities/worker.dart';
import 'package:arquitech/features/tasks/domain/entities/task.dart';
import 'package:arquitech/features/incidents/domain/entities/incident.dart';
import 'package:arquitech/features/materials/domain/entities/material.dart';
import 'package:arquitech/features/materials/domain/entities/material_movement.dart';

import '../support/fake_repositories.dart';
import '../support/second_half_fixtures.dart';

class DelayedWorkers extends FakeWorkerRepository {
  DelayedWorkers(this.gate, this.calls);
  final Future<void> gate;
  final List<String> calls;
  @override
  Future<List<Worker>> list(int id) {
    calls.add('workers');
    return gate.then((_) => super.list(id));
  }
}

class DelayedTasks extends FakeTaskRepository {
  DelayedTasks(this.gate, this.calls);
  final Future<void> gate;
  final List<String> calls;
  @override
  Future<List<Task>> list(int id) {
    calls.add('tasks');
    return gate.then((_) => super.list(id));
  }
}

class DelayedIncidents extends FakeIncidentRepository {
  DelayedIncidents(this.gate, this.calls);
  final Future<void> gate;
  final List<String> calls;
  @override
  Future<List<Incident>> list(int id) {
    calls.add('incidents');
    return gate.then((_) => super.list(id));
  }
}

class DelayedMaterials extends FakeMaterialRepository {
  DelayedMaterials(this.gate, this.calls);
  final Future<void> gate;
  final List<String> calls;
  @override
  Future<List<Material>> getMaterials(int id) {
    calls.add('materials');
    return gate.then((_) => super.getMaterials(id));
  }

  @override
  Future<List<MaterialMovement>> getHistory(int id) {
    calls.add('history');
    return gate.then((_) => super.getHistory(id));
  }
}

void main() {
  test(
    'Weekly report starts all five requests before waiting for any response',
    () async {
      final gate = Completer<void>();
      final calls = <String>[];
      final source = ReportLocalDataSource(
        DelayedTasks(gate.future, calls),
        DelayedWorkers(gate.future, calls),
        DelayedMaterials(gate.future, calls),
        DelayedIncidents(gate.future, calls),
      );
      final report = source.generate(sampleProject, DateTime(2026, 10, 4));
      expect(calls.toSet(), {
        'tasks',
        'workers',
        'history',
        'materials',
        'incidents',
      });
      gate.complete();
      expect((await report).project.id, 9);
    },
  );
}
