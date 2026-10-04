import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/material.dart';

class MaterialModel {
  const MaterialModel(this.entity);
  final Material entity;

  factory MaterialModel.fromJson(Map<String, dynamic> json) => MaterialModel(
    Material(
      id: (json['id'] as num).toInt(),
      projectId: (json['projectId'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toDouble() ?? 0,
      minimumStock: (json['minimumStock'] as num?)?.toDouble() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      provider: json['provider']?.toString() ?? '',
      providerRuc: json['providerRuc']?.toString() ?? '',
      date: DateTime.parse(json['date'].toString()),
    ),
  );
}

extension CreateMaterialJson on CreateMaterialRequest {
  Map<String, dynamic> toJson() => {
    'projectId': projectId,
    'name': name,
    'unit': unit,
    'quantity': quantity,
    'minimumStock': minimumStock,
    'unitPrice': unitPrice,
    'provider': provider,
    'providerRuc': providerRuc,
    'date': AppDateUtils.apiDate(date),
  };
}

extension UpdateMaterialJson on UpdateMaterialRequest {
  Map<String, dynamic> toJson() => {
    'name': name,
    'unit': unit,
    'minimumStock': minimumStock,
    'unitPrice': unitPrice,
    'provider': provider,
    'providerRuc': providerRuc,
  };
}
