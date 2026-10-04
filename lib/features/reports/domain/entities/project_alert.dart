import '../../../materials/domain/entities/material.dart';
import '../../../incidents/domain/entities/incident.dart';

class ProjectAlert {
  const ProjectAlert({
    required this.name,
    required this.module,
    required this.critical,
  });
  final String name, module;
  final bool critical;
  static List<ProjectAlert> aggregate(
    List<Material> materials,
    List<Incident> incidents,
  ) => [
    for (final i in incidents)
      if (i.isCritical)
        ProjectAlert(name: i.description, module: 'incidents', critical: true),
    for (final m in materials)
      if (m.isLowStock)
        ProjectAlert(name: m.name, module: 'materials', critical: false),
  ];
}
