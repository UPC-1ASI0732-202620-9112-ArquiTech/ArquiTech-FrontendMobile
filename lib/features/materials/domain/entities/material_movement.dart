enum MovementType {
  entry('ENTRY'),
  usage('USAGE');

  const MovementType(this.apiValue);
  final String apiValue;

  static MovementType fromApi(String value) =>
      value == 'USAGE' ? MovementType.usage : MovementType.entry;
}

class MaterialMovement {
  const MaterialMovement({
    required this.id,
    required this.materialId,
    required this.projectId,
    required this.materialName,
    required this.unit,
    required this.type,
    required this.quantity,
    required this.registeredByUserId,
    required this.occurredAt,
    this.supplier,
    this.registeredByName,
    this.note,
  });

  final int id;
  final int materialId;
  final int projectId;
  final String materialName;
  final String unit;
  final MovementType type;
  final double quantity;
  final String? supplier;
  final int registeredByUserId;
  final String? registeredByName;
  final DateTime occurredAt;
  final String? note;
}

class MaterialEntryRequest {
  const MaterialEntryRequest({
    required this.quantity,
    required this.supplier,
    required this.occurredAt,
    required this.note,
  });
  final double quantity;
  final String supplier;
  final DateTime occurredAt;
  final String note;
}

class MaterialUsageRequest {
  const MaterialUsageRequest({
    required this.quantity,
    required this.occurredAt,
    required this.note,
  });
  final double quantity;
  final DateTime occurredAt;
  final String note;
}
