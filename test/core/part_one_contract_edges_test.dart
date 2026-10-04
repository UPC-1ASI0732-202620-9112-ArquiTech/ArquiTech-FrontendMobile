import 'package:flutter_test/flutter_test.dart';
import 'package:arquitech/features/materials/data/models/material_model.dart';
import 'package:arquitech/features/materials/data/models/material_movement_model.dart';
import 'package:arquitech/features/materials/domain/entities/material_movement.dart';

import '../support/second_half_fixtures.dart';

void main() {
  test(
    'Material response allows absent legacy date without inventing a date',
    () {
      final json = materialJson()..['date'] = null;
      expect(MaterialModel.fromJson(json).entity.date, isNull);
    },
  );
  test('Material entry and usage emit canonical UTC OffsetDateTime', () {
    final at = DateTime.parse('2026-10-03T13:30:00-05:00');
    expect(
      MaterialEntryRequest(
        quantity: 2,
        supplier: 'Provider',
        occurredAt: at,
        note: '',
      ).toJson()['occurredAt'],
      '2026-10-03T18:30:00.000Z',
    );
    expect(
      MaterialUsageRequest(
        quantity: 1,
        occurredAt: at,
        note: '',
      ).toJson()['occurredAt'],
      '2026-10-03T18:30:00.000Z',
    );
  });
}
