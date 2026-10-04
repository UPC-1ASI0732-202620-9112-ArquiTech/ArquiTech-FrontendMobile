import '../entities/material.dart';
import '../entities/material_movement.dart';

abstract class MaterialRepository {
  Future<List<Material>> getMaterials(int projectId);
  Future<Material> createMaterial(CreateMaterialRequest request);
  Future<Material> updateMaterial(int id, UpdateMaterialRequest request);
  Future<void> deleteMaterial(int id);
  Future<MaterialMovement> registerEntry(int id, MaterialEntryRequest request);
  Future<MaterialMovement> registerUsage(int id, MaterialUsageRequest request);
  Future<List<MaterialMovement>> getHistory(int projectId);
}
