import 'attendance.dart';

class AttendanceRequest {
  const AttendanceRequest({
    this.projectId,
    required this.workerId,
    required this.attendanceDate,
    required this.status,
    this.checkInAt,
    this.checkOutAt,
    this.notes = '',
  });
  final int? projectId;
  final int workerId;
  final DateTime attendanceDate;
  final AttendanceStatus status;
  final DateTime? checkInAt, checkOutAt;
  final String notes;
  bool get hasValidTimes =>
      (!status.allowsTimes && (checkInAt != null || checkOutAt != null))
      ? false
      : checkOutAt == null ||
            (checkInAt != null && !checkOutAt!.isBefore(checkInAt!));
}
