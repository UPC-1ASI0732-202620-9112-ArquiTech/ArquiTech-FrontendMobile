import '../entities/local_profile.dart';
import '../entities/accessibility_preferences.dart';

abstract class ProfileRepository {
  LocalProfile read(int userId, LocalProfile fallback);
  Future<void> save(int userId, LocalProfile profile);
  AccessibilityPreferences readPreferences();
  Future<void> savePreferences(AccessibilityPreferences preferences);
}
