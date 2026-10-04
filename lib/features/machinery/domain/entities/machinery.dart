enum MachineryStatus {
  operational('OPERATIONAL'),
  maintenance('MAINTENANCE'),
  outOfService('OUT_OF_SERVICE');

  const MachineryStatus(this.apiValue);
  final String apiValue;
  static MachineryStatus fromApi(String value) =>
      values.firstWhere((e) => e.apiValue == value);
}

class Machinery {
  const Machinery({
    required this.id,
    required this.projectId,
    required this.status,
    required this.name,
    required this.serialNumber,
    required this.registeredAt,
    required this.description,
  });
  final int id;
  final int projectId;
  final MachineryStatus status;
  final String name;
  final String serialNumber;
  final DateTime registeredAt;
  final String description;
  static bool validSerial(String value) =>
      RegExp(r'^[A-Za-z0-9-]{3,20}$').hasMatch(value);
}
