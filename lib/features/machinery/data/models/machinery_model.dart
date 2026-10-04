import '../../domain/entities/machinery.dart';

class MachineryModel {
  static Machinery fromJson(Map<String, dynamic> json) => Machinery(
    id: (json['id'] as num).toInt(),
    projectId: (json['projectId'] as num).toInt(),
    status: MachineryStatus.fromApi(json['status'] as String),
    name: json['name']?.toString() ?? '',
    serialNumber: json['serialNumber']?.toString() ?? '',
    registeredAt: DateTime.parse(json['registeredAt'] as String),
    description: json['description']?.toString() ?? '',
  );
}
