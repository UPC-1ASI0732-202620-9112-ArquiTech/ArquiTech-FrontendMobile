import 'package:flutter_test/flutter_test.dart';
import 'package:arquitech/features/workers/data/models/worker_model.dart';
import 'package:arquitech/features/workers/data/models/worker_request_model.dart';
import 'package:arquitech/features/workers/domain/entities/worker.dart';
import 'package:arquitech/features/workers/domain/entities/worker_request.dart';
import 'package:arquitech/core/errors/error_mapper.dart';
import 'package:arquitech/core/errors/api_error.dart';
import 'package:arquitech/app/localization/app_localizations.dart';
import 'package:flutter/widgets.dart';

import '../support/second_half_fixtures.dart';

void main() {
  test('Worker preserves String role, LocalDate and nullable specialty', () {
    final w = WorkerModel.fromJson(workerJson());
    expect(w.id, 3);
    expect(w.role, 'Capataz');
    expect(w.specialty, '');
    expect(w.hireDate, DateTime(2026, 9, 1));
  });
  for (final status in WorkerStatus.values) {
    test(
      'Worker parses ${status.apiValue}',
      () => expect(
        WorkerModel.fromJson(workerJson(status: status.apiValue)).status,
        status,
      ),
    );
  }
  test('Worker update omits project id', () {
    final r = WorkerRequest(
      fullName: 'Ana',
      role: 'Capataz',
      specialty: '',
      hireDate: DateTime(2026, 9, 1),
      status: WorkerStatus.active,
    ).toJson();
    expect(r.containsKey('projectId'), isFalse);
    expect(r['hireDate'], '2026-09-01');
  });
  test('WORKER_HAS_TASKS gives actionable localized message', () async {
    final l = await AppLocalizations.delegate.load(const Locale('es'));
    expect(
      ErrorMapper.message(
        l,
        const ApiError(code: 'WORKER_HAS_TASKS', message: 'conflict'),
      ),
      l.errorWorkerHasTasks,
    );
  });
}
