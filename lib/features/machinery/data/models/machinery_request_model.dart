import '../../domain/entities/machinery_request.dart';

extension MachineryRequestModel on MachineryRequest {
  Map<String, dynamic> toJson() => {
    if (projectId != null) 'projectId': projectId,
    'status': status.apiValue,
    'name': name,
    'serialNumber': serialNumber.toUpperCase(),
    'registeredAt': registeredAt.toIso8601String().split('T').first,
    'description': description,
  };
}
