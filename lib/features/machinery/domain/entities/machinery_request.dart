import 'machinery.dart';

class MachineryRequest {
  const MachineryRequest({
    this.projectId,
    required this.status,
    required this.name,
    required this.serialNumber,
    required this.registeredAt,
    required this.description,
  });
  final int? projectId;
  final MachineryStatus status;
  final String name;
  final String serialNumber;
  final DateTime registeredAt;
  final String description;
}
