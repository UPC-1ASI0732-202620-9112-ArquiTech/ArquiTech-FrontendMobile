import '../../domain/entities/attendance_request.dart';

extension AttendanceRequestModel on AttendanceRequest {
  Map<String, dynamic> toJson() => {
    if (projectId != null) 'projectId': projectId,
    'workerId': workerId,
    'attendanceDate': attendanceDate.toIso8601String().split('T').first,
    'status': status.apiValue,
    'checkInAt': checkInAt?.toUtc().toIso8601String(),
    'checkOutAt': checkOutAt?.toUtc().toIso8601String(),
    'notes': notes.trim(),
  };
}
