import '../../../auth/presentation/controllers/session_controller.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/incident_remote_datasource.dart';
import '../../data/repositories/incident_repository_impl.dart';
import '../../domain/repositories/incident_repository.dart';
import '../../domain/entities/incident.dart';
import '../../domain/entities/incident_request.dart';

final incidentRepositoryProvider = Provider<IncidentRepository>((ref) {
  ref.watch(sessionControllerProvider.select((s) => s.user?.id));
  return IncidentRepositoryImpl(
    IncidentRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

class IncidentController extends StateNotifier<AsyncValue<List<Incident>>> {
  IncidentController(this.projectId, this.repository)
    : super(const AsyncValue.loading()) {
    load();
  }
  final int projectId;
  final IncidentRepository repository;
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

  Future<void> save(IncidentRequest request, {int? id}) async {
    if (id == null) {
      await repository.create(request);
    } else {
      await repository.update(id, request);
    }
    await refresh();
  }

  Future<void> resolve(Incident incident) => save(
    IncidentRequest(
      type: incident.type,
      description: incident.description,
      severity: incident.severity,
      status: IncidentStatus.resolved,
      reportedAt: incident.reportedAt,
    ),
    id: incident.id,
  );
  Future<void> delete(int id) async {
    await repository.delete(id);
    await refresh();
  }
}

final incidentsControllerProvider = StateNotifierProvider.autoDispose
    .family<IncidentController, AsyncValue<List<Incident>>, int>(
      (ref, id) =>
          IncidentController(id, ref.watch(incidentRepositoryProvider)),
    );
