import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:arquitech/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:arquitech/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:arquitech/features/profile/domain/entities/local_profile.dart';
import 'package:arquitech/features/profile/domain/entities/accessibility_preferences.dart';
import 'package:arquitech/features/profile/presentation/controllers/profile_controller.dart';
import 'package:arquitech/app/localization/locale_controller.dart';

import '../auth/session_controller_test.dart';

void main() {
  test('Profile is persisted per user and never contains JWT', () async {
    final storage = FakePreferences();
    final repo = ProfileRepositoryImpl(ProfileLocalDataSource(storage));
    await repo.save(
      1,
      const LocalProfile(
        fullName: 'Ana',
        phone: '999999999',
        company: 'Empresa',
      ),
    );
    final restored = ProfileRepositoryImpl(ProfileLocalDataSource(storage))
        .read(1, const LocalProfile(fullName: 'fallback'));
    expect(restored.fullName, 'Ana');
    expect(restored.company, 'Empresa');
    expect(restored.phone, '999999999');
    expect(
      repo.read(2, const LocalProfile(fullName: 'Other')).fullName,
      'Other',
    );
    expect(storage.values.values.join().contains('token'), false);
  });
  test('Malformed local profile safely falls back', () {
    final storage = FakePreferences()..values['arquitech.profile.1'] = 'broken';
    expect(
      ProfileRepositoryImpl(ProfileLocalDataSource(storage))
          .read(1, const LocalProfile(fullName: 'fallback'))
          .fullName,
      'fallback',
    );
  });
  test('Accessibility and locale survive recreation', () async {
    final storage = FakePreferences();
    final repo = ProfileRepositoryImpl(ProfileLocalDataSource(storage));
    final controller = AccessibilityController(repo);
    await controller.change(
      const AccessibilityPreferences(
        textScale: 1.6,
        highContrast: true,
        reduceMotion: true,
      ),
    );
    final restored = AccessibilityController(repo);
    expect(restored.state.textScale, 1.6);
    expect(restored.state.highContrast, true);
    expect(restored.state.reduceMotion, true);
    final locale = LocaleController(
      () => storage.getString('locale'),
      (v) => storage.setString('locale', v),
    );
    await locale.change(const Locale('en'));
    expect(
      LocaleController(
        () => storage.getString('locale'),
        (v) => storage.setString('locale', v),
      ).state.languageCode,
      'en',
    );
    await locale.change(const Locale('fr'));
    expect(locale.state.languageCode, 'en');
  });
}
