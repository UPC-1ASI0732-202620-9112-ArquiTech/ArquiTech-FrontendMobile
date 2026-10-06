import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'localization/app_localizations.dart';
import 'localization/locale_controller.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../features/profile/presentation/controllers/profile_controller.dart';

class ArquiTechApp extends ConsumerStatefulWidget {
  const ArquiTechApp({super.key});

  @override
  ConsumerState<ArquiTechApp> createState() => _ArquiTechAppState();
}

class _ArquiTechAppState extends ConsumerState<ArquiTechApp> {
  SemanticsHandle? _webSemantics;

  @override
  void initState() {
    super.initState();
    // Keep accessible controls exposed across every route in Flutter Web.
    if (kIsWeb) {
      _webSemantics = WidgetsBinding.instance.ensureSemantics();
    }
  }

  @override
  void dispose() {
    _webSemantics?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
