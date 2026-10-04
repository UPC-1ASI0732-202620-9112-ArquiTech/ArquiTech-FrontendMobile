import '../../domain/entities/material.dart';
import '../../domain/entities/material_movement.dart';
import '../../domain/repositories/material_repository.dart';
import '../datasources/material_remote_datasource.dart';

class MaterialRepositoryImpl implements MaterialRepository {
  MaterialRepositoryImpl(this._remote);
  final MaterialRemoteDataSource _remote;

  @override
  Future<Material> createMaterial(CreateMaterialRequest request) =>
      _remote.createMaterial(request);
  @override
  Future<void> deleteMaterial(int id) => _remote.deleteMaterial(id);
  @override
  Future<List<MaterialMovement>> getHistory(int projectId) =>
      _remote.getHistory(projectId);
  @override
  Future<List<Material>> getMaterials(int projectId) =>
      _remote.getMaterials(projectId);
  @override
  Future<MaterialMovement> registerEntry(
    int id,
    MaterialEntryRequest request,
  ) => _remote.registerEntry(id, request);
  @override
  Future<MaterialMovement> registerUsage(
    int id,
    MaterialUsageRequest request,
  ) => _remote.registerUsage(id, request);
  @override
  Future<Material> updateMaterial(int id, UpdateMaterialRequest request) =>
      _remote.updateMaterial(id, request);
}
