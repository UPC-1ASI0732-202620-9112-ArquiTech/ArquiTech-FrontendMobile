import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/models/project_model.dart';
import '../../domain/entities/project.dart';

class ProjectContextController extends StateNotifier<Project?> {
  ProjectContextController(String? Function() read, this._write, this._remove)
    : super(_restore(read()));

  static const _key = 'arquitech.current-project';
  final Future<void> Function(String) _write;
  final Future<void> Function() _remove;

  static Project? _restore(String? raw) {
    if (raw == null) return null;
    try {
      return ProjectModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      ).entity;
    } on Object {
      return null;
    }
  }

  Future<void> select(Project project) async {
    state = project;
    await _write(jsonEncode(_toJson(project)));
  }

  Future<void> clear() async {
    state = null;
    await _remove();
  }

  static Map<String, dynamic> _toJson(Project project) => {
    'id': project.id,
    'name': project.name,
    'location': project.location,
    'startDate': project.startDate.toIso8601String(),
    'endDate': project.endDate.toIso8601String(),
    'budget': project.budget,
    'status': project.status.apiValue,
    'progress': project.progress,
    'supervisorId': project.supervisorId,
    'contractorId': project.contractorId,
    'supervisorName': project.supervisorName,
    'contractorName': project.contractorName,
    'createdAt': project.createdAt.toIso8601String(),
    'imageUrl': project.imageUrl,
  };
}

final projectContextProvider =
    StateNotifierProvider<ProjectContextController, Project?>((ref) {
      final storage = ref.watch(preferencesStorageProvider);
      return ProjectContextController(
        () => storage.getString(ProjectContextController._key),
        (value) => storage.setString(ProjectContextController._key, value),
        () => storage.remove(ProjectContextController._key),
      );
    });
