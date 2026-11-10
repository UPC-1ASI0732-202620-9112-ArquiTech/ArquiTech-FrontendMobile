import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/material.dart';

/// Minimal material metadata cached per user and project for offline selection.
/// Stock is deliberately not cached as authoritative: it may change remotely.
class Ec08CatalogMaterial {
  const Ec08CatalogMaterial({
    required this.id,
    required this.name,
    required this.unit,
  });

  final int id;
  final String name;
  final String unit;

  factory Ec08CatalogMaterial.fromMaterial(Material material) =>
      Ec08CatalogMaterial(
        id: material.id,
        name: material.name,
        unit: material.unit,
      );

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'unit': unit,
  };

  factory Ec08CatalogMaterial.fromJson(Map<String, dynamic> json) =>
      Ec08CatalogMaterial(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        unit: json['unit'] as String,
      );
}

class Ec08MaterialCatalog {
  const Ec08MaterialCatalog(this.prefs);

  final SharedPreferences prefs;

  static String key(int userId, int projectId) =>
      'arquitech.ec08.catalog.$userId.$projectId';

  List<Ec08CatalogMaterial> load(int userId, int projectId) {
    final saved = prefs.getString(key(userId, projectId));
    if (saved == null) return const [];
    try {
      final rows = jsonDecode(saved) as List<dynamic>;
      final catalog = rows
          .map((item) => Ec08CatalogMaterial.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
      if (catalog.any((item) => item.id <= 0 || item.name.trim().isEmpty)) {
        throw const FormatException('Invalid material catalog');
      }
      return catalog;
    } catch (_) {
      // Never hide a corrupted cache by silently replacing it with an empty list.
      throw const FormatException('The offline material catalog is invalid');
    }
  }

  Future<void> save(
    int userId,
    int projectId,
    List<Material> materials,
  ) async {
    // Validate existing data before writing, to avoid silently masking damage.
    load(userId, projectId);
    if (materials.any((m) => m.projectId != projectId || m.id <= 0)) {
      throw ArgumentError('Materials must belong to the selected project');
    }
    final rows = materials
        .map(Ec08CatalogMaterial.fromMaterial)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    if (rows.map((item) => item.id).toSet().length != rows.length) {
      throw ArgumentError('Duplicated material id');
    }
    final ok = await prefs.setString(
      key(userId, projectId),
      jsonEncode(rows.map((item) => item.toJson()).toList()),
    );
    if (!ok) throw StateError('Unable to save offline material catalog');
  }
}
