import 'package:flutter_test/flutter_test.dart';
import 'package:arquitech/features/reports/domain/entities/project_alert.dart';
import 'package:arquitech/features/incidents/data/models/incident_model.dart';
import 'package:arquitech/features/materials/data/models/material_model.dart';

import '../support/second_half_fixtures.dart';

void main() {
  test(
    'Alerts use strict low stock and HIGH unresolved incident predicates',
    () {
      final alerts = ProjectAlert.aggregate(
        [sampleMaterial, MaterialModel.fromJson(materialJson(stock: 5)).entity],
        [
          sampleIncident,
          IncidentModel.fromJson(incidentJson(severity: 'MEDIUM')),
          IncidentModel.fromJson(incidentJson(status: 'RESOLVED')),
        ],
      );
      expect(alerts.length, 2);
      expect(alerts.first.critical, true);
      expect(alerts.first.module, 'incidents');
      expect(alerts.last.module, 'materials');
    },
  );
}
