import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/project.dart';

class ProjectModel {
  const ProjectModel(this.entity);
  final Project entity;

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
    Project(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      startDate: DateTime.parse(json['startDate'].toString()),
      endDate: DateTime.parse(json['endDate'].toString()),
      budget: (json['budget'] as num?)?.toDouble() ?? 0,
      status: ProjectStatus.fromApi(json['status']?.toString() ?? ''),
      progress: ((json['progress'] as num?)?.toInt() ?? 0).clamp(0, 100),
      supervisorId: (json['supervisorId'] as num).toInt(),
      contractorId: (json['contractorId'] as num).toInt(),
      supervisorName: json['supervisorName']?.toString() ?? '',
      contractorName: json['contractorName']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt'].toString()),
      imageUrl: json['imageUrl']?.toString(),
    ),
  );
}

extension CreateProjectRequestJson on CreateProjectRequest {
  Map<String, dynamic> toJson() => {
    'name': name,
    'location': location,
    'startDate': AppDateUtils.apiDate(startDate),
    'endDate': AppDateUtils.apiDate(endDate),
    'budget': budget,
    'status': ProjectStatus.pending.apiValue,
    'progress': progress,
    'supervisorId': supervisorId,
    'contractorId': contractorId,
  };
}
