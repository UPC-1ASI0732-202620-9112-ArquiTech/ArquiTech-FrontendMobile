import '../../domain/entities/attendance.dart';
import '../../domain/entities/attendance_request.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this.remote);
  final AttendanceRemoteDataSource remote;
  @override
  Future<List<Attendance>> list(int projectId, {DateTime? date}) =>
      remote.list(projectId, date: date);
  @override
  Future<Attendance> create(AttendanceRequest request) =>
      remote.create(request);
  @override
  Future<Attendance> update(int id, AttendanceRequest request) =>
      remote.update(id, request);
  @override
  Future<void> delete(int id) => remote.delete(id);
}
