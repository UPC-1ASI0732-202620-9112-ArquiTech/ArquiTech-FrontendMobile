import '../../domain/entities/local_profile.dart';
import '../../domain/entities/accessibility_preferences.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/local_profile_model.dart';
import '../models/accessibility_preferences_model.dart';
import '../datasources/profile_local_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this.source);
  final ProfileLocalDataSource source;
  String key(int id) => 'arquitech.profile.$id';
  @override
  LocalProfile read(int userId, LocalProfile fallback) {
    final j = source.read(key(userId));
    try {
      return j == null ? fallback : LocalProfileModel.fromJson(j);
    } catch (_) {
      return fallback;
    }
  }

  @override
  Future<void> save(int userId, LocalProfile profile) =>
      source.save(key(userId), LocalProfileModel.toJson(profile));
  @override
  AccessibilityPreferences readPreferences() {
    try {
      return AccessibilityPreferencesModel.fromJson(
        source.read('arquitech.accessibility') ?? {},
      );
    } catch (_) {
      return const AccessibilityPreferences();
    }
  }

  @override
  Future<void> savePreferences(AccessibilityPreferences p) => source.save(
    'arquitech.accessibility',
    AccessibilityPreferencesModel.toJson(p),
  );
}
