import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../data/datasources/attendance_remote_datasource.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/attendance_request.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  ref.watch(sessionControllerProvider.select((s) => s.user?.id));
  return AttendanceRepositoryImpl(
    AttendanceRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

class AttendanceController extends StateNotifier<AsyncValue<List<Attendance>>> {
  AttendanceController(this.projectId, this.repository)
    : super(const AsyncValue.loading()) {
    load();
  }
  final int projectId;
  final AttendanceRepository repository;
  Future<void> load() async {
    state = const AsyncValue.loading();
    await refresh();
  }

  Future<void> refresh() async {
    final result = await AsyncValue.guard(() => repository.list(projectId));
    if (mounted) state = result;
  }

  Future<void> save(AttendanceRequest request, {int? id}) async {
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

final attendanceControllerProvider = StateNotifierProvider.autoDispose
    .family<AttendanceController, AsyncValue<List<Attendance>>, int>(
      (ref, id) =>
          AttendanceController(id, ref.watch(attendanceRepositoryProvider)),
    );
