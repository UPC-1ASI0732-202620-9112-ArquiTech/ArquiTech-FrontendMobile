import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/attendance_request.dart';
import '../models/attendance_model.dart';
import '../models/attendance_request_model.dart';

class AttendanceRemoteDataSource {
  AttendanceRemoteDataSource(this.client);
  final ApiClient client;
  Future<List<Attendance>> list(int projectId, {DateTime? date}) async =>
      ((await client.get(ApiEndpoints.attendanceList(projectId, date: date)))
              as List)
          .map(
            (e) =>
                AttendanceModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
  Future<Attendance> create(AttendanceRequest request) async =>
      AttendanceModel.fromJson(
        Map<String, dynamic>.from(
          await client.post(ApiEndpoints.attendance, data: request.toJson())
              as Map,
        ),
      );
  Future<Attendance> update(int id, AttendanceRequest request) async =>
      AttendanceModel.fromJson(
        Map<String, dynamic>.from(
          await client.put(
            ApiEndpoints.attendanceRecord(id),
            data: request.toJson(),
          ) as Map,
        ),
      );
  Future<void> delete(int id) =>
      client.delete(ApiEndpoints.attendanceRecord(id));
}
