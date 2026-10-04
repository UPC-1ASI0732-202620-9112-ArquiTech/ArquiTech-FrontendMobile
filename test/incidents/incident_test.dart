import 'package:flutter_test/flutter_test.dart';
import 'package:arquitech/features/incidents/data/models/incident_model.dart';
import 'package:arquitech/features/incidents/data/models/incident_request_model.dart';
import 'package:arquitech/features/incidents/domain/entities/incident.dart';
import 'package:arquitech/features/incidents/domain/entities/incident_request.dart';

import '../support/second_half_fixtures.dart';

void main() {
  for (final severity in IncidentSeverity.values) {
    for (final status in IncidentStatus.values) {
      test('Incident ${severity.apiValue} / ${status.apiValue}', () {
        final i = IncidentModel.fromJson(
          incidentJson(severity: severity.apiValue, status: status.apiValue),
        );
        expect(i.severity, severity);
        expect(i.status, status);
        expect(i.isResolved, status == IncidentStatus.resolved);
        expect(
          i.isCritical,
          severity == IncidentSeverity.high &&
              status != IncidentStatus.resolved,
        );
      });
    }
  }
  test('Resolution is parsed from server response', () {
    final i = IncidentModel.fromJson(
      incidentJson(status: 'RESOLVED', resolvedAt: '2026-10-03T18:30:00Z'),
    );
    expect(i.reportedByUserId, 1);
    expect(i.resolvedAt, DateTime.utc(2026, 10, 3, 18, 30));
  });
  test('Incident payload emits UTC and excludes server-managed fields', () {
    final payload = IncidentRequest(
      projectId: 9,
      type: 'OTHER',
      description: 'Issue',
      severity: IncidentSeverity.high,
      status: IncidentStatus.open,
      reportedAt: DateTime.parse('2026-10-03T13:30:00-05:00'),
    ).toJson();
    expect(payload['reportedAt'], '2026-10-03T18:30:00.000Z');
    expect(payload.containsKey('reportedByUserId'), false);
    expect(payload.containsKey('resolvedAt'), false);
  });
}
