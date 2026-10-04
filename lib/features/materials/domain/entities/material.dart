class Material {
  const Material({
    required this.id,
    required this.projectId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.stock,
    required this.minimumStock,
    required this.unitPrice,
    required this.provider,
    required this.providerRuc,
    required this.date,
  });

  final int id;
  final int projectId;
  final String name;
  final String unit;
  final double quantity;
  final double stock;
  final double minimumStock;
  final double unitPrice;
  final String provider;
  final String providerRuc;
  final DateTime? date;

  bool get isLowStock => stock < minimumStock;
  bool canUse(double amount) => amount > 0 && amount <= stock;
}

class CreateMaterialRequest {
  const CreateMaterialRequest({
    required this.projectId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.minimumStock,
    required this.unitPrice,
    required this.provider,
    required this.providerRuc,
    required this.date,
  });
  final int projectId;
  final String name;
  final String unit;
  final double quantity;
  final double minimumStock;
  final double unitPrice;
  final String provider;
  final String providerRuc;
  final DateTime date;
}

class UpdateMaterialRequest {
  const UpdateMaterialRequest({
    required this.name,
    required this.unit,
    required this.minimumStock,
    required this.unitPrice,
    required this.provider,
    required this.providerRuc,
  });
  final String name;
  final String unit;
  final double minimumStock;
  final double unitPrice;
  final String provider;
  final String providerRuc;
}
