import 'package:arquitech/features/materials/data/models/material_movement_model.dart';
import 'package:arquitech/features/materials/domain/entities/material_movement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses material movement history resource', () {
    final movement = MaterialMovementModel.fromJson({
      'id': 5,
      'materialId': 11,
      'projectId': 3,
      'materialName': 'Cemento',
      'unit': 'bolsa',
      'type': 'USAGE',
      'quantity': 2.5,
      'supplier': null,
      'registeredByUserId': 1,
      'registeredByName': 'Ana Torres',
      'occurredAt': '2026-10-03T20:00:00Z',
      'note': 'Vaciado',
    }).entity;

    expect(movement.type, MovementType.usage);
    expect(movement.quantity, 2.5);
    expect(movement.registeredByName, 'Ana Torres');
  });
}
