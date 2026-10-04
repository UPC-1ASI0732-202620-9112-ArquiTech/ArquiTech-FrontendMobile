import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../app/localization/locale_controller.dart';
import '../../domain/entities/accessibility_preferences.dart';
import '../controllers/profile_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(accessibilityProvider);
    void change({double? scale, bool? contrast, bool? motion}) {
      ref
          .read(accessibilityProvider.notifier)
          .change(
            AccessibilityPreferences(
              textScale: scale ?? p.textScale,
              highContrast: contrast ?? p.highContrast,
              reduceMotion: motion ?? p.reduceMotion,
            ),
          );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(context.l10n.language),
          DropdownButton<String>(
            isExpanded: true,
            value: ref.watch(localeControllerProvider).languageCode,
            items: [
              DropdownMenuItem(value: 'es', child: Text(context.l10n.spanish)),
              DropdownMenuItem(value: 'en', child: Text(context.l10n.english)),
            ],
            onChanged: (v) {
              if (v != null) {
                ref.read(localeControllerProvider.notifier).change(Locale(v));
              }
            },
          ),
          Text(context.l10n.textSize),
          DropdownButton<double>(
            isExpanded: true,
            value: p.textScale,
            items: [
              DropdownMenuItem(value: 1, child: Text(context.l10n.normalText)),
              DropdownMenuItem(value: 1.3, child: Text(context.l10n.largeText)),
              DropdownMenuItem(
                value: 1.6,
                child: Text(context.l10n.extraLargeText),
              ),
            ],
            onChanged: (v) => change(scale: v),
          ),
          SwitchListTile(
            title: Text(context.l10n.highContrast),
            value: p.highContrast,
            onChanged: (v) => change(contrast: v),
          ),
          SwitchListTile(
            title: Text(context.l10n.reduceMotion),
            value: p.reduceMotion,
            onChanged: (v) => change(motion: v),
          ),
        ],
      ),
    );
  }
}
