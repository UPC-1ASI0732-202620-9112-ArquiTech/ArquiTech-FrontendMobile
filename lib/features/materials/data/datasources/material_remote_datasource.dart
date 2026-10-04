import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/material.dart';
import '../../domain/entities/material_movement.dart';
import '../models/material_model.dart';
import '../models/material_movement_model.dart';

class MaterialRemoteDataSource {
  MaterialRemoteDataSource(this._client);
  final ApiClient _client;

  Future<List<Material>> getMaterials(int projectId) async {
    final data = await _client.get(
      ApiEndpoints.projectMaterials(projectId),
    ) as List<dynamic>;
    return data.map(_materialFrom).toList();
  }

  Future<Material> createMaterial(CreateMaterialRequest request) async {
    final data = await _client.post(
      ApiEndpoints.materials,
      data: request.toJson(),
    );
    return _materialFrom(data);
  }

  Future<Material> updateMaterial(int id, UpdateMaterialRequest request) async {
    final data = await _client.put(
      ApiEndpoints.material(id),
      data: request.toJson(),
    );
    return _materialFrom(data);
  }

  Future<void> deleteMaterial(int id) =>
      _client.delete(ApiEndpoints.material(id));

  Future<MaterialMovement> registerEntry(
    int id,
    MaterialEntryRequest request,
  ) async {
    final data = await _client.post(
      ApiEndpoints.materialEntry(id),
      data: request.toJson(),
    );
    return _movementFrom(data);
  }

  Future<MaterialMovement> registerUsage(
    int id,
    MaterialUsageRequest request,
  ) async {
    final data = await _client.post(
      ApiEndpoints.materialUsage(id),
      data: request.toJson(),
    );
    return _movementFrom(data);
  }

  Future<List<MaterialMovement>> getHistory(int projectId) async {
    final data = await _client.get(
      ApiEndpoints.materialHistory(projectId),
    ) as List<dynamic>;
    return data.map(_movementFrom).toList();
  }

  Material _materialFrom(dynamic data) =>
      MaterialModel.fromJson(Map<String, dynamic>.from(data as Map)).entity;

  MaterialMovement _movementFrom(dynamic data) =>
      MaterialMovementModel.fromJson(Map<String, dynamic>.from(data as Map))
          .entity;
}
