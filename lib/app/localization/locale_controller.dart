import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';

class LocaleController extends StateNotifier<Locale> {
  LocaleController(String? Function() readLocale, this._writeLocale)
    : super(Locale(readLocale() ?? 'es'));

  final Future<void> Function(String) _writeLocale;

  Future<void> change(Locale locale) async {
    if (!const {'es', 'en'}.contains(locale.languageCode)) return;
    state = Locale(locale.languageCode);
    await _writeLocale(locale.languageCode);
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
      final storage = ref.watch(preferencesStorageProvider);
      return LocaleController(
        () => storage.getString('arquitech.locale'),
        (value) => storage.setString('arquitech.locale', value),
      );
    });
