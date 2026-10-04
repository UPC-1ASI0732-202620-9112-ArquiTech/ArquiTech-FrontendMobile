import 'package:flutter/material.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/widgets/feature_placeholder_view.dart';

class WorkersPlaceholderPage extends StatelessWidget {
  const WorkersPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => FeaturePlaceholderView(
    title: context.l10n.personnel,
    message: context.l10n.comingSoon,
    icon: Icons.groups_outlined,
  );
}
