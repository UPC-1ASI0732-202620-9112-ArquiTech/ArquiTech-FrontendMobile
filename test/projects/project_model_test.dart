import 'package:arquitech/features/projects/data/models/project_model.dart';
import 'package:arquitech/features/projects/domain/entities/project.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses canonical project resource', () {
    final project = ProjectModel.fromJson({
      'id': 3,
      'name': 'Edificio A',
      'location': 'Lima',
      'startDate': '2026-10-01',
      'endDate': '2027-05-01',
      'budget': 120000.50,
      'status': 'ACTIVE',
      'progress': 35,
      'supervisorId': 1,
      'contractorId': 2,
      'supervisorName': 'Ana',
      'contractorName': 'Luis',
      'createdAt': '2026-10-01T10:00:00Z',
      'imageUrl': null,
    }).entity;

    expect(project.status, ProjectStatus.active);
    expect(project.budget, 120000.50);
    expect(project.contractorName, 'Luis');
  });
}
