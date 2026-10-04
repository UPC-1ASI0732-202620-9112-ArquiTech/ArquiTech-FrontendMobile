enum ProjectStatus {
  active('ACTIVE'),
  pending('PENDING'),
  completed('COMPLETED'),
  suspended('SUSPENDED');

  const ProjectStatus(this.apiValue);
  final String apiValue;

  static ProjectStatus fromApi(String value) => values.firstWhere(
    (status) => status.apiValue == value,
    orElse: () => ProjectStatus.pending,
  );
}

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.status,
    required this.progress,
    required this.supervisorId,
    required this.contractorId,
    required this.supervisorName,
    required this.contractorName,
    required this.createdAt,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final ProjectStatus status;
  final int progress;
  final int supervisorId;
  final int contractorId;
  final String supervisorName;
  final String contractorName;
  final DateTime createdAt;
  final String? imageUrl;
}

class CreateProjectRequest {
  const CreateProjectRequest({
    required this.name,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.progress,
    required this.supervisorId,
    required this.contractorId,
  });

  final String name;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final int progress;
  final int supervisorId;
  final int contractorId;
}
