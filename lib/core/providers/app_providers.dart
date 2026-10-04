import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../storage/preferences_storage_service.dart';
import '../storage/secure_storage_service.dart';

final secureStorageProvider = Provider<SecureStorageService>(
  (_) => FlutterSecureStorageService(const FlutterSecureStorage()),
);

final preferencesStorageProvider = Provider<PreferencesStorageService>(
  (_) => throw StateError('Preferences storage must be initialized in main.'),
);
