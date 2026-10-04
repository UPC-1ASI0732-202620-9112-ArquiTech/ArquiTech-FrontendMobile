import '../entities/attendance.dart';
import '../entities/attendance_request.dart';

abstract class AttendanceRepository {
  Future<List<Attendance>> list(int projectId, {DateTime? date});
  Future<Attendance> create(AttendanceRequest request);
  Future<Attendance> update(int id, AttendanceRequest request);
  Future<void> delete(int id);
}
