import '../../../auth/presentation/controllers/session_controller.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/machinery_remote_datasource.dart';
import '../../data/repositories/machinery_repository_impl.dart';
import '../../domain/repositories/machinery_repository.dart';
import '../../domain/entities/machinery.dart';
import '../../domain/entities/machinery_request.dart';

final machineryRepositoryProvider = Provider<MachineryRepository>((ref) {
  ref.watch(sessionControllerProvider.select((s) => s.user?.id));
  return MachineryRepositoryImpl(
    MachineryRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

class MachineryController extends StateNotifier<AsyncValue<List<Machinery>>> {
  MachineryController(this.projectId, this.repository)
    : super(const AsyncValue.loading()) {
    load();
  }
  final int projectId;
  final MachineryRepository repository;
  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => repository.list(projectId));
    if (mounted) {
      state = result;
    }
  }

  Future<void> refresh() async {
    final result = await AsyncValue.guard(() => repository.list(projectId));
    if (mounted) {
      state = result;
    }
  }

  Future<void> save(MachineryRequest request, {int? id}) async {
    if (id == null) {
      await repository.create(request);
    } else {
      await repository.update(id, request);
    }
    await refresh();
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    await refresh();
  }
}

final machineryControllerProvider = StateNotifierProvider.autoDispose
    .family<MachineryController, AsyncValue<List<Machinery>>, int>(
      (ref, id) =>
          MachineryController(id, ref.watch(machineryRepositoryProvider)),
    );
