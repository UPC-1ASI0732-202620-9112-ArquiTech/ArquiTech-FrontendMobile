import 'package:arquitech/features/materials/domain/entities/material.dart';
import 'package:flutter_test/flutter_test.dart';

final material = Material(
  id: 1,
  projectId: 2,
  name: 'Acero',
  unit: 'varilla',
  quantity: 20,
  stock: 4,
  minimumStock: 5,
  unitPrice: 15,
  provider: 'Proveedor',
  providerRuc: '20123456789',
  date: testDate,
);

final testDate = DateTime(2026, 10, 3);

void main() {
  test('low stock follows stock below minimum rule', () {
    expect(material.isLowStock, isTrue);
  });

  test('usage cannot exceed available stock', () {
    expect(material.canUse(4), isTrue);
    expect(material.canUse(4.01), isFalse);
    expect(material.canUse(0), isFalse);
  });
}
