import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/material_movement.dart';

class MaterialMovementModel {
  const MaterialMovementModel(this.entity);
  final MaterialMovement entity;

  factory MaterialMovementModel.fromJson(Map<String, dynamic> json) =>
      MaterialMovementModel(
        MaterialMovement(
          id: (json['id'] as num).toInt(),
          materialId: (json['materialId'] as num).toInt(),
          projectId: (json['projectId'] as num).toInt(),
          materialName: json['materialName']?.toString() ?? '',
          unit: json['unit']?.toString() ?? '',
          type: MovementType.fromApi(json['type']?.toString() ?? ''),
          quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
          supplier: json['supplier']?.toString(),
          registeredByUserId: (json['registeredByUserId'] as num).toInt(),
          registeredByName: json['registeredByName']?.toString(),
          occurredAt: DateTime.parse(json['occurredAt'].toString()),
          note: json['note']?.toString(),
        ),
      );
}

extension MaterialEntryJson on MaterialEntryRequest {
  Map<String, dynamic> toJson() => {
    'quantity': quantity,
    'supplier': supplier,
    'occurredAt': AppDateUtils.utcIso(occurredAt),
    'note': note,
  };
}

extension MaterialUsageJson on MaterialUsageRequest {
  Map<String, dynamic> toJson() => {
    'quantity': quantity,
    'occurredAt': AppDateUtils.utcIso(occurredAt),
    'note': note,
  };
}
