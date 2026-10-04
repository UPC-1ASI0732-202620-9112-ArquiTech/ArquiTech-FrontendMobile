import '../../domain/entities/accessibility_preferences.dart';

abstract final class AccessibilityPreferencesModel {
  static AccessibilityPreferences fromJson(Map<String, dynamic> j) =>
      AccessibilityPreferences(
        textScale:
            const [1.0, 1.3, 1.6].contains((j['textScale'] as num?)?.toDouble())
            ? (j['textScale'] as num).toDouble()
            : 1,
        highContrast: j['highContrast'] == true,
        reduceMotion: j['reduceMotion'] == true,
      );
  static Map<String, dynamic> toJson(AccessibilityPreferences p) => {
    'textScale': p.textScale,
    'highContrast': p.highContrast,
    'reduceMotion': p.reduceMotion,
  };
}
