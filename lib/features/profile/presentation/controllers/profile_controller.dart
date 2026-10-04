import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../domain/entities/local_profile.dart';
import '../../domain/entities/accessibility_preferences.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/datasources/profile_local_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(
    ProfileLocalDataSource(ref.watch(preferencesStorageProvider)),
  ),
);
final localProfileProvider = Provider<LocalProfile>((ref) {
  final user = ref.watch(sessionControllerProvider).user;
  if (user == null) return const LocalProfile(fullName: '');
  return ref
      .watch(profileRepositoryProvider)
      .read(
        user.id,
        LocalProfile(fullName: user.fullName, phone: user.phone ?? ''),
      );
});

class AccessibilityController extends StateNotifier<AccessibilityPreferences> {
  AccessibilityController(this.repository)
    : super(repository.readPreferences());
  final ProfileRepository repository;
  Future<void> change(AccessibilityPreferences p) async {
    await repository.savePreferences(p);
    state = p;
  }
}

final accessibilityProvider =
    StateNotifierProvider<AccessibilityController, AccessibilityPreferences>(
      (ref) => AccessibilityController(ref.watch(profileRepositoryProvider)),
    );
