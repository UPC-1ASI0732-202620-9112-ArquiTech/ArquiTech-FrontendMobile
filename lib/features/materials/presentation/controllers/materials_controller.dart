import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/material_remote_datasource.dart';
import '../../data/repositories/material_repository_impl.dart';
import '../../domain/entities/material.dart';
import '../../domain/entities/material_movement.dart';
import '../../domain/repositories/material_repository.dart';

final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  return MaterialRepositoryImpl(
    MaterialRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

class MaterialsController extends StateNotifier<AsyncValue<List<Material>>> {
  MaterialsController(this._projectId, this._repository)
    : super(const AsyncValue.loading()) {
    load();
  }

  final int _projectId;
  final MaterialRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getMaterials(_projectId));
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _repository.getMaterials(_projectId));
  }

  Future<Material> create(CreateMaterialRequest request) async {
    final result = await _repository.createMaterial(request);
    await refresh();
    return result;
  }

  Future<Material> update(int id, UpdateMaterialRequest request) async {
    final result = await _repository.updateMaterial(id, request);
    await refresh();
    return result;
  }

  Future<void> delete(int id) async {
    await _repository.deleteMaterial(id);
    await refresh();
  }

  Future<MaterialMovement> entry(int id, MaterialEntryRequest request) async {
    final result = await _repository.registerEntry(id, request);
    await refresh();
    return result;
  }

  Future<MaterialMovement> usage(int id, MaterialUsageRequest request) async {
    final result = await _repository.registerUsage(id, request);
    await refresh();
    return result;
  }
}

final materialsControllerProvider =
    StateNotifierProvider.family<
      MaterialsController,
      AsyncValue<List<Material>>,
      int
    >((ref, projectId) {
      return MaterialsController(
        projectId,
        ref.watch(materialRepositoryProvider),
      );
    });

class MovementsController
    extends StateNotifier<AsyncValue<List<MaterialMovement>>> {
  MovementsController(this._projectId, this._repository)
    : super(const AsyncValue.loading()) {
    load();
  }
  final int _projectId;
  final MaterialRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getHistory(_projectId));
  }
}

final movementsControllerProvider =
    StateNotifierProvider.family<
      MovementsController,
      AsyncValue<List<MaterialMovement>>,
      int
    >((ref, projectId) {
      return MovementsController(
        projectId,
        ref.watch(materialRepositoryProvider),
      );
    });
