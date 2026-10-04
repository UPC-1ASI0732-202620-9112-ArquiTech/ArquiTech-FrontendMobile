import '../../domain/entities/attendance.dart';

abstract final class AttendanceModel {
  static Attendance fromJson(Map<String, dynamic> json) => Attendance(
    id: (json['id'] as num).toInt(),
    projectId: (json['projectId'] as num).toInt(),
    workerId: (json['workerId'] as num).toInt(),
    workerName: json['workerName'] as String,
    attendanceDate: DateTime.parse(json['attendanceDate'] as String),
    status: AttendanceStatus.fromApi(json['status'] as String),
    registeredByUserId: (json['registeredByUserId'] as num).toInt(),
    notes: json['notes'] as String? ?? '',
    checkInAt: _date(json['checkInAt']),
    checkOutAt: _date(json['checkOutAt']),
    createdAt: _date(json['createdAt']),
    updatedAt: _date(json['updatedAt']),
  );
  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.parse(value as String);
}
