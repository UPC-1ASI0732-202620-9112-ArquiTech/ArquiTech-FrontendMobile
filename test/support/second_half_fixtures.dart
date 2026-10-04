import 'package:arquitech/features/workers/data/models/worker_model.dart';
import 'package:arquitech/features/tasks/data/models/task_model.dart';
import 'package:arquitech/features/incidents/data/models/incident_model.dart';
import 'package:arquitech/features/machinery/data/models/machinery_model.dart';
import 'package:arquitech/features/materials/data/models/material_model.dart';
import 'package:arquitech/features/materials/data/models/material_movement_model.dart';
import 'package:arquitech/features/projects/domain/entities/project.dart';

Map<String, dynamic> workerJson({
  String status = 'ACTIVE',
  int id = 3,
  int projectId = 9,
}) => {
  'id': id,
  'projectId': projectId,
  'fullName': 'Ana Torres',
  'role': 'Capataz',
  'specialty': null,
  'hireDate': '2026-09-01',
  'status': status,
};
Map<String, dynamic> taskJson({
  String status = 'PENDING',
  String dueDate = '2026-09-30',
  String? completedAt,
  int id = 4,
}) => {
  'id': id,
  'projectId': 9,
  'workerId': 3,
  'workerName': 'Ana Torres',
  'title': 'Revisar cimentación',
  'description': null,
  'status': status,
  'dueDate': dueDate,
  'createdAt': '2026-09-20T18:00:00Z',
  'completedAt': completedAt,
};
Map<String, dynamic> incidentJson({
  String severity = 'HIGH',
  String status = 'OPEN',
  String reportedAt = '2026-09-30T18:00:00Z',
  String? resolvedAt,
}) => {
  'id': 5,
  'projectId': 9,
  'reportedByUserId': 1,
  'type': 'UNSAFE_CONDITION',
  'description': 'Protección incompleta',
  'severity': severity,
  'status': status,
  'reportedAt': reportedAt,
  'resolvedAt': resolvedAt,
};
Map<String, dynamic> machineryJson({String status = 'OPERATIONAL'}) => {
  'id': 6,
  'projectId': 9,
  'name': 'Excavadora',
  'serialNumber': 'ABC-123',
  'status': status,
  'registeredAt': '2026-09-01',
  'description': null,
};
Map<String, dynamic> materialJson({double stock = 2, double minimum = 5}) => {
  'id': 7,
  'projectId': 9,
  'name': 'Cemento',
  'unit': 'bolsas',
  'quantity': 10,
  'stock': stock,
  'minimumStock': minimum,
  'unitPrice': 30,
  'provider': 'Proveedor',
  'providerRuc': '20123456789',
  'date': '2026-09-01',
};
Map<String, dynamic> movementJson({
  String type = 'ENTRY',
  String occurredAt = '2026-09-30T18:00:00Z',
}) => {
  'id': 8,
  'materialId': 7,
  'projectId': 9,
  'materialName': 'Cemento',
  'unit': 'bolsas',
  'type': type,
  'quantity': 2,
  'registeredByUserId': 1,
  'occurredAt': occurredAt,
  'supplier': null,
  'note': null,
};
final sampleWorker = WorkerModel.fromJson(workerJson());
final sampleTask = TaskModel.fromJson(taskJson());
final sampleIncident = IncidentModel.fromJson(incidentJson());
final sampleMachinery = MachineryModel.fromJson(machineryJson());
final sampleMaterial = MaterialModel.fromJson(materialJson()).entity;
final sampleMovement = MaterialMovementModel.fromJson(movementJson()).entity;
final sampleProject = Project(
  id: 9,
  name: 'Obra Lima',
  location: 'Lima',
  startDate: DateTime(2026, 9),
  endDate: DateTime(2027),
  budget: 1000,
  status: ProjectStatus.active,
  progress: 42,
  supervisorId: 1,
  contractorId: 2,
  supervisorName: 'Supervisor',
  contractorName: 'Contractor',
  createdAt: DateTime(2026, 9),
);
