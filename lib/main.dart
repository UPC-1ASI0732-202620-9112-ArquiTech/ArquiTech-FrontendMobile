import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/providers/app_providers.dart';
import 'core/storage/preferences_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        preferencesStorageProvider.overrideWithValue(
          SharedPreferencesStorageService(preferences),
        ),
      ],
      child: const ArquiTechApp(),
    ),
  );
}
