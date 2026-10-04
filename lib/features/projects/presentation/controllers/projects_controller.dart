import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../auth/domain/entities/user.dart';
import '../../data/datasources/project_remote_datasource.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(
    ProjectRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

class ProjectsController extends StateNotifier<AsyncValue<List<Project>>> {
  ProjectsController(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final ProjectRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.getProjects);
  }

  Future<void> refresh() async {
    final result = await AsyncValue.guard(_repository.getProjects);
    state = result;
  }

  Future<Project> create(CreateProjectRequest request) async {
    final project = await _repository.createProject(request);
    state = AsyncValue.data([...state.valueOrNull ?? [], project]);
    return project;
  }
}

final projectsControllerProvider =
    StateNotifierProvider<ProjectsController, AsyncValue<List<Project>>>((ref) {
      return ProjectsController(ref.watch(projectRepositoryProvider));
    });

final contractorsProvider = FutureProvider<List<User>>((ref) {
  return ref.watch(projectRepositoryProvider).getContractors();
});
