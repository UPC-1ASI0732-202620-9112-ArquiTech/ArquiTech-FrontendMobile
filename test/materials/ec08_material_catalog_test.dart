import 'package:arquitech/features/materials/data/ec08_material_catalog.dart';
import 'package:arquitech/features/materials/domain/entities/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Material sampleMaterial({
  int id = 4,
  int projectId = 11,
  String name = 'Cemento Portland',
  String unit = 'kg',
}) => Material(
  id: id,
  projectId: projectId,
  name: name,
  unit: unit,
  quantity: 500,
  stock: 450,
  minimumStock: 50,
  unitPrice: 25.6,
  provider: 'Constructora Lima',
  providerRuc: '20123456789',
  date: DateTime.utc(2026, 11, 9),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('caches names and units for later offline selection', () async {
    final prefs = await SharedPreferences.getInstance();
    final cache = Ec08MaterialCatalog(prefs);
    await cache.save(9, 11, [
      sampleMaterial(id: 8, name: 'Fierro', unit: 'varilla'),
      sampleMaterial(),
    ]);

    final offline = Ec08MaterialCatalog(prefs).load(9, 11);
    expect(offline.map((row) => row.name), [
      'Cemento Portland',
      'Fierro',
    ]);
    expect(offline.first.unit, 'kg');
    expect(offline.first.id, 4);
    expect(offline.first.toJson().containsKey('stock'), false);
  });

  test('isolates the cached catalog by user and project', () async {
    final cache = Ec08MaterialCatalog(await SharedPreferences.getInstance());
    await cache.save(9, 11, [sampleMaterial()]);
    expect(cache.load(9, 11), hasLength(1));
    expect(cache.load(10, 11), isEmpty);
    expect(cache.load(9, 12), isEmpty);
  });

  test('updated online materials replace stale names without losing ids', () async {
    final cache = Ec08MaterialCatalog(await SharedPreferences.getInstance());
    await cache.save(9, 11, [sampleMaterial()]);
    await cache.save(9, 11, [
      sampleMaterial(name: 'Cemento Portland Tipo I', unit: 'saco'),
    ]);
    expect(cache.load(9, 11).single.name, 'Cemento Portland Tipo I');
    expect(cache.load(9, 11).single.unit, 'saco');
    expect(cache.load(9, 11).single.id, 4);
  });

  test('rejects materials from another project', () async {
    final cache = Ec08MaterialCatalog(await SharedPreferences.getInstance());
    await expectLater(
      cache.save(9, 11, [sampleMaterial(projectId: 12)]),
      throwsArgumentError,
    );
    expect(cache.load(9, 11), isEmpty);
  });

  test('preserves corrupted catalog for diagnosis rather than replacing it',
      () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Ec08MaterialCatalog.key(9, 11), 'invalid-json');
    final cache = Ec08MaterialCatalog(prefs);
    expect(() => cache.load(9, 11), throwsFormatException);
    await expectLater(cache.save(9, 11, [sampleMaterial()]),
        throwsFormatException);
    expect(prefs.getString(Ec08MaterialCatalog.key(9, 11)), 'invalid-json');
  });
}
