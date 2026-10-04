import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'localization/app_localizations.dart';
import 'localization/locale_controller.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../features/profile/presentation/controllers/profile_controller.dart';

class ArquiTechApp extends ConsumerWidget {
  const ArquiTechApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final accessibility = ref.watch(accessibilityProvider);
    final locale = ref.watch(localeControllerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ArquiTech',
      theme: AppTheme.withAccessibility(
        highContrast: accessibility.highContrast,
        reduceMotion: accessibility.reduceMotion,
      ),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(
              media.textScaler.scale(1) * accessibility.textScale,
            ),
            disableAnimations:
                accessibility.reduceMotion || media.disableAnimations,
          ),
          child: child!,
        );
      },
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
