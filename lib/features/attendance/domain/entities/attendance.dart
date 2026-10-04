enum AttendanceStatus {
  present('PRESENT'),
  absent('ABSENT'),
  late('LATE'),
  excused('EXCUSED');

  const AttendanceStatus(this.apiValue);
  final String apiValue;
  static AttendanceStatus fromApi(String value) =>
      values.firstWhere((s) => s.apiValue == value);
  bool get allowsTimes => this == present || this == late;
}

class Attendance {
  const Attendance({
    required this.id,
    required this.projectId,
    required this.workerId,
    required this.workerName,
    required this.attendanceDate,
    required this.status,
    required this.registeredByUserId,
    this.checkInAt,
    this.checkOutAt,
    this.notes = '',
    this.createdAt,
    this.updatedAt,
  });
  final int id, projectId, workerId, registeredByUserId;
  final String workerName, notes;
  final DateTime attendanceDate;
  final AttendanceStatus status;
  final DateTime? checkInAt, checkOutAt, createdAt, updatedAt;
}
