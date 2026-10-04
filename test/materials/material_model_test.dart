import 'package:arquitech/features/materials/data/models/material_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses decimal material quantities and provider data', () {
    final material = MaterialModel.fromJson({
      'id': 11,
      'projectId': 3,
      'name': 'Cemento',
      'unit': 'bolsa',
      'quantity': 100.5,
      'stock': 8.25,
      'minimumStock': 10,
      'unitPrice': 25.9,
      'provider': 'ConstruMax',
      'providerRuc': '20123456789',
      'date': '2026-10-03',
    }).entity;

    expect(material.quantity, 100.5);
    expect(material.stock, 8.25);
    expect(material.providerRuc, '20123456789');
  });
}
