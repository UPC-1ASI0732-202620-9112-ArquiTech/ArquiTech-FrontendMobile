import 'package:flutter/material.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/widgets/feature_placeholder_view.dart';

class IncidentsPlaceholderPage extends StatelessWidget {
  const IncidentsPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => FeaturePlaceholderView(
    title: context.l10n.incidents,
    message: context.l10n.comingSoon,
    icon: Icons.warning_amber_outlined,
  );
}
