import 'package:flutter/material.dart';

import '../../app/localization/localization_context.dart';

/// Shared brand artwork used by the mobile application and web frontend.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size / 6),
    child: Image.asset(
      'assets/images/arquitech-logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: context.l10n.appName,
    ),
  );
}
