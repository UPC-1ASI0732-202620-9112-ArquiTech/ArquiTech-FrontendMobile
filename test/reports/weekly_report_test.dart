import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:arquitech/app/localization/app_localizations.dart';
import 'package:arquitech/features/reports/domain/entities/week_range.dart';
import 'package:arquitech/features/reports/domain/entities/weekly_report.dart';
import 'package:arquitech/features/reports/presentation/widgets/report_pdf.dart';
import 'package:arquitech/features/tasks/data/models/task_model.dart';
import 'package:arquitech/features/incidents/data/models/incident_model.dart';
import 'package:arquitech/features/materials/data/models/material_movement_model.dart';
import 'package:arquitech/features/materials/data/models/material_model.dart';

import '../support/second_half_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Week matches Web Monday to Sunday, including year boundary', () {
    final w = WeekRange(DateTime(2027, 1, 3));
    expect(w.start, DateTime(2026, 12, 28));
    expect(w.end, DateTime(2027, 1, 3, 23, 59, 59, 999));
    expect(w.contains(w.start), true);
    expect(w.contains(w.end), true);
    expect(w.contains(w.endExclusive), false);
  });
  test('Report uses completion date first, fallback dueDate, current open totals and weekly events', () {
    final w = WeekRange(DateTime(2026, 10, 4));
    final report = WeeklyReport(
      project: sampleProject,
      week: w,
      workers: [sampleWorker],
      tasks: [
        sampleTask,
        TaskModel.fromJson(
          taskJson(
            id: 10,
            status: 'COMPLETED',
            dueDate: '2026-09-01',
            completedAt: DateTime(2026, 9, 30, 14).toIso8601String(),
          ),
        ),
        TaskModel.fromJson(
          taskJson(id: 11, status: 'COMPLETED', dueDate: '2026-09-30'),
        ),
        TaskModel.fromJson(
          taskJson(
            id: 12,
            status: 'COMPLETED',
            dueDate: '2026-09-30',
            completedAt: DateTime(2026, 9, 1).toIso8601String(),
          ),
        ),
      ],
      movements: [
        sampleMovement,
        MaterialMovementModel.fromJson(movementJson(type: 'USAGE')).entity,
        MaterialMovementModel.fromJson(
          movementJson(occurredAt: DateTime(2026, 9, 20).toIso8601String()),
        ).entity,
      ],
      materials: [
        sampleMaterial,
        MaterialModel.fromJson(materialJson(stock: 5)).entity,
      ],
      allIncidents: [
        sampleIncident,
        IncidentModel.fromJson(incidentJson(status: 'RESOLVED')),
        IncidentModel.fromJson(
          incidentJson(reportedAt: DateTime(2026, 9, 20).toIso8601String()),
        ),
      ],
    );
    expect(report.completedTasks.length, 2);
    expect(report.completedTasks.first.task.id, 10);
    expect(report.completedTasks.first.workerName, 'Ana Torres');
    expect(report.openTasks, 1);
    expect(report.entries.length, 1);
    expect(report.usages.length, 1);
    expect(report.incidents.length, 2);
    expect(report.openIncidents, 2);
    expect(report.lowStockMaterials.length, 1);
    expect(report.project.progress, 42);
  });
  test('Empty categories stay empty and PDF is generated locally', () async {
    final r = WeeklyReport(
      project: sampleProject,
      week: WeekRange(DateTime(2026, 10, 4)),
      tasks: [],
      workers: [],
      movements: [],
      materials: [],
      allIncidents: [],
    );
    expect(r.completedTasks, isEmpty);
    final l = await AppLocalizations.delegate.load(const Locale('es'));
    final bytes = await buildReportPdf(r, l);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(1000));
  });
}
